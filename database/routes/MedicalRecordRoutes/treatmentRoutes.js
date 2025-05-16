import express from 'express';
const router = express.Router();
import { addTreatment, getUserTreatments, updateTreatment, deleteTreatment, DoctorgetUserTreatments } from '../../controllers/medicalRecordController/treatmentController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../../middlewares/doctorAuthMiddleware.js';

// Áp dụng middleware xác thực cho tất cả các routes


// Routes
router.post('/',authenticateToken, addTreatment);
router.get('/', authenticateToken, getUserTreatments);
router.put('/:id', authenticateToken, updateTreatment);
router.delete('/:id', authenticateToken, deleteTreatment);
router.get('/doctor/:id', authenticateDoctor, DoctorgetUserTreatments);
export default router; 