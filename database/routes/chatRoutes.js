import express from 'express';
import { createChat, getUserChats, getDoctorChats, sendMessage, getChatMessages, searchMessages, getChatImages } from '../controllers/chatController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';

const router = express.Router();

// Routes cho user
router.post('/create', authenticateToken, createChat);
router.get('/user', authenticateToken, getUserChats);
router.post('/Sendmessage', authenticateToken, sendMessage);
router.get('/messages/:chatId', authenticateToken, getChatMessages);
router.get('/search/:chatId', authenticateToken, searchMessages);
router.get('/images/:chatId', authenticateToken, getChatImages);

// Routes cho doctor
router.get('/doctor', authenticateDoctor, getDoctorChats);
router.post('/doctor/Sendmessage', authenticateDoctor, sendMessage);
router.get('/doctor/messages/:chatId', authenticateDoctor, getChatMessages);
router.get('/doctor/search/:chatId', authenticateDoctor, searchMessages);
router.get('/doctor/images/:chatId', authenticateDoctor, getChatImages);

export default router; 