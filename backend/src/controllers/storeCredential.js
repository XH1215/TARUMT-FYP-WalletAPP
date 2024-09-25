const axios = require('axios');
const sql = require('mssql');
const dbConfig = require('../config/dbConfigWallet');
const acaPyBaseUrl = 'http://localhost:7011';

// Initialize SQL connection pool
let poolPromise = sql.connect(dbConfig)
    .then(pool => {
        console.log('Connected to MSSQL');
        return pool;
    })
    .catch(err => {
        console.error('Database Connection Failed! Bad Config: ', err);
        process.exit(1);
    });

// Function to store the credential
async function storeCredential(credExId, jwtToken) {
    try {
        // Step 1: Accept the offer
        const acceptResponse = await axios.post(
            `http://localhost:7011/issue-credential-2.0/records/${credExId}/send-request`,
            {},
            {
                headers: {
                    Authorization: `Bearer ${jwtToken}`,  // Pass your JWT token for holder
                    'Content-Type': 'application/json'
                }
            }
        );
        console.log("Accept:    \n\n" + acceptResponse.data);

        const requestUrl = `http://localhost:7011/issue-credential-2.0/records/${credExId}/store`;
        console.log(requestUrl);

        // Wait for 5 seconds
        await wait(5000);

        // Step 2: Store the credential
        const storeResponse = await axios.post(
            requestUrl,
            {},
            {
                headers: {
                    Authorization: `Bearer ${jwtToken}`,  // Use the retrieved JWT token
                    'Content-Type': 'application/json'
                }
            }
        );
        console.log("Store Done");
        return storeResponse.data; // Return the store response if needed
    } catch (error) {
        console.error('Error storing credential:', error.message);
        throw new Error('Failed to store credential');
    }
}

// Function to wait for a specified number of milliseconds
function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Function to get Auth Token from ACA-Py
async function getAuthToken(req, res) {
    const { walletID } = req.body; // Expect walletID in request body

    if (!walletID) {
        return res.status(400).json({ error: "Wallet ID is required" });
    }

    try {
        const response = await axios.post(`${acaPyBaseUrl}/multitenancy/wallet/${walletID}/token`);

        if (response.data && response.data.token) {
            res.status(200).json({ token: response.data.token });
        } else {
            res.status(404).json({ error: 'Token not found in response' });
        }
    } catch (error) {
        console.error('Error getting auth token:', error.response ? error.response.data : error.message);
        res.status(500).send('Failed to get auth token');
    }
}

// Function to get Wallet Data from MSSQL database
async function getWalletData(req, res) {
    const { email } = req.body; // Expect email in request body

    if (!email) {
        return res.status(400).json({ error: "Email is required" });
    }

    try {
        const pool = await poolPromise;
        const walletDataResult = await pool.request()
            .input('Email_Address', sql.NVarChar(50), email)
            .query(`
                SELECT wallet_id, public_did 
                FROM Wallets 
                WHERE Email_Address = @Email_Address
            `);

        if (walletDataResult.recordset.length === 0) {
            return res.status(404).send('No wallet found for this email.');
        }

        const walletData = walletDataResult.recordset[0];
        res.status(200).json({ wallet: walletData });
    } catch (err) {
        console.error('Get Wallet Data Error:', err);
        res.status(500).send('Server error');
    }
}

// Export all the functions
module.exports = {
    storeCredential,
    getAuthToken,
    getWalletData,
};
