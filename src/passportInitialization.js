// import LocalStrategy from 'passport-local';
import FacebookStrategy from 'passport-facebook';
let GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;

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
        // console.log(User.where({id: id}).fetch().toSQL())
        User.where({id: id}).fetch().then((user) => {
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

                User.query(function (qb) {
                    qb.where({facebook_id: profile.id}).orWhere({email: profile.emails[0].value});
                }).fetch().then((user) => {

                    if (!user) {
                        user = new User();
                        user.set('email', profile.emails[0].value);
                        user.set('facebook_id', profile.id);
                    }

                    user.set('name', [profile.name.givenName, profile.name.middleName, profile.name.familyName].filter(x => x).join(' '));
                    user.set('display_name', [profile.name.givenName, profile.name.familyName].filter(x => x).join(' '));
                    user.set('logged_in_at', new Date());
                    user.set('locale', profile._json.locale);
                    user.set('timezone', profile._json.timezone);
                    user.set('profile_photo', `https://graph.facebook.com/${user.facebook_id}/picture?type=normal`);

                    return user.save();
                }).then((user) => {
                    done(null, user);
                }).catch((err) => {
                    done(err);
                });

            });

        }));

    passport.use(new GoogleStrategy(configAuth.googleAuth,
        function (token, tokenSecret, profile, done) {
            User.query(function (qb) {
                qb.where({google_id: profile.id}).orWhere({email: profile.emails[0].value});
            }).fetch().then((user) => {

                if (!user) {
                    user = new User();
                    user.set('email', profile.emails[0].value);
                    user.set('facebook_id', profile.id);
                }

                user.set('name', [profile.name.givenName, profile.name.familyName].filter(x => x).join(' '));
                user.set('display_name', profile.displayName);
                user.set('logged_in_at', new Date());
                user.set('locale', profile._json.language);
                user.set('timezone', 0);
                if (profile.photos && profile.photos.length > 0){
                    user.set('profile_photo', profile.photos[0].value.replace('sz=50', 'sz=200'));
                } else {
                    // TODO: Configure default photo
                }


                return user.save();
            }).then((user) => {
                done(null, user);
            }).catch((err) => {
                done(err);
            });
        }
    ));

}