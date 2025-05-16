import express from 'express';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { addDoctor, getConsultationList, removeDoctor, getConsultationListUser, checkConsultation, bookConsultation, checkDuplicateConsultation, getConsultationHistory, getDoctorConsultationHistory } from '../controllers/consultationListController.js';
import { authenticateDoctor  } from '../middlewares/doctorAuthMiddleware.js';
const router = express.Router();

// Thêm bác sĩ vào danh sách tư vấn
router.post('/add', authenticateToken, addDoctor);
router.get('/check', authenticateToken, checkConsultation);
// Lấy danh sách bác sĩ tư vấn
router.get('/list', authenticateToken, getConsultationList);
router.get('/list/user', authenticateDoctor , getConsultationListUser);
// Xóa bác sĩ khỏi danh sách tư vấn
router.delete('/remove/:doctorId', authenticateToken, removeDoctor);
// Đặt lịch tư vấn
router.post('/book', authenticateToken, bookConsultation);
// Kiểm tra lịch trùng
router.post('/check-duplicate', authenticateToken, checkDuplicateConsultation);
// Lấy lịch sử cuộc hẹn của người dùng
router.get('/history', authenticateToken, getConsultationHistory);
// Lấy lịch sử cuộc hẹn của bác sĩ
router.get('/doctor/history', authenticateDoctor, getDoctorConsultationHistory);

export default router; 