import {DatabaseORM} from '../database';
import  Organization from './organization'
import  Participant from './participant'
import _ from 'lodash'

export default DatabaseORM.Model.extend({
    tableName: 'user',

    organizations: function () {
        return this.belongsToMany(Organization, 'user_organization', 'id_user', 'id_organization').withPivot(['role']);
    },

    participants: function () {
        return this.belongsToMany(Participant, 'user_participant', 'id_user', 'id_participant').withPivot(['role']);
    },

    /**
     * Retrieves a participant that's connected to the current
     * user via a direct or indirect relationship
     *
     * @param participantId
     * @param roles
     */
    connectedParticipant(participantId, roles) {
        let self = this;
        return Promise.all([
            self.participants().query(qb => {
                qb.where('id_participant', participantId);
                if (roles) {
                    qb.whereIn('role', roles);
                }
            }).fetch(),
            self.organizations().fetch()
        ]).then(results => {
            let directParticipants = results[0]
            let organizations = results[1];
            if (directParticipants.length > 0) {
                return directParticipants.at(0);
            } else {
                return Promise.all(organizations.map(o => o.participants().query(qb => {
                        qb.where('id_participant', participantId);
                        if (roles) {
                            qb.whereIn('role', roles);
                        }
                    }).fetch()
                ))
                    .then(results => {
                        for(let i=0; i< results.length; i++) {
                            if (results[i].length > 0) {
                                return results[i].at(0);
                            }
                        }
                    })
            }
        })
    }

    //
    //
    // participantsThroughOrg: function () {
    //     let self = this;
    //     return Participant.collection().query((q) => {
    //         q.from('participant as p')
    //             .join('organization_participant as op', 'op.id_participant', 'p.id')
    //             .join('organization as o', 'op.id_organization', 'o.id')
    //             .join('user_organization as uo', 'uo.id_organization', 'o.id')
    //             .whereIn('op.role', ['EDITOR', 'VIEWER'])
    //             .whereIn('uo.role', ['ADMIN', 'HELPDESK', 'TERAPEUT'])
    //             .where('uo.id_user', self.get('id'))
    //             .select(['p.*', 'op.role as role']);
    //     });
    // },
    //
    //
    // participants: function() {
    //     return Promise.all([
    //         this.participantsDirect().fetch({columns: ['participant.*', 'role']}),
    //         this.participantsThroughOrg().fetch()
    //     ]).then((data) => {
    //         let result = Participant.collection();
    //         data[0].forEach(d => result.add(d.toJSON({omitPivot: true})));
    //         data[1].forEach(d => result.add(d.toJSON({omitPivot: true})));
    //         return result;
    //     })
    // }

    // participants: function () {
    //     let self = this;
    //     return Participant.collection().query((q) => {
    //         return q.from(subq => {
    //             subq.union(function () {
    //                     this.from('participant as p')
    //                         .join('organization_participant as op', 'op.id_participant', 'p.id')
    //                         .join('organization as o', 'op.id_organization', 'o.id')
    //                         .join('user_organization as uo', 'uo.id_organization', 'o.id')
    //                         .whereIn('op.role', ['EDITOR', 'VIEWER'])
    //                         .whereIn('uo.role', ['ADMIN', 'HELPDESK', 'TERAPEUT'])
    //                         .where('uo.id_user', self.get('id'))
    //                         .select(['p.*', 'op.id_participant', 'op.role'])
    //                 })
    //                 .union(function () {
    //                     this.from('participant')
    //                         .join('user_participant as up', 'up.id_participant', 'participant.id')
    //                         .where('up.id_user', self.get('id'))
    //                         .select(['participant.*', 'up.id_participant', 'up.role'])
    //                 })
    //                 .as('participant')
    //
    //         });
    //     });
    // }
});
