import express from 'express';
import {
  register,
  login,
  forgotPassword,
  resetDoctorPassword,
  testCreateDoctor,
  getProfile,
  updateProfile,
  changePassword,
  getAllDoctors,
  getDoctorsActive,
  updateDoctorStatus,
  updateAvatar,
  getPublicProfileDoctorById,
  getDoctorImageId,
  createDoctor,
  updateDoctor,
  deleteDoctor,
  getPublicDoctors,
  getSchedule,
  addWorkingTime,
  deleteWorkingTime,
  saveServices,
  getServices,
  getProfileForEdit,
  getFullDoctorInfo
} from '../controllers/doctorController.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';
import { upload } from '../utils/upload.js';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';
import { sendNotification } from '../config/firebase-config.js';
import Doctor from '../models/Doctor.js';
const router = express.Router();

// Public routes
router.post('/register', register);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetDoctorPassword); // Endpoint để fix lỗi double hash
router.post('/test-create', testCreateDoctor); // Endpoint để test tạo bác sĩ
router.get('/active/isActive', getDoctorsActive);
router.get('/getPublicDoctorProfile/:id', getPublicProfileDoctorById);

// Protected routes (yêu cầu đăng nhập bác sĩ)
router.get('/profile', authenticateDoctor, getProfile);
router.get('/profile/edit', authenticateDoctor, getProfileForEdit);
router.put('/profile', authenticateDoctor, updateProfile);
router.put('/change-password', authenticateDoctor, changePassword);
router.put('/status/:id', authenticateDoctor, updateDoctorStatus);
router.put('/avatar', authenticateDoctor, upload.single('avatar'), updateAvatar);
router.get('/image/info', authenticateDoctor, getDoctorImageId);

// Admin routes
router.get('/',authenticateToken, isAdmin, getAllDoctors);
router.post('/', upload.single('avatar'), createDoctor);
router.put('/:id', upload.single('avatar'), updateDoctor);
router.delete('/:id', deleteDoctor);

// Thêm route lấy thống kê bác sĩ
router.get('/stats/total', authenticateToken, isAdmin, async (req, res) => {
  try {
    const totalDoctors = await Doctor.countDocuments();
    const activeDoctors = await Doctor.countDocuments({ isActive: true });
    const inactiveDoctors = await Doctor.countDocuments({ isActive: false });
    const verifiedDoctors = await Doctor.countDocuments({ isVerified: true });
    const unverifiedDoctors = await Doctor.countDocuments({ isVerified: false });
    
    // Thống kê theo chuyên khoa
    const specialtyStats = await Doctor.aggregate([
      {
        $group: {
          _id: '$specialty',
          count: { $sum: 1 }
        }
      },
      {
        $sort: { count: -1 }
      }
    ]);

    // Thống kê theo thời gian đăng ký
    const registrationStats = await Doctor.aggregate([
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' }
          },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { '_id.year': -1, '_id.month': -1 }
      }
    ]);
    
    res.json({
      totalDoctors,
      activeDoctors,
      inactiveDoctors,
      verifiedDoctors,
      unverifiedDoctors,
      specialtyStats,
      registrationStats
    });
  } catch (error) {
    console.error('Lỗi khi lấy thống kê bác sĩ:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// Route công khai - không cần xác thực
router.get('/public', getPublicDoctors);

// Routes cho quản lý lịch làm việc
router.get('/schedule', authenticateDoctor, getSchedule);
router.post('/schedule', authenticateDoctor, addWorkingTime);
router.delete('/schedule/:day/:index', authenticateDoctor, deleteWorkingTime);
router.get('/services', authenticateDoctor, getServices);
router.post('/services', authenticateDoctor, saveServices);

// Thêm route mới để lấy toàn bộ thông tin bác sĩ
router.get('/full-info/:id', authenticateToken, isAdmin, getFullDoctorInfo);

// Cập nhật FCM token cho bác sĩ
router.post('/update-fcm-token', authenticateDoctor, async (req, res) => {
  try {
    const { fcmToken, platform = 'web' } = req.body;
    const doctorId = req.doctor.id;
    const doctor = await Doctor.findById(doctorId);
    if (!fcmToken) {
      return res.status(400).json({ 
        success: false, 
        message: 'FCM token là bắt buộc' 
      });
    }

    // Cập nhật token mới
    doctor.fcmTokens[platform] = fcmToken;
    await doctor.save();
    console.log(`Đã cập nhật FCM token mới cho bác sĩ ${doctor._id}`);

    res.json({ 
      success: true, 
      message: 'Cập nhật FCM token thành công',
      tokens: doctor.fcmTokens 
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật FCM token:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Lỗi khi cập nhật FCM token',
      error: error.message 
    });
  }
});

// Xóa FCM token của bác sĩ
router.delete('/remove-fcm-token', authenticateDoctor, async (req, res) => {
  try {
    const { platform = 'web' } = req.body;
    const doctor = req.doctor;

    // Xóa token bằng cách gán giá trị rỗng
    doctor.fcmTokens[platform] = '';
    await doctor.save();
    console.log(`Đã xóa FCM token khỏi bác sĩ ${doctor._id}`);

    res.json({ 
      success: true, 
      message: 'Xóa FCM token thành công',
      tokens: doctor.fcmTokens 
    });
  } catch (error) {
    console.error('Lỗi khi xóa FCM token:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Lỗi khi xóa FCM token',
      error: error.message 
    });
  }
});

// Gửi thông báo cho bác sĩ
router.post('/send-notification', authenticateDoctor, async (req, res) => {
  try {
    const { title, body, data } = req.body;
    const doctor = req.doctor;

    if (!doctor.fcmToken) {
      return res.status(400).json({ message: 'Bác sĩ chưa có FCM token' });
    }

    await sendNotification(doctor.fcmToken, title, body, data);
    res.json({ message: 'Gửi thông báo thành công' });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ message: 'Lỗi khi gửi thông báo' });
  }
});

// Routes cho cài đặt thông báo
router.get('/settings', authenticateDoctor, async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.doctor.id);
    if (!doctor) {
      return res.status(404).json({ message: 'Không tìm thấy bác sĩ' });
    }
    res.json({ 
      success: true,
      settings: { enabled: doctor.notificationsEnabled }
    });
  } catch (error) {
    console.error('Lỗi khi lấy cài đặt:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

router.put('/settings', authenticateDoctor, async (req, res) => {
  try {
    const { enabled } = req.body;

    const doctor = await Doctor.findById(req.doctor.id);
    if (!doctor) {
      return res.status(404).json({ message: 'Không tìm thấy bác sĩ' });
    }

    // Cập nhật cài đặt thông báo
    doctor.notificationsEnabled = enabled ?? doctor.notificationsEnabled;

    await doctor.save();

    res.json({
      success: true,
      message: 'Cập nhật cài đặt thông báo thành công',
      settings: { enabled: doctor.notificationsEnabled }
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật cài đặt:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Lỗi server khi cập nhật cài đặt thông báo' 
    });
  }
});

export default router;