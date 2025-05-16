
import express from 'express';
import { getAllHealthData, addHealthData, updateHealthData, deleteHealthData, DoctorgetAllHealthDataetAllHealthData } from '../../controllers/medicalRecordController/healthDataController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../../middlewares/doctorAuthMiddleware.js';
const router = express.Router();

// Áp dụng middleware xác thực cho tất cả các route


router.get('/', authenticateToken, getAllHealthData);
router.post('/', authenticateToken, addHealthData);
router.put('/:id', authenticateToken, updateHealthData);
router.delete('/:id', authenticateToken, deleteHealthData); 
router.get('/doctor/:id', authenticateDoctor, DoctorgetAllHealthDataetAllHealthData);
export default router;