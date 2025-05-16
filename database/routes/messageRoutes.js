import express from 'express';
import { sendMessage, getChatHistory, markAsRead, getUnreadMessages } from '../controllers/messageController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';

const router = express.Router();

// Routes cho cả user và doctor
router.post('/send', [authenticateToken, authenticateDoctor], sendMessage);
router.get('/history/:partnerId', [authenticateToken, authenticateDoctor], getChatHistory);
router.put('/read/:messageId', [authenticateToken, authenticateDoctor], markAsRead);
router.get('/unread', [authenticateToken, authenticateDoctor], getUnreadMessages);

export default router; 