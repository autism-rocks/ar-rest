import {Database} from '../database';

export default class User extends Database.Model {
    static get tableName() { return 'user'; }
}

Database.register(User);