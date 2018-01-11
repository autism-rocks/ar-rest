import express from 'express';
import Participant from '../model/participant'
import User from '../model/user'
import isLoggedIn from '../context/isLoggedIn'
import {DB} from '../database';


let router = express.Router();
let fields = ['name', 'gender', 'country', 'city'];

/**
 * Create a new participant
 */
router.post('/participant', isLoggedIn, function (req, res) {

    DB.transaction((tx) => {
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
 * Returns the list of users who have direct access to a participant
 */
router.get('/participant/:id_participant/users', isLoggedIn, function (req, res, next) {
    req.user.connectedParticipant(req.params.id_participant)
        .then((participant) => {
            if (!participant) {
                res.status(404).send({});
            } else {
                participant.users().fetch({columns: ['id', 'email', 'name', 'profile_photo', 'role']}).then((users) => {
                    res.send(users.toJSON({omitPivot: true}));
                });
            }
        })
        .catch(next);
});

/**
 * Returns the list of organizations who have direct access to a participant
 */
router.get('/participant/:id_participant/organizations', isLoggedIn, function (req, res, next) {
    req.user.connectedParticipant(req.params.id_participant)
        .then((participant) => {
            if (!participant) {
                res.status(404).send({});
            } else {
                participant.organizations().fetch({columns: ['id', 'email', 'display_name', 'role']}).then((organizations) => {
                    res.send(organizations.toJSON({omitPivot: true}));
                });
            }
        })
        .catch(next);
});

/**
 * Adds or modifies the access between user and participant
 */
router.post('/participant/:id_participant/users', isLoggedIn, function (req, res, next) {
    req.user.connectedParticipant(req.params.id_participant, ['ADMIN'])
        .then((participant) => {
            if (!participant) {
                res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
            } else {
                if (req.body.email == req.user.get('email')) {
                    res.status(409).send({status: 'ERROR', message: 'CANNOT_SET_OWN_ACCESS_LEVELS'});
                } else if (req.body.id) {
                    return DB('user_participant')
                        .update({role: req.body.role})
                        .where({
                            id_participant: participant.get('id'),
                            id_user: req.body.id
                        })
                        .then(() => {
                            res.send({status: 'SUCCESS', message: 'PARTICIPANT_USER_ROLE_UPDATED'});
                        })
                } else if (req.body.email) {
                    return User.where({email: req.body.email}).fetch().then((user) => {
                        if (user) {
                            // user already in our system, so we can just attach the participant
                            return user.participants().attach({
                                id_participant: participant.get('id'),
                                role: 'VIEWER'
                            }).then(() => {
                                res.send({status: 'SUCCESS', message: 'USER_ADDED_TO_PARTICIPANT'});
                            });
                        } else {
                            // user does not exist which means we need to create a new user and attach the participant to it
                            user = new User();
                            user.set('email', req.body.email);
                            return user.save().then(() => {
                                user.participants().attach({
                                    id_participant: participant.get('id'),
                                    role: 'VIEWER'
                                }).then(() => {
                                    res.send({status: 'SUCCESS', message: 'USER_ADDED_TO_PARTICIPANT'});
                                });
                            })
                        }
                    });
                } else {
                    res.status(400).send({status: 'ERROR', message: 'USER_DETAILS_MISSING'});
                }
            }
        })
        .catch(next);
});

/**
 * Adds or modifies the access between organization and participant
 */
router.post('/participant/:id_participant/organizations', isLoggedIn, function (req, res, next) {
    req.user.connectedParticipant(req.params.id_participant, ['ADMIN'])
        .then((participant) => {
            if (!participant) {
                res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
            } else {
                req.body.id = parseInt(req.body.id, 10);

                return participant.organizations().query({where: {id_organization: req.body.id}}).fetch().then((orgs) => {
                    let query = DB('organization_participant');
                    if (orgs.length > 0) {
                        query.update({role: req.body.role ? req.body.role : 'VIEWER'}).where({
                            id_participant: participant.get('id'),
                            id_organization: req.body.id
                        });
                    } else {
                        query.insert({
                            id_participant: participant.get('id'),
                            id_organization: req.body.id,
                            role: 'VIEWER'
                        });
                    }
                    return query.then(() => {
                        res.send({status: 'SUCCESS', message: 'PARTICIPANT_ORGANIZATION_ROLE_UPDATED'});
                    });

                });

            }
        })
        .catch(next);
});


/**
 * Remove user access to a participant
 */
router.delete('/participant/:id_participant/users', isLoggedIn, function (req, res, next) {
    req.user.connectedParticipant(req.params.id_participant, ['ADMIN'])
        .then((participant) => {
            if (!participant) {
                res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
            } else {
                if (req.body.email == req.user.get('email')) {
                    res.status(409).send({status: 'ERROR', message: 'CANNOT_SET_OWN_ACCESS_LEVELS'});
                } else if (req.body.id) {
                    return DB('user_participant')
                        .where({
                            id_participant: participant.get('id'),
                            id_user: req.body.id
                        })
                        .delete()
                        .then(() => {
                            res.send({status: 'SUCCESS', message: 'PARTICIPANT_USER_ROLE_UPDATED'});
                        })
                } else {
                    res.status(400).send({status: 'ERROR', message: 'USER_DETAILS_MISSING'});
                }
            }
        })
        .catch(next);
});

/**
 * Remove organization access to a participant
 */
router.delete('/participant/:id_participant/organizations', isLoggedIn, function (req, res, next) {
    req.user.connectedParticipant(req.params.id_participant, ['ADMIN'])
        .then((participant) => {
            if (!participant) {
                res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
            } else {
                if (req.body.id) {
                    return DB('organization_participant')
                        .where({
                            id_participant: participant.get('id'),
                            id_organization: parseInt(req.body.id, 10)
                        })
                        .delete()
                        .then(() => {
                            res.send({status: 'SUCCESS', message: 'PARTICIPANT_ORGANIZATION_ROLE_UPDATED'});
                        })
                } else {
                    res.status(400).send({status: 'ERROR', message: 'ORGANIZATION_DETAILS_MISSING'});
                }
            }
        })
        .catch(next);
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
