import {DatabaseORM} from '../database';
import  Organization from './organization'

export default DatabaseORM.Model.extend({
    tableName: 'resource',

    organization: function () {
        return this.hasOne(Organization, 'id_organization',  'id');
    }
})
