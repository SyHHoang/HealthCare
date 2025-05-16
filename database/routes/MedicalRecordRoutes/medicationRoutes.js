import express from 'express';
const router = express.Router();
import { addMedication, getUserMedications, updateMedication, deleteMedication, DoctorgetUserMedications } from '../../controllers/medicalRecordController/medicationController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../../middlewares/doctorAuthMiddleware.js';

// Áp dụng middleware xác thực cho tất cả các routes


// Routes
router.post('/', authenticateToken, addMedication);
router.get('/', authenticateToken, getUserMedications);
router.put('/:id', authenticateToken, updateMedication);
router.delete('/:id', authenticateToken, deleteMedication);
router.get('/doctor/:id', authenticateDoctor, DoctorgetUserMedications);
export default router; 