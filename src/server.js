import express from 'express';
import flash from 'connect-flash';
import logger from 'morgan';
import cookieParser from 'cookie-parser';
import bodyParser from 'body-parser';
import session from 'cookie-session';
import passport from 'passport';
import passportInitialization from './passportInitialization';




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

app.use('/ar', require('./controller/auth').default());
app.use('/ar', require('./controller/geo').default());
app.use('/ar', require('./controller/user').default());
app.use('/ar', require('./controller/participant').default());
app.use('/ar', require('./controller/organization').default());
app.use('/ar', require('./controller/development_model').default());


// setup healthcheck
app.get(`/_ah/health`, function respond(req, res, next) {
    res.send({status: 'OK'});
    next();
});

// global error handler
app.use(function (err, req, res, next) {
    console.log(err);
    res.status(500).send({
        status: 'ERROR',
        message: 'UNKNOWN_SERVER_ERROR'
    });
    next();
});

// start accepting connections
app.listen(port);
console.log('AR Rest Service now Listening on ' + port);