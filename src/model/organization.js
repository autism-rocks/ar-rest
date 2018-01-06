import {DatabaseORM} from '../database';
import  User from './user'

export default DatabaseORM.Model.extend({
    tableName: 'organization',
    users: function () {
        return this.belongsToMany(User, 'user_organization', 'id_organization',  'id_user').withPivot(['role']);
    }
})
