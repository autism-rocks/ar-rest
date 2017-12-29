import knex from 'knex';
import Bookshelf from 'bookshelf';

export const DB = knex(require('../.config/database'));
export const DatabaseORM = new Bookshelf(DB);

