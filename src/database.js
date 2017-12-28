import knex from 'knex';
import KnexOrm from'knex-orm';

/**
 * Establish the Database connection
 */
export const Database = new KnexOrm(
    knex(require('../.config/database'))
);

