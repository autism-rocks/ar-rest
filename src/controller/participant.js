import express from 'express';
import Participant from '../model/participant'
import isLoggedIn from '../context/isLoggedIn'
import {DatabaseORM} from '../database';


let router = express.Router();
let fields = ['name', 'gender', 'country', 'city'];

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
            .then((participant) => {
                return req.user.related('participants')
                    .attach({
                        id_participant: participant.id,
                        role: 'ADMIN'
                    }, {transacting: tx})
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


router.get('/participants', isLoggedIn, function (req, res) {
    req.user.participants().fetch().then((participants) => {
        res.send(participants);
    });
});

router.get('/participant/:id_participant', isLoggedIn, function (req, res) {
    req.user.participants().query(function (qb) {
        qb.where('id_participant', req.params.id_participant)
    }).fetch().then((participants) => {
        res.send(participants.first());
    });
});


router.post('/participant/:id_participant', isLoggedIn, function (req, res) {
    req.user.participants().query(function (qb) {
        qb.where('id_participant', req.params.id_participant).whereIn('role', ['ADMIN', 'EDITOR'])
    }).fetch().then((participants) => {
        if (participants.length > 0) {
            let participant = participants.first();
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
            res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
        }
    });
});


export default function () {
    return router;
};
