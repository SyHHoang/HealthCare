import express from 'express';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import {
  searchDrugs,
  getDrugById,
  createDrug,
  updateDrug,
  deleteDrug
} from '../controllers/drugController.js';

const router = express.Router();

// Public routes
router.get('/search', searchDrugs);
router.get('/:id', getDrugById);

// Protected routes (admin only)
router.post('/', authenticateToken, createDrug);
router.put('/:id', authenticateToken, updateDrug);
router.delete('/:id', authenticateToken, deleteDrug);

export default router; 