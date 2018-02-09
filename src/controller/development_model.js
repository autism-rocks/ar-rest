import express from 'express';
import {DB} from '../database';
import isLoggedIn from '../context/isLoggedIn'
import _ from 'lodash';
import moment from 'moment';


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
        .leftJoin(DB.raw(`model_question_eval AS mqe_previous ON mqe_previous.id = (SELECT id FROM model_question_eval WHERE id_participant=? AND id_user=? AND confirmed=true AND id_model_question = mq.id ORDER BY date DESC limit 1)`, [participantId, userId]))
        .leftJoin(DB.raw(`model_question_eval AS mqe_current ON mqe_current.id = (SELECT id FROM model_question_eval WHERE id_participant=? AND id_user=? AND confirmed=false AND id_model_question = mq.id ORDER BY date DESC limit 1)`, [participantId, userId]))
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
            'mgl.description as group_description',
            'mq.id as question_id',
            'mq.ref as question_ref',
            'mg.scale as scale',
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
                            description: q.question_description,
                            previous_level: q.previous_level,
                            current_level: q.current_level !== null ? q.current_level : q.previous_level,
                            placeholder: q.current_level !== null ? false : true
                        };

                        subgroup.data.push(item)
                    });
                }

                function mapGroup(m) {
                    return {scale: m.scale}
                }

                data = buildModelTree(questions, attachQuestions, mapGroup);

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
function buildModelTree(questions, attach, map, parentGroupId = null, parentSequenceId = null) {
    let data = [];
    // build the group tree
    // this is a real mess. need to figure out a better way to build the tree...
    let questionsWithinGroup = _.uniqWith(questions.filter(q => q.group_parent_id == parentGroupId).map((q, i) => {
        let mappedGroup = map ? map(q) : q;
        mappedGroup._id = q.group_id;
        mappedGroup.ref = q.group_ref;
        mappedGroup.group = q.group;
        mappedGroup.open = true;
        return mappedGroup;
    }), _.isEqual);

    questionsWithinGroup.forEach((group, i) => {
        group.id = (parentSequenceId ? `${parentSequenceId}.` : '') + `${i + 1}`;
        group.data = buildModelTree(questions, attach, map, group._id, group.id);
        if (attach) {
            attach(questions.filter(q => q.group_id == group._id), group);
        }
        data.push(group);
    });

    return data;
}


/**
 * For a given development model, returns the group tree along with the average level
 * for a specific participantId
 *
 * @param modelRef
 * @param participantId
 * @param filters
 * @returns {Promise.<TResult>}
 */
function getModelSummary(modelRef, userId, participantId, date = new Date(), tx = DB) {
    let fields = [
        'ml.name',
        'm.ref',
        'mg.id as group_id',
        'mg.id_parent as group_parent_id',
        'mg.ref as group_ref',
        'mg.sequence_number as sequence',
        'mg.scoring as scoring',
        'mgl.name as group'];
    let groupByFields = ['mg.sequence_number', 'mg.id', 'mq.sequence_number', 'name', 'ref', 'group_id', 'group_parent_id', 'group_ref', 'sequence', 'scoring', 'group'];
    let query =  tx.from('model as m')
        .join('model_lang as ml', 'm.id', 'ml.id_model')
        .join('lang as l', 'ml.id_lang', 'l.id')
        .join('model_group as mg', 'm.id', 'mg.id_model')
        .join('model_group_lang as mgl', 'mg.id', 'mgl.id_model_group')
        .join('lang as mgll', 'mgl.id_lang', 'mgll.id')
        .leftJoin('model_question as mq', 'mq.id_model_group', 'mg.id')
        .leftJoin('model_question_lang as mql', 'mql.id_model_question', 'mq.id')
        .leftJoin('lang as mqll', 'mqll.id', 'mql.id_lang')
        .leftJoin(DB.raw(`model_question_eval AS mqe ON mqe.id = (SELECT id FROM model_question_eval WHERE id_model_question=mq.id AND id_participant=? AND id_user=? AND (date<=? OR date IS NULL) ORDER BY date DESC limit 1)`, [participantId, userId, date]))
        .orderBy(['mg.sequence_number', 'mg.id', 'mq.sequence_number'])
        .where('m.ref', modelRef)
        .where(function () {
            // top level groups don't have participant_id
            this.where('mqe.id_participant', participantId).orWhere('mqe.id_participant', null)
        })
        .select(fields.concat(DB.raw('AVG(mqe.level) as average_level, SUM(mqe.level) as sum_level')))
        .groupBy(groupByFields);

    function calculateAndAttachScoring(questions, group) {
        if (questions.length > 0) {
            group.sum_level = questions.reduce(function (v, p) {
                return v + p.sum_level;
            }, 0);
            group.average_level = Math.round(questions.reduce(function (v, p) {
                        return v + p.average_level;
                    }, 0) / questions.length * 10) / 10;

            if (group.scoring) {
                try {
                    group.score = null;
                    // group.scoring = JSON.parse(group.scoring);
                    for (let i = 0; i < group.scoring.length; i++) {
                        if (group.sum_level >= group.scoring[i][1][0] && group.sum_level <= group.scoring[i][1][1]) {
                            group.score = group.scoring[i][0];
                        }
                    }
                } catch (e) {
                    console.log(e);
                    group.score = null;
                }
            }
        }
        return group;
    }

    function mapGroup(g) {
        return {scoring: g.scoring ? JSON.parse(g.scoring) : null};
    }


    return query
    // returns tree with averages per group
        .then((rows) => buildModelTree(rows, calculateAndAttachScoring, mapGroup))
        // calculate averages for top_level groups
        .then((groups) => groups.map((group) => {
            return calculateAndAttachScoring(group.data, group)
        }));
}


