/*
A Collaborative Creation:
CHIN KAH FUI
CHIN XUAN HONG
OLIVIA HUANG SI HAN
LIM CHU QING
*/

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const userRoutes = require('./routes/userRoutes');

const app = express();

// Middleware
app.use(cors()); // Enable CORS

// Increase payload size limit for JSON bodies (e.g., for handling large files or base64-encoded images)
app.use(bodyParser.json({ limit: '20mb' })); // Adjust the limit based on your needs
app.use(bodyParser.urlencoded({ limit: '20mb', extended: true })); // For URL-encoded form data

// Route handling
app.use('/api', userRoutes);

// Root route for testing
app.get('/', (req, res) => {
    res.send('Welcome to the API');
});

module.exports = app;
