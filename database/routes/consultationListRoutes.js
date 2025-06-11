import express from 'express';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { addDoctor, getConsultationList, removeDoctor, getConsultationListUser, checkConsultation, bookConsultation, checkDuplicateConsultation, getConsultationHistory, getDoctorConsultationHistory } from '../controllers/consultationListController.js';
import { authenticateDoctor  } from '../middlewares/doctorAuthMiddleware.js';
import Consultation from '../models/Consultation.js';
import ConsultationList from '../models/ConsultationList.js';
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
// Thống kê tổng số lượt tư vấn
router.get('/stats/summary', authenticateToken, async (req, res) => {
  try {
    const totalConsultations = await Consultation.countDocuments();
    res.json({ totalConsultations });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy tổng số lượt tư vấn', error: error.message });
  }
});
// Lấy số lịch hẹn hôm nay của bác sĩ
router.get('/doctor/today', authenticateDoctor, async (req, res) => {
  try {
    const doctorId = req.doctor.id;
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date();
    end.setHours(23, 59, 59, 999);

    const count = await Consultation.countDocuments({
      doctorId,
      consultationDate: { $gte: start, $lte: end }
    });

    res.json({ todayAppointments: count });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy số lịch hẹn hôm nay', error: error.message });
  }
});
// Lấy tổng số bệnh nhân của bác sĩ (dựa trên ConsultationList)
router.get('/doctor/patients', authenticateDoctor, async (req, res) => {
  try {
    const doctorId = req.doctor.id;
    const count = await ConsultationList.countDocuments({ doctorId });
    res.json({ totalPatients: count });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy tổng số bệnh nhân', error: error.message });
  }
});

export default router; 