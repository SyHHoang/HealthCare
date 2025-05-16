import express from 'express';
import {
  requestVerification,
  getVerificationRequests,
  handleVerificationRequest,
  getDoctorVerificationRequest,
  getDoctorVerificationDetails
} from '../controllers/verificationController.js';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';
const router = express.Router();

// Routes cho bác sĩ
router.post('/request', authenticateDoctor, requestVerification);
router.get('/doctor/request', authenticateDoctor, getDoctorVerificationRequest);
router.get('/doctor/verification-details', authenticateDoctor, getDoctorVerificationDetails);

// Routes cho admin
router.get('/requests', authenticateToken, isAdmin, getVerificationRequests);
router.put('/handle-requests/:requestId', authenticateToken, isAdmin, handleVerificationRequest);

export default router; 