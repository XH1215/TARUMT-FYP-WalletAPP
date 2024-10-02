const axios = require('axios');
const sql = require('mssql');
const { getAuthToken, getWalletData } = require('./receiveConnection'); // Import functions from receiveConnection.js
async function receiveExistedCredential(req, res) {
    try {
        // Extract the attributes and holder details from the request body
        const { holder } = req.body; // Include holder to fetch wallet data

        // Step 1: Get wallet data for the user
        const walletData = await getWalletData(holder);
        if (!walletData) {
            throw new Error(`Wallet not found for holder: ${holder}`);
        }

        // Step 2: Get JWT token for the user's wallet
        const jwtToken = await getAuthToken(walletData.wallet_id);

        // Step 3: Fetch credential records from the ACA-Py agent (holder's side)
        const credentialRecordResponse = await axios.get(
            `http://172.16.20.114:7011/credentials`,
            {
                headers: {
                    Authorization: `Bearer ${jwtToken}`,
                    'Content-Type': 'application/json'
                }
            }
        );

        console.log('Credential Record:', credentialRecordResponse.data);

        // Check if the 'results' array exists and if it's empty
        if (credentialRecordResponse.data.results && credentialRecordResponse.data.results.length > 0) {
            // There are credential records, return them with status code 200
            console.log("Credentials found.");

            res.status(200).json({
                message: "Credential offer accepted and stored successfully.",
                credentials: credentialRecordResponse.data.results  // Pass credentials to frontend
            });
        } else {
            // No credential records found, return status code 201
            console.log("No credential records found.");

            res.status(201).json({
                message: "No credential offers found."
            });
        }

    } catch (error) {
        console.error('Error processing credential offer:', error.message);
        // Send a 500 Internal Server Error response
        res.status(500).json({ message: "Error processing credential offer.", error: error.message });
    }
}


async function sendMessage() {
    try {
        // Example: Call the external Node.js project endpoint
        const response = await axios.post(
            'http://172.16.20.114:5000/router/storeSuccess',  // Replace with the actual URL of the other Node.js project
            { Offer: "Success" }
        );
        console.log('Message sent successfully:', response.data);
    } catch (error) {
        console.error('Error sending message:', error.message);
    }
}

module.exports = { receiveExistedCredential };
