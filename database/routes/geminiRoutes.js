import express from 'express';
import geminiController from '../controllers/geminiController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Route gửi tin nhắn
router.post('/message', authenticateToken, geminiController.sendMessage);

export default router; 