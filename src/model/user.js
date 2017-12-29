import {DatabaseORM} from '../database';
import  Organization from './organization'
import  UserOrganization from './user_organization'

export default DatabaseORM.Model.extend({
    tableName: 'user',
    organizations: function () {
        return this.belongsToMany(Organization, 'user_organization', 'id_user',  'id_organization')
            // .through(UserOrganization, 'id', 'id_user', 'id', 'id_organization')
            .withPivot(['role']);
    }
});
