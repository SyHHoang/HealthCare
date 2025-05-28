import express from 'express';
import { 
  createNotification, 
  createBulkNotifications,
  getNotifications, 
  markAsRead, 
  markAllAsRead, 
  deleteNotification,
  getDoctorNotifications,
  markDoctorNotificationAsRead,
  markAllDoctorNotificationsAsRead,
  deleteDoctorNotification
} from '../controllers/notificationController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';

const router = express.Router();

// Tạo thông báo mới
router.post('/', authenticateToken, createNotification);

// Tạo nhiều thông báo cùng lúc
router.post('/bulk', authenticateToken, createBulkNotifications);

// Lấy danh sách thông báo cho user
router.get('/', authenticateToken, getNotifications);

// Lấy danh sách thông báo cho bác sĩ
router.get('/doctor', authenticateDoctor, getDoctorNotifications);

// Đánh dấu thông báo đã đọc cho user
router.patch('/:id/read', authenticateToken, markAsRead);

// Đánh dấu tất cả thông báo đã đọc cho user
router.patch('/read-all', authenticateToken, markAllAsRead);

// Xóa thông báo cho user
router.delete('/:id', authenticateToken, deleteNotification);

// Đánh dấu thông báo đã đọc cho bác sĩ
router.patch('/doctor/:id/read', authenticateDoctor, markDoctorNotificationAsRead);

// Đánh dấu tất cả thông báo đã đọc cho bác sĩ
router.patch('/doctor/read-all', authenticateDoctor, markAllDoctorNotificationsAsRead);

// Xóa thông báo cho bác sĩ
router.delete('/doctor/:id', authenticateDoctor, deleteDoctorNotification);

export default router; 