import express from 'express';
import {
  getAllOrderTypes,
  GetConsolutionID,
  GetQuantityAndExtendID,
  getOrderTypeById,
  updateOrderType
} from '../controllers/orderTypeController.js';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';

const router = express.Router();
// Public routes
router.get('/', authenticateToken, isAdmin, getAllOrderTypes);
router.get('/:id', getOrderTypeById);
router.get('/getConsolution',GetConsolutionID);
router.get('/getQuantityAndExtend',GetQuantityAndExtendID);

// Protected routes (require authentication)
router.put('/:id', authenticateToken, isAdmin, updateOrderType);

export default router;
