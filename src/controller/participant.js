import express from 'express';
import Participant from '../model/participant'
import isLoggedIn from '../context/isLoggedIn'
import {DatabaseORM} from '../database';


let router = express.Router();
let fields = ['name', 'gender', 'country', 'city'];

/**
 * Create a new participant
 */
router.post('/participant', isLoggedIn, function (req, res) {

    DatabaseORM.transaction((tx) => {
        let participant = new Participant();
        // filter body fields
        fields.forEach((f) => {
            participant.set(f, req.body[f]);
        });

        // convert date to object
        participant.set('dob', new Date(req.body.dob));


        return participant.save(null, {transacting: tx})
            // grant ADMIN permisions to creating user
            .then((participant) => req.user.participants().attach({
                    id_participant: participant.id,
                    role: 'ADMIN'
                }, {transacting: tx})
            )
            // grant EDITOR permissions by default to particpants on all user organizations
            // TODO: If a user has many organizations, this code can take over all DB connections. Needs to be
            // moved to an async queue
            .then(() => req.user.organizations().fetch())
            .then((organizations) => {
                return Promise.all(
                    organizations.map((org) => org.participants()
                        .attach({
                            id_participant: participant.id,
                            role: 'EDITOR'
                        }, {transacting: tx})
                    ))
            })
            .then(() => {
                return participant;
            });
    })
        .then((participant) => {
            res.send({status: 'SUCCESS', message: 'PARTICIPANT_CREATED', data: participant.toJSON()});
        })
        .catch((err) => {
            console.log(err);
            res.status(500).send({status: 'ERROR', message: 'ERROR_CREATING_PARTICIPANT'});
        });

});


/**
 * Return the Direct participants for the current user
 */
router.get('/participants', isLoggedIn, function (req, res) {
    req.user.participants().fetch().then((participants) => {
        res.send(participants);
    });
});

/**
 * Return information about a specific participant that the current user
 * has access to
 */
router.get('/participant/:id_participant', isLoggedIn, function (req, res) {
    req.user.connectedParticipant(req.params.id_participant, ['ADMIN', 'EDITOR', 'TERAPEUT', 'VIEWER'])
        .then((participant) => {
        if (!participant) {
            res.status(404).send({});
        } else {
            res.send(participant.toJSON({omitPivot: true}));
        }
    });
});


/**
 * Save details of a specific participant
 */
router.post('/participant/:id_participant', isLoggedIn, function (req, res) {
    req.user.connectedParticipant(req.params.id_participant, ['ADMIN', 'EDITOR', 'TERAPEUT'])
        .then((participant) => {
        if (participant) {
            fields.forEach((f) => {
                participant.set(f, req.body[f]);
            });

            // convert date to object
            participant.set('dob', new Date(req.body.dob));

            participant.save().then(() => {
                res.send({status: 'SUCCESS', message: 'PARTICIPANT_DETAILS_SAVED'});
            }).catch(() => {
                res.status(500).send({status: 'ERROR', message: 'ERROR_UPDATING_PARTICIPANT_DETAILS'});
            })

        } else {
            res.status(404);
        }
    });
});


export default function () {
    return router;
};
