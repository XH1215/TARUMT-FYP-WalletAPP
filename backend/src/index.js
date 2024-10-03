const app = require('./app');
const port = process.env.PORT || 4000;

// Start server
app.listen(port, () => {
    console.log(`Server is running on http://103.52.192.245:${port}`);
});
