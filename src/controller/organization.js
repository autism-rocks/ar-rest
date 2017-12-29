import Organization from '../model/organization';
import {DB} from '../database';
import express from 'express';
let router = express.Router();
const createOrgFields = ['name', 'display_name', 'address', 'country', 'city', 'postcode', 'phone', 'website', 'email'];

router.get('/organizations', function (req, res) {
    Organization.query().select(['id', 'display_name as value']).orderBy('display_name').then((orgs) => {
        orgs.unshift({id:null, value:''});
        res.send(orgs);
    });
});

router.post('/organizations', function (req, res) {
    let newOrg = req.body;


    // check if the organization already exists
    Organization.query()
        .where('email', newOrg.email).orWhere('name', newOrg.name)
        .first()
        .then((org) => {
            if (org) {
                res.status(409).send({status: 'ERROR', message:'ORGANIZATION_ALREADY_EXISTS'});
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
                    res.status(409).send({status: 'ERROR', message:'ERROR_CREATING_ORGANIZATION'});
                    console.error(error);
                });
            }
        });
});


export default function () {
    return router;
};
