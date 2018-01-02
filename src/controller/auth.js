import express from 'express';
import passport from 'passport';

let router = express.Router();


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
router.get('/auth/logout', function(req, res) {
    req.logout();
    res.send({});
});

export default function() {
    return router;
};
