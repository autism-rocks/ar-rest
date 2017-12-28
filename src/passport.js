// import LocalStrategy from 'passport-local';
import FacebookStrategy from 'passport-facebook';
import User from './model/user';

const configAuth = require('../.config/auth');

/**
 * General Passport configuration
 *
 * @param passport
 */
export default function (passport) {

    // used to serialize the user for the session
    passport.serializeUser(function (user, done) {
        done(null, user.id);
    });

    // used to deserialize the user
    passport.deserializeUser(function (id, done) {
        User.query().where({id: id}).first().then((user) => {
            done(null, user);
        }).catch((err) => {
            done(err);
        });
    });

    passport.use(new FacebookStrategy(configAuth.facebookAuth,

        // facebook will send back the token and profile
        function (token, refreshToken, profile, done) {

            // asynchronous
            process.nextTick(function () {

                if (!profile._json.verified) {
                    return done('Application only accepts authentication for verified Facebook Users');
                }

                User.query().where({facebook_id: profile.id}).first().then((user) => {

                    if (!user) {
                        user = new User();
                        user.email = profile.emails[0].value;
                        user.facebook_id = profile.id;
                    }

                    user.name = [profile.name.givenName, profile.name.middleName, profile.name.familyName].filter(x => x).join(' ');
                    user.display_name = [profile.name.givenName, profile.name.familyName].filter(x => x).join(' ');
                    user.logged_in_at = new Date();
                    user.locale = profile._json.locale;
                    user.timezone = profile._json.timezone;

                    return user.save().then((ids) => {
                        if (!user.id) {
                            user.id = ids[0]
                        }
                        return user;
                    });
                }).then((user) => {
                    done(null, user);
                }).catch((err) => {
                    done(err);
                });

            });

        }));

}