import User from '../models/User.js';
import News from '../models/News.js';
import Transaction from '../models/Transaction.js';
import Doctor from '../models/Doctor.js';
import Feedback from '../models/Feedback.js';
import ConsultationList from '../models/ConsultationList.js';

export const getDashboardStats = async (req, res) => {
  try {
    // Lấy tổng số người dùng
    const totalUsers = await User.countDocuments({ role: 'user' });
    
    // Lấy tổng số bài viết
    const totalPosts = await News.countDocuments();
    
    // Lấy tổng doanh thu
    const totalRevenue = await Transaction.aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    
    // Tính doanh thu thực tế (10% tổng doanh thu)
    const actualRevenue = totalRevenue[0]?.total ? totalRevenue[0].total * 0.1 : 0;
    
    // Thống kê bác sĩ
    const activeDoctors = await Doctor.countDocuments({ isActive: true });
    const inactiveDoctors = await Doctor.countDocuments({ isActive: false });
    
    // Thống kê feedback
    const totalFeedbacks = await Feedback.countDocuments();
    
    // Thống kê lượt tư vấn
    const totalConsultations = await ConsultationList.countDocuments();
    
    // Lấy thống kê so với tháng trước
    const lastMonth = new Date();
    lastMonth.setMonth(lastMonth.getMonth() - 1);
    
    // Thống kê người dùng mới
    const lastMonthUsers = await User.countDocuments({
      role: 'user',
      createdAt: { $gte: lastMonth }
    });
    const userChange = totalUsers > 0 ? ((lastMonthUsers / totalUsers) * 100).toFixed(1) : 0;
    
    // Thống kê bài viết mới
    const lastMonthPosts = await News.countDocuments({
      createdAt: { $gte: lastMonth }
    });
    const postChange = totalPosts > 0 ? ((lastMonthPosts / totalPosts) * 100).toFixed(1) : 0;
    
    // Thống kê doanh thu tháng trước
    const lastMonthRevenue = await Transaction.aggregate([
      { 
        $match: { 
          status: 'completed',
          createdAt: { $gte: lastMonth }
        }
      },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    
    const lastMonthTotal = lastMonthRevenue[0]?.total || 0;
    const currentMonthTotal = totalRevenue[0]?.total || 0;
    const revenueChange = lastMonthTotal > 0 
      ? (((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100).toFixed(1)
      : 0;

    // Thống kê bác sĩ mới
    const lastMonthDoctors = await Doctor.countDocuments({
      createdAt: { $gte: lastMonth }
    });
    const totalDoctors = activeDoctors + inactiveDoctors;
    const doctorChange = totalDoctors > 0 ? ((lastMonthDoctors / totalDoctors) * 100).toFixed(1) : 0;

    // Thống kê feedback mới
    const lastMonthFeedbacks = await Feedback.countDocuments({
      createdAt: { $gte: lastMonth }
    });
    const feedbackChange = totalFeedbacks > 0 ? ((lastMonthFeedbacks / totalFeedbacks) * 100).toFixed(1) : 0;

    // Thống kê lượt tư vấn mới
    const lastMonthConsultations = await ConsultationList.countDocuments({
      createdAt: { $gte: lastMonth }
    });
    const consultationChange = totalConsultations > 0 ? ((lastMonthConsultations / totalConsultations) * 100).toFixed(1) : 0;

    res.json({
      totalUsers,
      totalPosts,
      totalRevenue: totalRevenue[0]?.total || 0,
      actualRevenue,
      activeDoctors,
      inactiveDoctors,
      totalFeedbacks,
      totalConsultations,
      userChange: parseFloat(userChange),
      postChange: parseFloat(postChange),
      revenueChange: parseFloat(revenueChange),
      doctorChange: parseFloat(doctorChange),
      feedbackChange: parseFloat(feedbackChange),
      consultationChange: parseFloat(consultationChange)
    });
  } catch (error) {
    console.error('Lỗi khi lấy thống kê:', error);
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
}; 