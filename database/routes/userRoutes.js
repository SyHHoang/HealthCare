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
    const { fcmToken } = req.body;
    const userId = req.user.userId;

    // Cập nhật FCM token cho user
    await User.findByIdAndUpdate(userId, { fcmToken });

    res.json({ success: true, message: 'FCM token updated successfully' });
  } catch (error) {
    console.error('Error updating FCM token:', error);
    res.status(500).json({ success: false, message: 'Error updating FCM token' });
  }
});

export default router;