/**
 * For a given development model, returns the current scoring breaking the data by the
 * parameters needed
 *
 * @param modelRef
 * @param participantId
 * @param filters
 * @returns {Promise.<TResult>}
 */
function getModelScore(modelRef, participantId, userId = null, date = new Date(), groupByUser = false) {

    let selectFields = ['ml.name',
        'm.ref',
        'mg.id as group_id',
        'mg.id_parent as group_parent_id',
        'mg.ref as group_ref',
        'mg.sequence_number as sequence',
        'mgl.name as group',
        DB.raw('AVG(mgs.average_level) as average_level'),
        DB.raw('AVG(mgs.score) as average_score'),
        DB.raw('AVG(mgs.sum_level) as average_sum_level')
    ];

    let groupByFields = ['name',
        'ref',
        'group_id',
        'group_parent_id',
        'group_ref',
        'sequence',
        'group'];


    let query = DB.from('model as m')
        .join('model_lang as ml', 'm.id', 'ml.id_model')
        .join('lang as l', 'ml.id_lang', 'l.id')
        .join('model_group as mg', 'm.id', 'mg.id_model')
        .join('model_group_lang as mgl', 'mg.id', 'mgl.id_model_group')
        .join('lang as mgll', 'mgl.id_lang', 'mgll.id')
        // this crazy join is so that we can select the most recent date of each score/user/model_group/participant
        .leftJoin(DB.raw(`(SELECT m1.* FROM model_group_score m1 JOIN 
                            (SELECT id_user, id_model_group, id_participant, MAX(date) as date 
                                FROM model_group_score WHERE date <= ? 
                                GROUP BY id_user, id_model_group, id_participant) as m2  
                            ON 
                                m1.id_user=m2.id_user 
                                AND m1.id_model_group=m2.id_model_group 
                                AND m1.id_participant=m2.id_participant 
                                AND m1.date=m2.date) as mgs`, [date]), (qb) => {
            qb.on('mgs.id_model_group', 'mg.id').andOn('mgs.id_participant', participantId)
        })
        .orderBy(['mg.sequence_number', 'mg.id'])
        .where('m.ref', modelRef);

    if (groupByUser) {
        query.join('user as u', 'mgs.id_user', 'u.id');
        selectFields.push('u.id as user_id');
        selectFields.push('u.name as user_name');
        groupByFields.push('user_id');
        groupByFields.push('user_name');
    }

    if (userId) {
        query.where('u.id', userId);
    }

    query.select(selectFields).groupBy(groupByFields);

    function mapGroup(g) {
        return {
            score: g.average_score,
            average_level: g.average_level,
            sum_level: g.average_sum_level
        };
    }

    return query.then((rows) => {
        let rowGroups = [];

        if (groupByUser) {
            let users = _.uniqBy(rows.map(r => {
                return {name: r.user_name, id: r.user_id}
            }).filter((r) => r.id), 'id');
            users.forEach((user) => {
                rowGroups.push({
                    label: user,
                    data: buildModelTree(rows.filter((r) => r.user_id == user.id), null, mapGroup)
                })
            })
        } else {
            rowGroups.push({
                label: 'ALL_USERS',
                data: buildModelTree(rows, null, mapGroup)
            })
        }

        return rowGroups;
    });

}

