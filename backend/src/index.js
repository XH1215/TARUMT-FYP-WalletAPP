const app = require('./app');
const port = process.env.PORT || 4000;

// Start server
app.listen(port, () => {
    console.log(`Server is running on http://192.168.1.9:${port}`);
});
