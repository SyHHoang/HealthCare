import express from 'express';
const router = express.Router();
import { addVaccination, getUserVaccinations, updateVaccination, deleteVaccination, DoctorgetUserVaccinations } from '../../controllers/medicalRecordController/vaccinationController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import {authenticateDoctor } from '../../middlewares/doctorAuthMiddleware.js';


// Thêm thông tin tiêm chủng mới
router.post('/', authenticateToken, addVaccination);

// Lấy lịch sử tiêm chủng của người dùng
router.get('/', authenticateToken, getUserVaccinations);

// Cập nhật thông tin tiêm chủng
router.put('/:id', authenticateToken, updateVaccination);

// Xóa thông tin tiêm chủng
router.delete('/:id', authenticateToken, deleteVaccination);
router.get('/doctor/:id', authenticateDoctor, DoctorgetUserVaccinations);
export default router;