// const express = require('express');
// const bodyParser = require('body-parser');
// const cors = require('cors');
// const sainoRoutes = require('./sainoRoutes'); // Import SAINO routes

// const appSAINO = express();

// // Middleware
// appSAINO.use(cors()); // Enable CORS

// appSAINO.use(bodyParser.json({ limit: '10mb' })); // Adjust the limit based on your needs
// appSAINO.use(bodyParser.urlencoded({ limit: '10mb', extended: true })); // For URL-encoded form data

// // Route handling
// appSAINO.use('/api/saino', sainoRoutes); // SAINO API route

// // Root route for testing
// appSAINO.get('/', (req, res) => {
//     res.send('Welcome to the SAINO API');
// });

// module.exports = appSAINO;
