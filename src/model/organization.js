import {DatabaseORM} from '../database';
import  User from './user'
import  Participant from './participant'
import  Resource from './resource'

export default DatabaseORM.Model.extend({
    tableName: 'organization',

    users: function () {
        return this.belongsToMany(User, 'user_organization', 'id_organization',  'id_user').withPivot(['role']);
    },

    participants: function () {
        return this.belongsToMany(Participant, 'organization_participant', 'id_organization',  'id_participant').withPivot(['role']);
    },

    resources: function() {
        return this.hasMany(Resource, 'id_organization', 'id');
    }
})
