import express from 'express';
import { addPrescription, getUserPrescriptions, updatePrescription, deletePrescription, DoctorgetUserPrescriptions, DoctoraddPrescription } from '../../controllers/medicalRecordController/prescriptionController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../../middlewares/doctorAuthMiddleware.js';
const router = express.Router();

// Áp dụng middleware xác thực cho tất cả các route

// Route thêm đơn thuốc mới
router.post('/', authenticateToken, addPrescription);

// Route lấy danh sách đơn thuốc của người dùng
router.get('/', authenticateToken, getUserPrescriptions);

// Route cập nhật đơn thuốc
router.put('/:id', authenticateToken, updatePrescription);

// Route xóa đơn thuốc
router.delete('/:id', authenticateToken, deletePrescription);

router.post('/doctor', authenticateDoctor, DoctoraddPrescription);
router.get('/doctor/:id', authenticateDoctor, DoctorgetUserPrescriptions);
export default router; 