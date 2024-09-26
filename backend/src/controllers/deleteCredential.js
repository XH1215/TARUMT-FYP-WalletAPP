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

// Helper function to wait for a specified number of milliseconds
function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Function to delete the credential (modified to take data from req.body)
const deleteCredential = async (req, res) => {
    const { credExId, jwtToken } = req.body; // Extract credExId and jwtToken from request body

    // Check if both credExId and jwtToken are provided
    if (!credExId || !jwtToken) {
        return res.status(400).json({ error: "credExId and jwtToken are required" });
    }

    try {
        console.log("Step 1: Received credExId and jwtToken from request body");
        console.log("credExId: ", credExId);
        console.log("jwtToken: ", jwtToken);

        // Step 2: Delete the credential
        const requestUrl = `http://localhost:7011/issue-credential-2.0/records/${credExId}`;
        console.log("Deleting credential at: ", requestUrl);

        // Wait for 2 seconds (if needed)
        await wait(5000);

        const deleteResponse = await axios.delete(
            requestUrl,
            {
                headers: {
                    Authorization: `Bearer ${jwtToken}`,  // Use the JWT token from the request body
                    'Content-Type': 'application/json'
                }
            }
        );

        console.log("Credential deleted successfully: ", deleteResponse.data);

        // Send success response back to the client
        return res.status(200).json({
            message: "Credential deleted successfully",
            data: deleteResponse.data
        });

    } catch (error) {
        console.error('Error deleting credential:', error.message);
        return res.status(500).json({ error: 'Failed to delete credential' });
    }
};

// Export the deleteCredential function
module.exports = {
    deleteCredential
};
