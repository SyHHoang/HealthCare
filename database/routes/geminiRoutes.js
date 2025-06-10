import express from 'express';
import geminiController from '../controllers/geminiController.js';
//import { authenticateToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Route khởi tạo chat
router.post('/initialize', geminiController.initializeChat);

// Route gửi tin nhắn
router.post('/message', geminiController.sendMessage);

// Route xóa lịch sử chat
router.delete('/clear', geminiController.clearChat);

export default router; 