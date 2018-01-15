import Organization from '../model/organization';
import {DB} from '../database';
import express from 'express';
import isLoggedIn from '../context/isLoggedIn'

let router = express.Router();
const createOrgFields = ['name', 'display_name', 'address', 'country', 'city', 'postcode', 'phone', 'website', 'email'];

router.get('/organizations', function (req, res) {
    Organization.query().select(['id', 'display_name as value']).orderBy('display_name').then((orgs) => {
        res.send(orgs);
    });
});


router.get('/organization/:org/users', isLoggedIn, function (req, res, next) {
    req.user.organizations()
        .query(function (qb) {
            qb.whereIn('role', ['ADMIN', 'HELPDESK', 'TERAPEUT'])
                .where('name', req.params.org)
        })
        .fetchOne()
        .then(org => {
            if (!org) {
                res.status(404).send({});
            } else {
                org.users().fetch({columns: ['id', 'name', 'email', 'role', 'country', 'city', 'logged_in_at', 'phone', 'profile_photo']})
                    .then((users) => {
                        res.send(users.toJSON({omitPivot: true}))
                    });
            }
        }).catch(next);

});

router.post('/organization/:org/users/:id_user', isLoggedIn, function (req, res, next) {
    req.user.organizations()
        .query(function (qb) {
            qb.whereIn('role', ['ADMIN'])
                .where('name', req.params.org)
        })
        .fetchOne()
        .then(org => {
            if (!org) {
                res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
            } else if (req.params.id_user != req.user.get('id')) {
                org.users()
                    .updatePivot({role: req.body.role}, {query: {where: {id_user: req.params.id_user}}}).then(() => {
                    res.send({status: 'SUCCESS', message: 'ROLE_UPDATED'});
                });
            } else {
                res.status(403).send({status: 'ERROR', message: 'CANNOT_UPDATE_OWN_ROLE'});
            }
        }).catch(next);

});

router.post('/organizations', function (req, res) {
    let newOrg = req.body;

    // check if the organization already exists
    Organization.query()
        .where('email', newOrg.email).orWhere('name', newOrg.name)
        .first()
        .then((org) => {
            if (org) {
                res.status(409).send({status: 'ERROR', message: 'ORGANIZATION_ALREADY_EXISTS'});
            } else {
                DB.transaction(function (trx) {
                    let org = {};
                    createOrgFields.forEach((f) => org[f] = newOrg[f]);
                    return trx.insert(org).into('organization').then((ids) => {
                        return trx.insert({
                            id_organization: ids[0],
                            id_user: req.user.id,
                            role: 'ADMIN'
                        }).into('user_organization');
                    });
                }).then(function () {
                    res.send({status: 'SUCCESS', message: 'ORGANIZATION_CREATED'});
                }).catch(function (error) {
                    res.status(409).send({status: 'ERROR', message: 'ERROR_CREATING_ORGANIZATION'});
                    console.error(error);
                });
            }
        });
});


export default function () {
    return router;
};
