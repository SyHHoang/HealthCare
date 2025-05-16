import Doctor from '../models/Doctor.js';

export const checkDoctorActivation = async (req, res, next) => {
  try {
    const doctor = await Doctor.findById(req.doctor.id);
    
    if (!doctor.status === 'active') {
      return res.status(403).json({
        message: 'Tài khoản của bạn chưa được kích hoạt. Vui lòng liên hệ quản trị viên.'
      });
    }
    
    next();
  } catch (error) {
    console.error('Lỗi kiểm tra kích hoạt:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi khi kiểm tra trạng thái tài khoản'
    });
  }
}; 