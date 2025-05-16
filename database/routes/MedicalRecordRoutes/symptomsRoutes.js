import express from 'express';
import { addSymptom, getUserSymptoms, updateSymptom, deleteSymptom, getDoctorUserSymptoms } from '../../controllers/medicalRecordController/symptomsController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../../middlewares/doctorAuthMiddleware.js';

const router = express.Router();

// Route thêm triệu chứng mới
router.post('/', authenticateToken, addSymptom);

// Route lấy danh sách triệu chứng của người dùng
router.get('/', authenticateToken, getUserSymptoms);

// Route lấy danh sách triệu chứng của bệnh nhân (cho bác sĩ)
router.get('/doctor/:id', authenticateDoctor, getDoctorUserSymptoms);

// Route cập nhật triệu chứng
router.put('/:id', authenticateToken, updateSymptom);

// Route xóa triệu chứng
router.delete('/:id', authenticateToken, deleteSymptom);

export default router; 