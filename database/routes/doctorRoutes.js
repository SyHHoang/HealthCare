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

export default router;