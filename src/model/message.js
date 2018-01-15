import {DatabaseORM} from '../database';
import  Organization from './organization'
import  User from './user'
import  Resource from './resource'

export default DatabaseORM.Model.extend({
    tableName: 'message',

    organization: function () {
        return this.hasOne(Organization, 'id_organization',  'id');
    },

    fromUser: function () {
        return this.hasOne(User, 'id_user_from',  'id');
    },

    toUser: function () {
        return this.hasOne(User, 'id_user_to',  'id');
    },

    resources: function () {
        return this.belongsToMany(Resource, 'message_resource', 'id_message',  'id_resource');
    }
})
