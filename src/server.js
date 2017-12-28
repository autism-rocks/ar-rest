import express from 'express';
import passport from 'passport';
import flash from 'connect-flash';
import logger from 'morgan';
import cookieParser from 'cookie-parser';
import bodyParser from 'body-parser';
import session from 'express-session';
import passportInitialization from './passport';

// initialize the express server
const app = express();

// configure port
const port = process.env.PORT || 8686;

// load configurations into passport
passportInitialization(passport);

// attach logger
app.use(logger('combined'));

// attach cookie parser
app.use(cookieParser());

// attach body parsers
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// attach session handling
app.use(session(require('../.config/session.js')));

// initialize passport
app.use(passport.initialize());

// initialize passport session
app.use(passport.session());

// initialize session flash messaging
app.use(flash());

// include controllers
require('./controller/auth.js')(app, passport);

// start accepting connections
app.listen(port);
console.log('AR Rest Service now Listening on ' + port);