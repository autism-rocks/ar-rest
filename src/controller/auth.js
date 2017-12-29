import express from 'express';
import passport from 'passport';
import User from '../model/user';

let router = express.Router();

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
router.get('/profile', isLoggedIn, function(req, res) {

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
    // console.log(req.user);
    //
    // req.user.organizations().then((data) => {
    //     console.log(data);
    // });


});

/**
 * Initializes the Facebook Authentication process
 */
router.get('/auth/facebook', passport.authenticate('facebook'));

/**
 * Callback for the Facebook Authentication redirect
 */
router.get('/auth/facebook/callback',
    passport.authenticate('facebook', {
        successRedirect : '/',
        failureRedirect : '/',
        scope: ['id', 'public_profile', 'email', 'gender', 'link', 'locale', 'name', 'timezone', 'updated_time', 'verified']
    }));

/**
 * Initializes the Google Authentication process
 */
router.get('/auth/google', passport.authenticate('google', { scope : ['profile', 'email'] }));


/**
 * Callback for the Google Authentication redirect
 */
router.get('/auth/google/callback',
    passport.authenticate('google', {
        successRedirect : '/',
        failureRedirect : '/'
    }));

/**
 * Logs the current user out
 */
router.get('/logout', function(req, res) {
    req.logout();
    res.send({});
});

export default function() {
    return router;
};
