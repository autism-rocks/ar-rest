module.exports = {
    'client': 'mysql',
    'pool': {
        'min': 3,
        'max': 20
    },
    'connection': {
        'port': 3306,
        'user': 'root',
        'password': '',
        'database': 'autismrocks'
    },
    'acquireConnectionTimeout': 2000,
    'timezone': 'UTC'
};