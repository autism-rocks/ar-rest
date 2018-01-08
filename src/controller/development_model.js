import express from 'express';
import {DB} from '../database';
import isLoggedIn from '../context/isLoggedIn'
import _ from 'lodash';


let router = express.Router();

/**
 * Returns a development model from the database, organized into groups and subgroups of questions.
 * The model is populated with current and previous answers provided by a specific user (userId)
 * @param modelRef
 * @param participantId
 * @param userId
 * @returns {Promise.<TResult>}
 */
function retrievePopulatedDevelopmentModel(modelRef, participantId, userId) {

    return DB.from('model as m')
        .join('model_lang as ml', 'm.id', 'ml.id_model')
        .join('lang as l', 'ml.id_lang', 'l.id')
        .join('model_group as mg', 'm.id', 'mg.id_model')
        .join('model_group_lang as mgl', 'mg.id', 'mgl.id_model_group')
        .join('lang as mgll', 'mgl.id_lang', 'mgll.id')
        .leftJoin('model_question as mq', 'mq.id_model_group', 'mg.id')
        .leftJoin('model_question_lang as mql', 'mql.id_model_question', 'mq.id')
        .leftJoin('lang as mqll', 'mqll.id', 'mql.id_lang')
        .leftJoin(DB.raw(`model_question_eval AS mqe_previous ON mqe_previous.id = (SELECT MAX(id) FROM model_question_eval WHERE id_participant=? AND id_user=? AND confirmed=true AND id_model_question = mq.id)`, [participantId, userId]))
        .leftJoin(DB.raw(`model_question_eval AS mqe_current ON mqe_current.id = (SELECT MAX(id) FROM model_question_eval WHERE id_participant=? AND id_user=? AND confirmed=false AND id_model_question = mq.id)`, [participantId, userId]))
        .orderBy(['mg.sequence_number', 'mg.id', 'mq.sequence_number', 'mq.id'])
        .where('m.ref', modelRef)
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
            'mq.scale as scale',
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
                        let item = {
                            id: `${subgroup.id}.${k + 1}`,
                            _id: q.question_id,
                            question: q.question_title,
                            ref: q.question_ref,
                            scale: q.scale,
                            description: q.question_description,
                            previous_level: q.previous_level,
                            current_level: q.current_level ? q.current_level : q.previous_level,
                            placeholder: q.current_level ? false : true
                        };

                        if (item.previous_level) {
                            item.previous_level = `${item.scale}:${item.previous_level}`
                        }

                        if (item.current_level) {
                            item.current_level = `${item.scale}:${item.current_level}`
                        }

                        subgroup.data.push(item)
                    });
                }

                data = buildModelTree(questions, attachQuestions);

            }

            return data;
        });
}


/**
 * Takes a mixed list of questions/groups and builds a tree.
 * @param questions
 * @param attach
 * @param parentGroupId
 * @returns {Array}
 */
function buildModelTree(questions, attach, parentGroupId) {
    let data = [];
    // build the group tree
    // this is a real mess. need to figure out a better way to build the tree...
    let questionsWithinGroup = _.uniqWith(questions.filter(q => q.group_parent_id == parentGroupId).map((q, i) => {
        return {
            _id: q.group_id,
            ref: q.group_ref,
            open: true,
            group: q.group
        }
    }), _.isEqual);

    questionsWithinGroup.forEach((group, i) => {
        group.id = (parentGroupId ? `${parentGroupId}.` : '') + `${i + 1}`;
        group.data = buildModelTree(questions, attach, group._id);
        attach(questions.filter(q => q.group_id == group._id), group);
        data.push(group);
    });

    return data;
}


/**
 * For a given development model, returns the group tree along with the average level
 * for a specific participant
 *
 * @param modelRef
 * @param participantId
 * @param filters
 * @returns {Promise.<TResult>}
 */
