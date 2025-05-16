import express from 'express';
import { getDashboardStats } from '../controllers/adminController.js';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Route lấy thống kê cho dashboard
router.get('/dashboard/stats', authenticateToken, isAdmin, getDashboardStats);

export default router; 