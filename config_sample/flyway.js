module.exports = {
    url: 'jdbc:mysql://localhost:3306/',
    schemas: 'autismrocks',
    locations: 'filesystem:sql/migrations',
    user: 'root',
    password: '',
    sqlMigrationSuffix: '.sql'
};