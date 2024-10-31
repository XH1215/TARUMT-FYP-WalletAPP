/*
A Collaborative Creation:
CHIN KAH FUI
CHIN XUAN HONG
OLIVIA HUANG SI HAN
LIM CHU QING
*/

const sql = require('mssql');
const dbConfigWallet = require('../config/dbConfigWallet');
let poolPromise = sql.connect(dbConfigWallet)
    .then(pool => {
        console.log('Connected to MSSQL');
        return pool;
    })
    .catch(err => {
        console.error('Database Connection Failed! Bad Config: ', err);
        process.exit(1);
    });


module.exports.backdoorReset = async (req, res) => {
    let transaction;
    try {
        const pool = await poolPromise;
        
        // Start a transaction
        transaction = pool.transaction();
        await transaction.begin();

        const request = transaction.request();

        // Disable all foreign key constraints
        await request.query('EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"');

        // Delete data from all tables
        await request.query(`
            DECLARE @sql NVARCHAR(MAX) = N'';
            SELECT @sql += 'DELETE FROM [' + TABLE_SCHEMA + '].[' + TABLE_NAME + ']; '
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_TYPE = 'BASE TABLE';
            EXEC sp_executesql @sql;
        `);

        // Re-enable all foreign key constraints
        await request.query('EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"');

        // Commit the transaction
        await transaction.commit();

        console.log('All tables in the database have been cleared.');
        return res.status(200).send('All records from all tables have been deleted successfully.');
    } catch (err) {
        console.error('Error resetting all tables:', err);

        // If an error occurs, rollback the transaction
        if (transaction) {
            await transaction.rollback();
        }

        return res.status(500).send('Error resetting tables.');
    }
};
