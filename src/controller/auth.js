/**
 * Responds with a 401 if the user is not authenticated
 *
 * @param req
 * @param res
 * @param next
 * @returns {*}
 */
function isLoggedIn(req, res, next) {
    if (req.isAuthenticated())
        return next();
    else {
        res.status(401).send()
    }
}

module.exports = function(app, passport) {

    /**
     * Serves the User Profile
     */
    app.get('/profile', isLoggedIn, function(req, res) {
        res.send({
            display_name: req.user.display_name,
            locale: req.user.locale
        });
    });

    /**
     * Initializes the Facebook Authentication process
     */
    app.get('/auth/facebook', passport.authenticate('facebook'));

    /**
     * Callback for the Facebook Authentication redirect
     */
    app.get('/auth/facebook/callback',
        passport.authenticate('facebook', {
            successRedirect : '/profile',
            failureRedirect : '/profile',
            scope: ['id', 'public_profile', 'email', 'gender', 'link', 'locale', 'name', 'timezone', 'updated_time', 'verified']
        }));

    /**
     * Logs the current user out
     */
    app.get('/logout', function(req, res) {
        req.logout();
        res.send({});
    });
};
