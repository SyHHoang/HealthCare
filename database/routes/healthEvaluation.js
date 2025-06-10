import express from 'express';
import healthEvaluationController from '../controllers/healthEvaluationController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Route để đánh giá sức khỏe
router.post('/evaluate', authenticateToken, healthEvaluationController.evaluateHealth);

export default router; 