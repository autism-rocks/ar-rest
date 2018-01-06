import {DatabaseORM} from '../database';
import  Organization from './organization'
import  Participant from './participant'

export default DatabaseORM.Model.extend({
    tableName: 'user',
    organizations: function () {
        return this.belongsToMany(Organization, 'user_organization', 'id_user',  'id_organization').withPivot(['role']);
    },

    participants: function () {
        return this.belongsToMany(Participant, 'user_participant', 'id_user',  'id_participant').withPivot(['role']);
    }
});
