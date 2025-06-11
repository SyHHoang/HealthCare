import Feedback from '../models/Feedback.js';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import Notification from '../models/notificationModel.js';
import User from '../models/User.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getFeedbacks = async (req, res) => {
  try {
    const { page = 1, limit = 10, rating, service, search } = req.query;
    const skip = (page - 1) * limit;
    const filterConditions = {};

    if (rating) filterConditions.rating = parseInt(rating);
    if (service) filterConditions.service = service;
    if (search) filterConditions.$or = [
      { title: { $regex: search, $options: 'i' } },
      { content: { $regex: search, $options: 'i' } }
    ];

    const total = await Feedback.countDocuments(filterConditions);
    const feedbacks = await Feedback.find(filterConditions)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('userId', 'fullname email');

    res.json({
      feedbacks: feedbacks.map(fb => ({
        id: fb._id, title: fb.title, content: fb.content, rating: fb.rating,
        service: fb.service, pros: fb.pros, cons: fb.cons, suggestions: fb.suggestions,
        images: fb.images, email: fb.email, phone: fb.phone, createdAt: fb.createdAt,
        user: fb.userId
      })),
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: Number(page)
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy danh sách đánh giá', error: error.message });
  }
};

export const getTopFeedbacks = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 4;
    
    // Lấy các đánh giá có rating từ 4 sao trở lên
    const feedbacks = await Feedback.find({ rating: { $gte: 4 } })
      .sort({ rating: -1, createdAt: -1 }) // Sắp xếp theo rating cao nhất và mới nhất
      .limit(limit)
      .populate('userId', 'fullname email avatar');

    res.json({
      feedbacks: feedbacks.map(fb => ({
        id: fb._id,
        title: fb.title,
        content: fb.content,
        rating: fb.rating,
        service: fb.service,
        createdAt: fb.createdAt,
        user: fb.userId ? {
          fullname: fb.userId.fullname,
          email: fb.userId.email,
          avatar: fb.userId.avatar
        } : null
      }))
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy đánh giá nổi bật', error: error.message });
  }
};

export const createFeedback = async (req, res) => {
  try {
    const { rating, service, title, content, pros, cons, suggestions, email, phone } = req.body;
    const images = req.files?.images || [];

    const feedback = new Feedback({
      rating,
      service,
      title,
      content,
      pros,
      cons,
      suggestions,
      email,
      phone,
      images: images.map(file => file.filename),
      userId: req.user.userId
    });

    await feedback.save();

    // Tạo thông báo cho user
    const notification = new Notification({
      userId: req.user.userId,
      title: 'Phản hồi thành công',
      message: 'Phản hồi của bạn đã được gửi thành công!',
      type: 'feedback',
      data: {
        feedbackId: feedback._id,
        rating,
        service
      }
    });

    // Lưu thông báo vào database
    await notification.save();

    // Gửi thông báo realtime cho user
    const io = req.app.get('io');
    io.to(`user_${req.user.userId}`).emit('feedback_success', {
      feedbackId: feedback._id,
      message: 'Phản hồi của bạn đã được gửi thành công rồi đó babyaasdsadd!'
    });

    res.status(201).json({
      message: 'Phản hồi đã được gửi thành công',
      feedback
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deleteFeedback = async (req, res) => {
  try {
    const feedback = await Feedback.findById(req.params.id);
    if (!feedback) return res.status(404).json({ message: 'Không tìm thấy đánh giá' });

    // Xóa ảnh
    feedback.images.forEach(imageUrl => {
      const imagePath = path.join(__dirname, '..', imageUrl);
      if (fs.existsSync(imagePath)) fs.unlinkSync(imagePath);
    });

    await feedback.deleteOne();
    res.json({ message: 'Đã xóa đánh giá thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi xóa đánh giá', error: error.message });
  }
};

export const getFeedbackSummary = async (req, res) => {
  try {
    const totalFeedbacks = await Feedback.countDocuments();
    res.json({ totalFeedbacks });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!', error: error.message });
  }
};
