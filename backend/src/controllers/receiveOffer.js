const axios = require('axios');
const sql = require('mssql');
const { getAuthToken, getWalletData } = require('./receiveConnection'); // Import functions from receiveConnection.js

async function receiveOffer(req) {
    try {
        // Extract the attributes and holder details from the request body
        const { holder, attributes } = req.body; // Include holder to fetch wallet data

        // Step 1: Get wallet data for the user
        const walletData = await getWalletData(holder);
        if (!walletData) {
            throw new Error(`Wallet not found for holder: ${holder}`);
        }

        // Step 2: Get JWT token for the user's wallet
        const jwtToken = await getAuthToken(walletData.wallet_id);
        
        // Fetch all credential offers from the ACA-Py agent (holder's side)
        const recordsResponse = await axios.get(
            'http://localhost:7011/issue-credential-2.0/records',
            {
                headers: {
                    Authorization: `Bearer ${jwtToken}`,  // Use the retrieved JWT token
                    'Content-Type': 'application/json'
                }
            }
        );

        // Declare 'records' outside the 'if' block so it can be used globally in the function
        let records = [];
        console.log("Fetched All records: ", recordsResponse);

        // Check if the response structure is valid and extract 'results'
        if (recordsResponse && recordsResponse.data && recordsResponse.data.results) {
            records = recordsResponse.data.results; // Fetch the list of credential exchange records
            console.log("Fetched records: ", records);
        } else {
            console.log("No records found or incorrect response structure.");
        }

        // Check if records exist and get the first record
        if (records.length === 0) {
            return res.status(201).json({ message: 'No credential offers found.' });
        }
console.log("\n\n\n\n\n\n\n fk \n\n\n\n\n\n");
        const firstRecord = records[0]; // Get the first record
        console.log('First record:', firstRecord);

        const credExId = firstRecord.cred_ex_record.cred_ex_id; // Extract the credential exchange ID
        
        console.log("credExId:    \n\n" +credExId);


        console.log("Store Done");

        console.log(jwtToken);

        // After fetching the credential records
        const credentialRecordResponse = await axios.get(
            `http://localhost:7011/credentials`,
            {
                headers: {
                    Authorization: `Bearer ${jwtToken}`,
                    'Content-Type': 'application/json'
                }
            }
        );
        console.log('Credential Record:', credentialRecordResponse.data);

        // Respond with success message and credential data
        res.status(200).json({
            message: "Credential offer accepted and stored successfully.",
            credentials: credentialRecordResponse.data.results  // Pass credentials to frontend
        });


    } catch (error) {
        console.error('Error processing credential offer:', error.message);
    }
}

async function sendMessage() {
    try {
        // Example: Call the external Node.js project endpoint
        const response = await axios.post(
            'http://localhost:5000/router/storeSuccess',  // Replace with the actual URL of the other Node.js project
            {Offer : "Success"}
        );
        console.log('Message sent successfully:', response.data);
    } catch (error) {
        console.error('Error sending message:', error.message);
    }
}

module.exports = { receiveOffer };
