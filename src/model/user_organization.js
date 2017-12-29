import {DatabaseORM} from '../database';
import  Organization from './organization'
import  User from './user'

export default DatabaseORM.Model.extend({
    tableName: 'user_organization',
    idAttribute: 'aaaaa',

    // organization: function () {
    //     return this.hasMany(Organization, 'id_organization', 'id').fetch();
    // }
    // ,
    //
    // user: function () {
    //     return this.hasOne(User, 'id_user', 'id').fetch();
    // }
});