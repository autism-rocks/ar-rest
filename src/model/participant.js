import {DatabaseORM} from '../database';
import  User from './user'

export default DatabaseORM.Model.extend({
    tableName: 'participant'
    // ,
    // users: function () {
    //     return this.belongsToMany(User).through(UserOrganization);
    // }
})
