import {DatabaseORM} from '../database';
import User from './user'
import Organization from './organization'

export default DatabaseORM.Model.extend({
    tableName: 'participant',

    users: function () {
        return this.belongsToMany(User, 'user_participant', 'id_participant',  'id_user').withPivot(['role']);
    },

    organizations: function () {
        return this.belongsToMany(Organization, 'organization_participant', 'id_participant',  'id_organization').withPivot(['role']);
    },

})
