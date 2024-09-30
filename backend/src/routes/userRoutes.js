const express = require('express');

const { login, register, logout } = require('../controllers/userController');


const { createWalletandDID } = require('../credential/acapyRegister');
const { receiveConnection } = require('../credential/receiveConnection');
const { receiveOffer } = require('../credential/receiveOffer');
const { getAuthToken, storeCredential, getWalletData } = require('../credential/storeCredential');
const { receiveExistedCredential } = require('../credential/receiveExistedCredential');
const { deleteCredential } = require('../credential/deleteCredential');

const { generateQRCode, fetchQRCodesByUserId, deleteQRCode, fetchCVByQRCode, searchQRCode } = require('../controllers/qrController');

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
    showDetailsQR,
    getCertifications,
    updateCertificationStatus,
    saveCVCertification
} = require('../controllers/cvController');

const { backdoorReset } = require('../controllers/backdoor');


const router = express.Router();


router.post('/backdoorReset', backdoorReset);


// Receive Credential fromIssuer
router.post('/createWalletandDID', createWalletandDID);
router.post('/receiveConnection', receiveConnection);
router.post('/receiveOffer', receiveOffer);
router.post('/getAuthToken', getAuthToken);
router.post('/storeCredential', storeCredential);
router.post('/getWalletData', getWalletData);
router.post('/receiveExistedCredential', receiveExistedCredential);
router.post('/deleteCredential', deleteCredential);


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

router.post('/saveCVCertification', saveCVCertification);
router.get('/getCertifications', getCertifications);
router.post('/updateCertificationStatus', updateCertificationStatus);

router.post('/saveCVQuali', saveCVQuali);
router.get('/getCVQualiInfo', getCVQualiInfo);

router.post('/showDetails', showDetails);
router.post('/showDetailsQR', showDetailsQR);


router.post('/generateQRCode', generateQRCode); // Route to generate a QR code
router.post('/fetchQRCodesByUserId', fetchQRCodesByUserId); // Route to fetch QR codes by account ID
router.post('/deleteQRCode', deleteQRCode);
router.post('/fetchCVByQRCode', fetchCVByQRCode);
router.post('/search-qrcode', searchQRCode);



module.exports = router;


