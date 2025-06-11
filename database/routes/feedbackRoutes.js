import express from 'express';
import { getFeedbacks, createFeedback, deleteFeedback, getTopFeedbacks, getFeedbackSummary } from '../controllers/feedbackController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { isAdmin } from '../middlewares/authMiddleware.js';
const router = express.Router();
router.get('/', authenticateToken, isAdmin, getFeedbacks);
router.get('/top', getTopFeedbacks);
router.post('/', authenticateToken, createFeedback);
router.delete('/:id', authenticateToken, isAdmin, deleteFeedback);
router.get('/stats/summary', authenticateToken, isAdmin, getFeedbackSummary);

export default router;
