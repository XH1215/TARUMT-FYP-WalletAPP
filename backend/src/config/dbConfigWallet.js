const sql = require('mssql');

const dbConfigWallet = {
    user: 'wallet',
    password: 'wallet123',
    server: '127.0.0.1',
    database: 'Wallet',
    options: {
        encrypt: true,
        trustServerCertificate: true,
        enableArithAbort: true,
        connectTimeout: 30000,
        requestTimeout: 30000,
    },
    port: 1433,
};

module.exports = dbConfigWallet;
