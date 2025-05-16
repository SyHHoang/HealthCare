import express from 'express';
import { getFeaturedServices } from '../controllers/serviceController.js';

const router = express.Router();

// Route để lấy danh sách dịch vụ nổi bật
router.get('/featured', getFeaturedServices);

export default router; 