import express from 'express';
import flash from 'connect-flash';
import logger from 'morgan';
import cookieParser from 'cookie-parser';
import bodyParser from 'body-parser';
import session from 'cookie-session';
import passport from 'passport';
import passportInitialization from './passportInitialization';
import AuthController from  './controller/auth';
import OrganizationController from  './controller/organization';
import GeoController from  './controller/geo';
import UserController from  './controller/user';
import ParticipantController from  './controller/participant';



// initialize the express server
const app = express();

// configure port
const port = process.env.PORT || 8686;

// attach logger
app.use(logger('combined'));

// attach cookie parser
app.use(cookieParser());

// attach body parsers
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// attach session handling
app.use(session(require('../.config/session.js')));

// load configurations into passport
passportInitialization(passport);

// initialize passport
app.use(passport.initialize());

// initialize passport session
app.use(passport.session());

// initialize session flash messaging
app.use(flash());

app.use('/ar', AuthController());
app.use('/ar', OrganizationController());
app.use('/ar', GeoController());
app.use('/ar', UserController());
app.use('/ar', ParticipantController());

// start accepting connections
app.listen(port);
console.log('AR Rest Service now Listening on ' + port);