import express from 'express';
import passport from 'passport';
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
 * Serves the User Profile
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
                        .then((x) => {
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