/**
 * Takes the current unconfirmed values in the model_question_eval table and confirms them by setting
 * a fixed date. Data within the target date will be overriten.
 * After confirming the values, it retrives the model summary and creates/updates the model_group_score whichs makes it
 * easier to then retrive scoring information
 *
 * @param modelRef
 * @param userId
 * @param participantId
 * @param date
 */
function recordEvaluationStep(modelRef, userId, participantId, date = new Date()) {
    return DB.transaction((tx) => tx.select('mqe.id')

        // get all model_question_eval records to delete wihtin the transaction
            .from('model_question_eval as mqe')
            .join('model_question as mq', 'mq.id', 'mqe.id_model_question')
            .join('model_group as mg', 'mg.id', 'mq.id_model_group')
            .join('model as m', 'm.id', 'mg.id_model')
            .leftJoin('model_question_eval as mqe1', (qb) => {
                qb.on('mqe1.id_model_question', 'mqe.id_model_question')
                    .andOn(DB.raw('mqe1.date IS NULL'))
            })
            .where({
                'mqe.id_user': userId,
                'mqe.id_participant': participantId,
                'm.ref': modelRef,
                'mqe.date': moment(date).format('YYYY-MM-DD'),
                'mqe.confirmed': true
            })
            .where(DB.raw('mqe1.id IS NOT NULL'))
            .then(ids => ids.map((r) => r.id))

            // delete previous questions that are meant to be overriden with the new values
            .then(ids => tx('model_question_eval').whereIn('id', ids).delete())

            // update the new rows by setting a target date and confirmation to true
            .then(() => {
                return tx('model_question_eval').update({
                    confirmed: true,
                    date: date
                }).where({
                    confirmed: false,
                    id_user: userId,
                    id_participant: participantId
                })
            })

            // delete any existent data in the model score
            .then(() => tx('model_group_score as mgs')
                .join('model_group as mg', 'mg.id', 'mgs.id_model_group')
                .join('model as m', 'm.id', 'mg.id_model')
                .where({
                    'mgs.id_user': userId,
                    'mgs.id_participant': participantId,
                    'm.ref': modelRef,
                    'mgs.date': moment(date).format('YYYY-MM-DD')
                }).select('mgs.id'))
            .then(ids => ids.map((r) => r.id))
            .then(ids => tx('model_group_score').whereIn('id', ids).delete())

            // get the summary and insert the current score in the model_group_score table
            .then(() => getModelSummary(modelRef, userId, participantId, date, tx))
            .then((model) => {
                let insert = [];

                function traverse(model) {
                    for (let i = 0; i < model.length; i++) {
                        if (model[i].data && model[i].data.length > 0) {
                            traverse(model[i].data);
                        }
                        insert.push({
                            date: moment(date).format('YYYY-MM-DD'),
                            id_user: userId,
                            id_participant: participantId,
                            id_model_group: model[i]._id,
                            score: model[i].score,
                            average_level: model[i].average_level,
                            sum_level: model[i].sum_level,
                        })
                    }
                }

                traverse(model);

                return tx.insert(insert).into('model_group_score');
            })
    )
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
                getModelSummary(req.params.ref, req.user.get('id'), participant.get('id'), req.query.date).then((model) => {
                    res.send(model);
                });
            }
        }).catch(next);
});

router.get('/development_model/:lang/:ref/:id_participant/scoring', isLoggedIn, function (req, res, next) {

    req.user.connectedParticipant(req.params.id_participant, ['ADMIN', 'EDITOR', 'TERAPEUT', 'VIEWER'])
        .then((participant) => {
            if (!participant) {
                res.status(404).send();
            } else {
                getModelScore(req.params.ref,
                    participant.get('id'),
                    req.query.userId,
                    req.query.date ? moment(req.query.date).toDate() : new Date(),
                    req.query.groupByUser
                ).then((model) => {
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
            return recordEvaluationStep(req.params.ref, req.user.get('id'), verifiedParticipantId, date)
                .then(() => {
                    res.send({status: 'SUCCESS', message: 'MODEL_PROGRESS_RECORDED'})
                });
        }

    }).catch(next);

});


export default function () {
    return router;
};
