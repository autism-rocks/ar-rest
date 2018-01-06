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


export default function () {
    return router;
};
