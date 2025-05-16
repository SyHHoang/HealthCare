import express from 'express';
import { getAllLifestyles,addLifestyle,updateLifestyle,deleteLifestyle, DoctorgetAllLifestyles } from '../../controllers/medicalRecordController/lifestyleController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../../middlewares/doctorAuthMiddleware.js';
const router = express.Router();

// Áp dụng middleware xác thực cho tất cả các route

// Routes cho Lifestyle
router.get('/', authenticateToken, getAllLifestyles);
router.post('/', authenticateToken, addLifestyle);
router.put('/:id', authenticateToken, updateLifestyle);
router.delete('/:id', authenticateToken, deleteLifestyle);
router.get('/doctor/:id', authenticateDoctor, DoctorgetAllLifestyles);
export default router; 