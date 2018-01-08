import express from 'express';
import {DB} from '../database';
import Organization from '../model/organization'

let router = express.Router();
let updateProfileFields = ['address', 'city', 'country', 'phone', 'postcode'];

/**
 * Responds with a 401 if the user is not authenticated
 *
 * TODO: Move to Utils
 *
 * @param req
 * @param res
 * @param next
 * @returns {*}
 */
export function isLoggedIn(req, res, next) {
    if (req.isAuthenticated())
        return next();
    else {
        res.status(401).send()
    }
}

/**
 * Serves the current User Profile
 */
router.get('/user/profile', isLoggedIn, function (req, res) {

    req.user.organizations().fetch().then((orgs) => {
        res.send({
            display_name: req.user.get('display_name'),
            email: req.user.get('email'),
            profile_photo: req.user.get('profile_photo'),
            locale: req.user.get('locale'),
            organizations: orgs.map((o) => {
                return {
                    name: o.get('name'),
                    display_name: o.get('display_name'),
                    role: o.pivot.get('role')
                };
            })
        });
    })

});

/**
 * Returns a user profile based on the access available for the current user
 */
router.get('/user/profile/:id', isLoggedIn, function (req, res, next) {

    // from all the organizations where the current user has previledges,
    // we are going to see if any pf them has access to the current
    // requested user profile...
    req.user.organizations().query(function (qb) {
        qb.whereIn('role', ['ADMIN', 'HELPDESK', 'TERAPEUT'])
    })
        .fetch({columns: ['id', 'name', 'display_name', 'role']})
        .then((organizations) => {

            // TODO: make this into a queue because having too many orgs will kill the db connection pool

            return Promise.all(
                organizations.map(org => org.users().query({where: {id: req.params.id}})
                    .fetch({columns: ['id', 'display_name', 'email', 'profile_photo']}))
            ).then((users) => {
                // loop as the same user might appear in more than one organization
                for (let i = 0; i < users.length; i++) {
                    if (users[i].length > 0) {
                        return [users[i].first(), organizations.at(i)];
                    }
                }
            })
            // console.log(organizations);

        })
        .then((data) => {
            if (!data || data.length < 2) {
                res.status(404).send({});
            } else {
                let user = data[0];
                let organization = data[1];

                // find a connection between the current user and the participants
                // to whom the user being retrieved has access
                return DB.from('participant as p')
                    .join('organization_participant as op', 'op.id_participant', 'p.id')
                    .join('organization as o', 'o.id', 'op.id_organization')
                    .join('user_organization as uo', 'uo.id_organization', 'o.id')
                    .join('user_participant as up', 'up.id_participant', 'p.id')
                    .where('uo.id_user', req.user.get('id'))
                    .where('up.id_user', user.get('id'))
                    .whereIn('uo.role', ['ADMIN', 'HELPDESK', 'TERAPEUT'])
                    .whereIn('op.role', ['EDITOR', 'VIEWER'])
                    .select(['p.id', 'p.name', 'p.dob', 'p.gender', 'p.photo', 'op.role as role_organization', 'up.role as role_user'])
                    .then((participants) => {
                        let response = user.toJSON({omitPivot: true});
                        response.participants = participants;
                        response.organization = organization.toJSON({omitPivot: true});
                        res.send(response);
                    });
            }
        })
        .catch(next);


});

router.get('/user/organizations', isLoggedIn, function (req, res) {

    req.user.organizations().fetch().then((orgs) => {
        res.send(orgs.map((o) => {
            return {
                name: o.get('name'),
                display_name: o.get('display_name'),
                role: o.pivot.get('role')
            };
        }));
    })

});

router.post('/user/profile', isLoggedIn, function (req, res) {
    let updateUser = {};
    // filter body fields
    updateProfileFields.forEach((f) => {
        updateUser[f] = req.body[f]
    });

    req.user.set(updateUser).save().then((user) => {
        if (req.body.org) {
            Organization.where({id: req.body.org}).fetch().then((org) => {
                if (org) {
                    req.user.related('organizations')
                        .attach({
                            id_organization: org.id,
                            role: 'MEMBER'
                        })
                        .then(() => {
                            res.send({status: 'SUCCESS', message: 'USER_PROFILE_UPDATED'});
                        }).catch((err) => {
                        console.log(err);
                        // TODO: Only send the success status if this was indeed a primary key violation error
                        res.send({status: 'SUCCESS', message: 'USER_ALREADY_ASSOCIATED_WITH_ORGANIZATION'});
                    })
                } else {
                    res.status(404).send({status: 'ERROR', message: 'ORGANIZATION_NOT_FOUND'});
                }
            })
        } else {
            res.send({status: 'SUCCESS', message: 'USER_PROFILE_UPDATED'});
        }


    });


});


export default function () {
    return router;
};
