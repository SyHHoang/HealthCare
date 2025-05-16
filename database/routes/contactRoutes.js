import express from 'express';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';
import * as contactController from '../controllers/contactController.js';

const router = express.Router();

// Route public - gửi liên hệ
router.post('/', contactController.createContact);

// Routes admin - quản lý liên hệ
router.get('/admin', authenticateToken, isAdmin, contactController.getContacts);
router.get('/admin/:id', authenticateToken, isAdmin, contactController.getContactById);
router.patch('/admin/:id/status', authenticateToken, isAdmin, contactController.updateContactStatus);
router.delete('/admin/:id', authenticateToken, isAdmin, contactController.deleteContact);
router.post('/admin/:id/reply', authenticateToken, isAdmin, contactController.replyToContact);

export default router; 