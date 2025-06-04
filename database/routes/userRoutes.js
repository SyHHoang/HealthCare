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
