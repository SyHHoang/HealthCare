import express from 'express';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';
import { startVideoCall, endVideoCall } from '../controllers/videoCallController.js';

const router = express.Router();

// Route cho người dùng
router.post('/start', authenticateToken, startVideoCall);
router.post('/end', authenticateToken, endVideoCall);

// Route cho bác sĩ
router.post('/doctor/start', authenticateDoctor, startVideoCall);
router.post('/doctor/end', authenticateDoctor, endVideoCall);

export default router; 