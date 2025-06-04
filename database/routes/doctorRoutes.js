import express from 'express';
import { 
  register,
  login,
  forgotPassword,
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
    const { fcmToken } = req.body;
    const doctorId = req.doctor.id;
    const doctor = await Doctor.findById(doctorId);
    if (!fcmToken) {
      return res.status(400).json({ 
        success: false, 
        message: 'FCM token là bắt buộc' 
      });
    }

    // Kiểm tra nếu token đã tồn tại
    if (!doctor.fcmTokens.includes(fcmToken)) {
      // Thêm token mới vào mảng
      doctor.fcmTokens.push(fcmToken);
      await doctor.save();
      console.log(`Đã thêm FCM token mới cho bác sĩ ${doctor._id}`);
    }

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
    const { fcmToken } = req.body;
    const doctor = req.doctor;

    if (!fcmToken) {
      return res.status(400).json({ 
        success: false, 
        message: 'FCM token là bắt buộc' 
      });
    }

    // Xóa token khỏi mảng
    doctor.fcmTokens = doctor.fcmTokens.filter(token => token !== fcmToken);
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

export default router;