function getModelSummary(modelRef, participant, filters) {
    let fields = [
        'ml.name',
        'm.ref',
        'mg.id as group_id',
        'mg.id_parent as group_parent_id',
        'mg.ref as group_ref',
        'mg.sequence_number as sequence',
        'mgl.name as group'];
    let groupByFields = ['mg.sequence_number', 'mg.id', 'mq.sequence_number', 'name', 'ref', 'group_id', 'group_parent_id', 'group_ref', 'sequence', 'group'];

    return DB.from('model as m')
        .join('model_lang as ml', 'm.id', 'ml.id_model')
        .join('lang as l', 'ml.id_lang', 'l.id')
        .join('model_group as mg', 'm.id', 'mg.id_model')
        .join('model_group_lang as mgl', 'mg.id', 'mgl.id_model_group')
        .join('lang as mgll', 'mgl.id_lang', 'mgll.id')
        .leftJoin('model_question as mq', 'mq.id_model_group', 'mg.id')
        .leftJoin('model_question_lang as mql', 'mql.id_model_question', 'mq.id')
        .leftJoin('lang as mqll', 'mqll.id', 'mql.id_lang')
        .leftJoin('model_question_eval as mqe', 'mqe.id_model_question', 'mq.id') //  TODO: This should only join up with the latest N entries of each question and not all of them. It's good enough for now...
        .orderBy(['mg.sequence_number', 'mg.id', 'mq.sequence_number'])
        .where('m.ref', modelRef)
        .where(function () {
            // top level groups don't have participant_id
            this.where('mqe.id_participant', participant.get('id')).orWhere('mqe.id_participant', null)
        })
        .select(fields.concat(DB.raw('AVG(mqe.level) as average_level, SUM(mqe.level) as sum_level')))
        .groupBy(groupByFields)

        // returns tree with averages per group
        .then((rows) => buildModelTree(rows, function (questions, group) {
            if (questions.length > 0) {
                group.sum_level = questions.reduce(function (v, p) {
                    return v + p.sum_level;
                }, 0);
                group.average_level = Math.round(questions.reduce(function (v, p) {
                        return v + p.average_level;
                    }, 0) / questions.length);
            }
        }))

        // calculate averages for top_level groups
        .then((groups) => groups.map((group) => {
            if (group.data.length > 0) {
                group.sum_level = group.data.reduce(function (v, p) {
                    return v + p.sum_level;
                }, 0);
                group.average_level = Math.round(group.data.reduce(function (v, p) {
                        return v + p.average_level;
                    }, 0) / group.data.length);
            }
            return group
        }))
        ;
}


router.get('/development_model/:lang/:ref/:id_participant', isLoggedIn, function (req, res, next) {

    req.user.connectedParticipant(req.params.id_participant, ['ADMIN', 'EDITOR', 'VIEWER'])
        .then((participant) => {
            if (!participant) {
                res.status(404).send();
            } else {
                retrievePopulatedDevelopmentModel(req.params.ref, participant.get('id'), req.user.get('id'))
                    .then(model => {
                        if (model.length > 0) {
                            res.send(model);
                        } else {
                            res.status(404).send();
                        }
                    });
            }
        }).catch(next);

});


router.get('/development_model/:lang/:ref/:id_participant/summary', isLoggedIn, function (req, res, next) {

    req.user.connectedParticipant(req.params.id_participant, ['ADMIN', 'EDITOR', 'TERAPEUT', 'VIEWER'])
        .then((participant) => {
            if (!participant) {
                res.status(404).send();
            } else {
                getModelSummary(req.params.ref, participant).then((model) => {
                    res.send(model);
                });
            }
        }).catch(next);
});


router.post('/development_model/:lang/:ref/:id_participant', isLoggedIn, function (req, res, next) {

    req.user.connectedParticipant(req.params.id_participant, ['ADMIN', 'EDITOR', 'TERAPEUT'])
        .then((participant) => {

        if (!participant) {
            res.status(404);
        } else {
            let verifiedParticipantId = participant.get('id');
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
                        e.level = req.body.current_level.split(':')[1];
                        return DB('model_question_eval').update(e).where({id: e.id});
                    } else {
                        evaluation.level = req.body.current_level.split(':')[1];
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
