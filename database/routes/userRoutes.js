import express from "express";
import {getProfile, updateProfile, getAllUsers, deleteUser, updateUser, getId, getImageId, createUser, doctorGetUserProfile, getNotificationSettings, updateNotificationSettings } from "../controllers/userController.js";
import { authenticateToken, isAdmin } from "../middlewares/authMiddleware.js";
import { authenticateDoctor} from "../middlewares/doctorAuthMiddleware.js";
import User from '../models/User.js';

const router = express.Router();

// Public routes
router.get("/profile", authenticateToken, getProfile);
router.put("/profile", authenticateToken, updateProfile);
router.get("/id", authenticateToken, getId);
// Admin routes
router.get("/", authenticateToken, isAdmin, getAllUsers);
router.post("/admin/create", authenticateToken, isAdmin, createUser);
router.put("/admin/:id", authenticateToken, isAdmin, updateUser);
router.delete("/admin/:id", authenticateToken, isAdmin, deleteUser);
router.get("/imageId", authenticateToken, getImageId);

// Thêm route lấy tổng số bệnh nhân
router.get("/stats/total", authenticateToken, isAdmin, async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ isActive: true });
    const inactiveUsers = await User.countDocuments({ isActive: false });

    // Thống kê theo thời gian đăng ký
    const registrationStats = await User.aggregate([
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

    // Thống kê theo độ tuổi
    const ageStats = await User.aggregate([
      {
        $group: {
          _id: {
            $switch: {
              branches: [
                { case: { $lt: ['$age', 18] }, then: 'Dưới 18' },
                { case: { $lt: ['$age', 30] }, then: '18-29' },
                { case: { $lt: ['$age', 40] }, then: '30-39' },
                { case: { $lt: ['$age', 50] }, then: '40-49' },
                { case: { $lt: ['$age', 60] }, then: '50-59' }
              ],
              default: 'Trên 60'
            }
          },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { count: -1 }
      }
    ]);

    // Thống kê theo giới tính
    const genderStats = await User.aggregate([
      {
        $group: {
          _id: '$gender',
          count: { $sum: 1 }
        }
      }
    ]);

    res.json({
      totalUsers,
      activeUsers,
      inactiveUsers,
      registrationStats,
      ageStats,
      genderStats
    });
  } catch (error) {
    console.error('Lỗi khi lấy thống kê bệnh nhân:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// Doctor routes
router.get("/doctor/user/:id", authenticateDoctor, doctorGetUserProfile);

// Notification settings routes
router.get("/settings", authenticateToken, getNotificationSettings);
router.put("/settings", authenticateToken, updateNotificationSettings);

// Route cập nhật FCM token
router.post('/update-fcm-token', authenticateToken, async (req, res) => {
  try {
    const { fcmToken, platform = 'web' } = req.body;
    const userId = req.user.userId;
    // Tìm user và cập nhật FCM token
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Cập nhật token mới
    user.fcmTokens[platform] = fcmToken;
    await user.save();

    res.json({ success: true, message: 'FCM token updated successfully' });
  } catch (error) {
    console.error('Error updating FCM token:', error);
    res.status(500).json({ success: false, message: 'Error updating FCM token' });
  }
});

export default router;
