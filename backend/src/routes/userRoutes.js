const express = require('express');
const {
    login,
    register,
    logout,
} = require('../controllers/userController');

const { createWalletandDID } = require('../controllers/acapyRegister');
const { receiveConnection } = require('../controllers/receiveConnection');
const { receiveOffer } = require('../controllers/receiveOffer');
const { getAuthToken, storeCredential, getWalletData } = require('../controllers/storeCredential');
const {receiveExistedCredential} = require('../controllers/receiveExistedCredential');
const {deleteCredential} = require('../controllers/deleteCredential');


const { generateQRCode, fetchQRCodesByUserId, deleteQRCode,fetchCVByQRCode } = require('../controllers/qrController');
// receive dailog
// const { checkForNewCredentials } = require('../controllers/credentialController');


const {
    saveCVProfile,
    getCVProfile,
    saveCVEducation,
    getCVEducation,
    saveCVWork,
    getCVWork,
    saveCVQuali,
    getCVQualiInfo,
    saveProfile,
    getProfile,
    getAccountEmail,
    getPersonDetails,
    deleteCVEducation,
    deleteCVWork,
    saveCVSkill,
    getCVSkill,
    deleteCVSkill,
    showDetails,
    getCertifications,
    updateCertificationStatus
} = require('../controllers/cvController');

/*const {
    generateQRCode,
} = require('../controllers/qrController');*/  // Uncomment to include QR code functionality

const router = express.Router();

// Receive Credential fromIssuer
router.post('/createWalletandDID', createWalletandDID);
router.post('/receiveConnection', receiveConnection);
router.post('/receiveOffer', receiveOffer);
router.post('/getAuthToken', getAuthToken);
router.post('/storeCredential', storeCredential);
router.post('/getWalletData', getWalletData);
router.post('/receiveExistedCredential', receiveExistedCredential);

router.post('/deleteCredential', deleteCredential);
// Add this route for checking credentials
// router.get('/receiveCredentials/:email', checkForNewCredentials);



// User-related routes
router.post('/login', login);
router.post('/register', register);
router.post('/logout', logout);

// Profile routes
router.post('/saveProfile', saveProfile);
router.get('/getProfile', getProfile);
router.get('/getAccountEmail', getAccountEmail);
router.get('/getPersonDetails', getPersonDetails);

// CV Profile
router.post('/saveCVProfile', saveCVProfile);
router.get('/getCVProfile', getCVProfile);

// CV Education
router.post('/saveCVEducation', saveCVEducation);
router.get('/getCVEducation', getCVEducation);
router.post('/deleteCVEducation', deleteCVEducation);

// CV Work
router.post('/saveCVWork', saveCVWork);
router.get('/getCVWork', getCVWork);
router.post('/deleteCVWork', deleteCVWork);

// CV Soft Skill
router.post('/saveCVSkill', saveCVSkill);
router.get('/getCVSkill', getCVSkill);
router.post('/deleteCVSkill', deleteCVSkill);

// CV-related routes
router.get('/getCertifications', getCertifications);
router.post('/updateCertificationStatus', updateCertificationStatus);



router.post('/saveCVQuali', saveCVQuali);
router.get('/getCVQualiInfo', getCVQualiInfo);

router.post('/showDetails', showDetails);

router.post('/generateQRCode', generateQRCode); // Route to generate a QR code
router.post('/fetchQRCodesByUserId', fetchQRCodesByUserId); // Route to fetch QR codes by account ID
router.post('/deleteQRCode', deleteQRCode); 
router.post('/fetchCVByQRCode', fetchCVByQRCode); 

fetchCVByQRCode
module.exports = router;


