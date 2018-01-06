import express from 'express';
import {DB} from '../database';
import isLoggedIn from '../context/isLoggedIn'
import _ from 'lodash';


let router = express.Router();


router.get('/development_model/:lang/:ref/:id_participant', isLoggedIn, function (req, res, next) {

    req.user.participants().query(function (qb) {
        qb.where('id_participant', req.params.id_participant)
    }).fetch().then((participants) => {

        let verifiedParticipantId = participants.first().get('id');

        DB.from('model as m')
            .join('model_lang as ml', 'm.id', 'ml.id_model')
            .join('lang as l', 'ml.id_lang', 'l.id')
            .join('model_group as mg', 'm.id', 'mg.id_model')
            .join('model_group_lang as mgl', 'mg.id', 'mgl.id_model_group')
            .join('lang as mgll', 'mgl.id_lang', 'mgll.id')
            .leftJoin('model_question as mq', 'mq.id_model_group', 'mg.id')
            .leftJoin('model_question_lang as mql', 'mql.id_model_question', 'mq.id')
            .leftJoin('lang as mqll', 'mqll.id', 'mql.id_lang')
            .leftJoin(DB.raw(`model_question_eval AS mqe_previous ON mqe_previous.id = (SELECT MAX(id) FROM model_question_eval WHERE id_participant=? AND id_user=? AND confirmed=true AND id_model_question = mq.id)`, [verifiedParticipantId, req.user.get('id')]))
            .leftJoin(DB.raw(`model_question_eval AS mqe_current ON mqe_current.id = (SELECT MAX(id) FROM model_question_eval WHERE id_participant=? AND id_user=? AND confirmed=false AND id_model_question = mq.id)`, [verifiedParticipantId, req.user.get('id')]))
            .orderBy(['mg.sequence_number', 'mg.id', 'mq.sequence_number', 'mq.id'])
            .select([
                'ml.name',
                'm.ref',
                'mg.id as group_id',
                'mg.id_parent as group_parent_id',
                'mg.ref as group_ref',
                'mg.sequence_number as sequence',
                'mgl.name as group',
                'mq.id as question_id',
                'mq.ref as question_ref',
                'mql.title as question_title',
                'mql.description as question_description',
                'mqe_previous.level as previous_level',
                'mqe_current.level as current_level'
            ])
            .then((questions) => {
                let data = [];
                if (questions.length > 0) {

                    function attachQuestions(questions, subgroup) {
                        questions.filter(q => q.group_id == subgroup._id && q.question_id).forEach((q, k) => {
                            subgroup.data.push({
                                id: `${subgroup.id}.${k + 1}`,
                                _id: q.question_id,
                                question: q.question_title,
                                ref: q.question_ref,
                                description: q.question_description,
                                previous_level: q.previous_level,
                                current_level: q.current_level ? q.current_level : q.previous_level,
                                placeholder: q.current_level ? false : true
                            })
                        });
                    }

                    // build the group tree
                    // this is a real mess. need to figure out a better way to build the tree...
                    _.uniqWith(questions.filter(q => !q.group_parent_id).map(q => {
                        return {
                            _id: q.group_id,
                            ref: q.group_ref,
                            open: true,
                            group: q.group
                        }
                    }), _.isEqual).forEach((group, i) => {
                        group.id = `${i + 1}`;
                        group.data = [];
                        attachQuestions(questions, group);
                        _.uniqWith(questions.filter((q => q.group_parent_id == group._id)).map(q => {
                            return {
                                _id: q.group_id,
                                open: true,
                                group: q.group
                            }
                        }), _.isEqual).forEach((subgroup, j) => {
                            subgroup.id = `${group.id}.${j + 1}`
                            subgroup.data = [];
                            attachQuestions(questions, subgroup);
                            group.data.push(subgroup);
                        });
                        data.push(group);
                    });

                    res.send(data);
                } else {
                    res.status(404).send(data);
                }
            });

    }).catch(next);

});


router.post('/development_model/:lang/:ref/:id_participant', isLoggedIn, function (req, res, next) {

    req.user.participants().query(function (qb) {
        qb.whereIn('role', ['ADMIN', 'EDITOR']).where('id_participant', req.params.id_participant)
    }).fetch().then((participants) => {

        if (participants.length == 0) {
            res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
        } else {
            let verifiedParticipantId = participants.first().get('id');
            let evaluation = {
                id_user: req.user.get('id'),
                id_participant: verifiedParticipantId,
                id_model_question: req.body._id,
                confirmed: false
            };
            return DB.from('model_question_eval')
                .where(evaluation).first()
                .then((e) => {

                    if (e) {
                        e.level = req.body.current_level;
                        return DB('model_question_eval').update(e).where({id: e.id});
                    } else {
                        evaluation.level = req.body.current_level;
                        return DB.insert(evaluation).into('model_question_eval');
                    }
                })
                .then(() => {
                    res.send({status: 'SUCCESS', message: 'EVALUATION_STORED'});
                });
        }

    }).catch(next);

});


router.post('/development_model/:lang/:ref/:id_participant/record', isLoggedIn, function (req, res, next) {

    req.user.participants().query(function (qb) {
        qb.whereIn('role', ['ADMIN', 'EDITOR']).where('id_participant', req.params.id_participant)
    }).fetch().then((participants) => {

        let date = new Date();
        if (req.body.date) {
            date = new Date(req.body.date);
        }

        if (participants.length == 0) {
            res.status(403).send({status: 'ERROR', message: 'PERMISSION_DENIED'});
        } else {
            let verifiedParticipantId = participants.first().get('id');
            DB.transaction((tx) => tx('model_question_eval')
                .where({
                    id_user: req.user.get('id'),
                    id_participant: verifiedParticipantId,
                    date: date,
                    confirmed: true
                })
                .delete()
                .then(() => {
                    return tx('model_question_eval').update({
                        confirmed: true,
                        date: date
                    }).where({
                        confirmed: false,
                        id_user: req.user.get('id'),
                        id_participant: verifiedParticipantId
                    })
                }))
                .then(() => {
                    res.send({status: 'SUCCESS', message: 'MODEL_PROGRESS_RECORDED'})
                });
        }

    }).catch(next);

});


export default function () {
    return router;
};
