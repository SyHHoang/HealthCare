import express from 'express';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';
import Review from '../models/Review.js';
import Doctor from '../models/Doctor.js';

const router = express.Router();

// Tạo đánh giá mới
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { doctorId, rating, content } = req.body;
    const userId = req.user.userId;

    // Kiểm tra xem người dùng đã đánh giá bác sĩ này chưa
    const existingReview = await Review.findOne({ userId, doctorId });
    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: 'Bạn đã đánh giá bác sĩ này rồi'
      });
    }

    // Tạo đánh giá mới
    const review = new Review({
      userId,
      doctorId,
      rating,
      content
    });

    await review.save();

    // Cập nhật điểm đánh giá trung bình của bác sĩ
    const doctorReviews = await Review.find({ doctorId });
    const averageRating = doctorReviews.reduce((acc, curr) => acc + curr.rating, 0) / doctorReviews.length;
    
    await Doctor.findByIdAndUpdate(doctorId, {
      rating: averageRating,
      totalReviews: doctorReviews.length
    });

    res.status(201).json({
      success: true,
      message: 'Đánh giá thành công',
      data: review
    });
  } catch (error) {
    console.error('Lỗi khi tạo đánh giá:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server',
      error: error.message
    });
  }
});

// Lấy danh sách đánh giá của một bác sĩ
router.get('/doctor/:doctorId', async (req, res) => {
  try {
    const { doctorId } = req.params;
    const reviews = await Review.find({ doctorId })
      .populate('userId', 'fullName avatar')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      data: reviews
    });
  } catch (error) {
    console.error('Lỗi khi lấy danh sách đánh giá:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server',
      error: error.message
    });
  }
});

// Lấy đánh giá của người dùng cho một bác sĩ
router.get('/user/:doctorId', authenticateToken, async (req, res) => {
  try {
    const { doctorId } = req.params;
    const userId = req.user.userId;

    const review = await Review.findOne({ userId, doctorId });

    res.json({
      success: true,
      data: review
    });
  } catch (error) {
    console.error('Lỗi khi lấy đánh giá của người dùng:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server',
      error: error.message
    });
  }
});

// Cập nhật đánh giá
router.put('/:reviewId', authenticateToken, async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { rating, content } = req.body;
    const userId = req.user.userId;

    const review = await Review.findOne({ _id: reviewId, userId });
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đánh giá'
      });
    }

    review.rating = rating;
    review.content = content;
    await review.save();

    // Cập nhật điểm đánh giá trung bình của bác sĩ
    const doctorReviews = await Review.find({ doctorId: review.doctorId });
    const averageRating = doctorReviews.reduce((acc, curr) => acc + curr.rating, 0) / doctorReviews.length;
    
    await Doctor.findByIdAndUpdate(review.doctorId, {
      rating: averageRating,
      totalReviews: doctorReviews.length
    });

    res.json({
      success: true,
      message: 'Cập nhật đánh giá thành công',
      data: review
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật đánh giá:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server',
      error: error.message
    });
  }
});

// Xóa đánh giá
router.delete('/:reviewId', authenticateToken, async (req, res) => {
  try {
    const { reviewId } = req.params;
    const userId = req.user.userId;

    const review = await Review.findOne({ _id: reviewId, userId });
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đánh giá'
      });
    }

    await review.deleteOne();

    // Cập nhật điểm đánh giá trung bình của bác sĩ
    const doctorReviews = await Review.find({ doctorId: review.doctorId });
    const averageRating = doctorReviews.length > 0 
      ? doctorReviews.reduce((acc, curr) => acc + curr.rating, 0) / doctorReviews.length 
      : 0;
    
    await Doctor.findByIdAndUpdate(review.doctorId, {
      rating: averageRating,
      totalReviews: doctorReviews.length
    });

    res.json({
      success: true,
      message: 'Xóa đánh giá thành công'
    });
  } catch (error) {
    console.error('Lỗi khi xóa đánh giá:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server',
      error: error.message
    });
  }
});

// Lấy thông tin đánh giá tổng quan của bác sĩ
router.get('/doctor-stats', authenticateDoctor, async (req, res) => {
  try {
    console.log("------------------------------------------req.doctor",req.doctor);
    const  doctorId  = req.doctor.id;
    console.log("------------------------------------------doctorId",doctorId);
    // Lấy tất cả đánh giá của bác sĩ
    const reviews = await Review.find({ doctorId });
    console.log("------------------------------------------reviews",reviews);
    // Tính toán thống kê
    const totalReviews = reviews.length;
    const averageRating = totalReviews > 0 
      ? reviews.reduce((acc, curr) => acc + curr.rating, 0) / totalReviews 
      : 0;
    
    // Phân loại đánh giá theo số sao
    const ratingDistribution = {
      5: reviews.filter(r => r.rating === 5).length,
      4: reviews.filter(r => r.rating === 4).length,
      3: reviews.filter(r => r.rating === 3).length,
      2: reviews.filter(r => r.rating === 2).length,
      1: reviews.filter(r => r.rating === 1).length
    };

    res.json({
      success: true,
      data: {
        totalReviews,
        averageRating,
        ratingDistribution
      }
    });
  } catch (error) {
    console.error('Lỗi khi lấy thống kê đánh giá:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server',
      error: error.message
    });
  }
});

// Lấy thông tin đánh giá công khai của bác sĩ
router.get('/doctor-statspublicpublic/:doctorId', async (req, res) => {
  try {
    const { doctorId } = req.params;

    // Kiểm tra bác sĩ có tồn tại
    const doctor = await Doctor.findById(doctorId);
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Lấy tất cả đánh giá của bác sĩ
    const reviews = await Review.find({ doctorId })
      .populate('userId', 'fullname avatar')
      .sort({ createdAt: -1 });

    // Tính toán thống kê
    const totalReviews = reviews.length;
    const averageRating = totalReviews > 0 
      ? reviews.reduce((acc, review) => acc + review.rating, 0) / totalReviews 
      : 0;

    // Tính phân bố số sao
    const ratingDistribution = {
      5: reviews.filter(review => review.rating === 5).length,
      4: reviews.filter(review => review.rating === 4).length,
      3: reviews.filter(review => review.rating === 3).length,
      2: reviews.filter(review => review.rating === 2).length,
      1: reviews.filter(review => review.rating === 1).length
    };

    // Lấy 5 đánh giá mới nhất
    const latestReviews = reviews.slice(0, 5).map(review => ({
      rating: review.rating,
      content: review.content,
      createdAt: review.createdAt,
      user: {
        fullname: review.userId.fullname,
        avatar: review.userId.avatar
      }
    }));

    res.json({
      success: true,
      data: {
        totalReviews,
        averageRating,
        ratingDistribution,
        latestReviews
      }
    });
  } catch (error) {
    console.error('Lỗi khi lấy thông tin đánh giá:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server khi lấy thông tin đánh giá'
    });
  }
});

// Lấy danh sách đánh giá của chính bác sĩ đang đăng nhập
router.get('/doctor-reviews', authenticateDoctor, async (req, res) => {
  try {
    const doctorId = req.doctor.id;
    const reviews = await Review.find({ doctorId })
      .populate('userId', 'fullName avatar')
      .sort({ createdAt: -1 });
    res.json({ success: true, data: reviews });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Lỗi server', error: error.message });
  }
});

export default router; 