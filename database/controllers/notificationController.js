import Notification from '../models/notificationModel.js';
import User from '../models/User.js';

// Tạo thông báo mới
export const createNotification = async (req, res) => {
  try {
    const { title, message, type, data, userId } = req.body;
    
    // Kiểm tra user tồn tại
    const user = await User.findById(userId || req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }

    const notification = new Notification({
      userId: userId || req.user.userId,
      title,
      message,
      type,
      data
    });

    await notification.save();
    
    // Gửi thông báo realtime qua socket
    const io = req.app.get('io');
    io.to(`user_${notification.userId}`).emit('new_notification', {
      _id: notification._id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      data: notification.data,
      read: notification.read,
      createdAt: notification.createdAt
    });

    res.status(201).json(notification);
  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).json({ message: 'Lỗi khi tạo thông báo' });
  }
};

// Tạo thông báo cho nhiều người dùng
export const createBulkNotifications = async (req, res) => {
  try {
    const { notifications } = req.body;
    
    const createdNotifications = await Notification.insertMany(notifications);
    
    // Gửi thông báo realtime cho từng người dùng
    const io = req.app.get('io');
    createdNotifications.forEach(notification => {
      io.to(`user_${notification.userId}`).emit('new_notification', {
        _id: notification._id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        data: notification.data,
        read: notification.read,
        createdAt: notification.createdAt
      });
    });

    res.status(201).json(createdNotifications);
  } catch (error) {
    console.error('Error creating bulk notifications:', error);
    res.status(500).json({ message: 'Lỗi khi tạo thông báo hàng loạt' });
  }
};

// Lấy danh sách thông báo
export const getNotifications = async (req, res) => {
  try {
    
    let query = { userId: req.user.userId || req.doctor.id };
    console.log("------------------------------------------query",query);
    // Nếu là admin, có thể lấy thông báo của tất cả user
    const notifications = await Notification.find(query)
      .limit(50);
    console.log("------------------------------------------notifications",notifications);
    res.json(notifications);
  } catch (error) {
    console.error('Error getting notifications:', error);
    res.status(500).json({ message: 'Lỗi khi lấy thông báo' });
  }
};

// Đánh dấu thông báo đã đọc
export const markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.userId },
      { read: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: 'Không tìm thấy thông báo' });
    }

    res.json(notification);
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: 'Lỗi khi đánh dấu thông báo đã đọc' });
  }
};

// Đánh dấu tất cả thông báo đã đọc
export const markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.user.userId, read: false },
      { read: true }
    );

    res.json({ message: 'Đã đánh dấu tất cả thông báo đã đọc' });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({ message: 'Lỗi khi đánh dấu tất cả thông báo đã đọc' });
  }
};

// Xóa thông báo
export const deleteNotification = async (req, res) => {
  try {
    const notification = await Notification.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.userId
    });

    if (!notification) {
      return res.status(404).json({ message: 'Không tìm thấy thông báo' });
    }

    res.json({ message: 'Đã xóa thông báo' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ message: 'Lỗi khi xóa thông báo' });
  }
}; 