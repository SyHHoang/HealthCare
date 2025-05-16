import jwt from 'jsonwebtoken';
import Doctor from '../models/Doctor.js';

export const authenticateDoctor = async (req, res, next) => {
  try {
    // Kiểm tra token trong header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        message: 'Vui lòng đăng nhập để tiếp tục'
      });
    }

    const token = authHeader.split(' ')[1];

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
 
    // Kiểm tra bác sĩ có tồn tại và đang active
    const doctor = await Doctor.findById(decoded.id);
    if (!doctor) {
      return res.status(401).json({
        message: 'Token không hợp lệ'
      });
    }


    // Thêm thông tin bác sĩ vào request
    req.doctor = doctor;
    next();
  } catch (error) {
    console.error('Lỗi xác thực:', error);
    res.status(401).json({
      message: 'Token không hợp lệ hoặc đã hết hạn'
    });
  }
}; 