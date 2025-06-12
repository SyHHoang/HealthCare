import VerificationRequest from '../models/VerificationRequest.js';
import Doctor from '../models/Doctor.js';
import mongoose from 'mongoose';

// Gửi yêu cầu xác thực
export const requestVerification = async (req, res) => {
  try {
    console.log('Request body:', req.body);
    const doctorId = req.doctor._id;
    console.log('Doctor ID:', doctorId);

    // Kiểm tra xem bác sĩ đã có yêu cầu xác thực chưa
    const existingRequest = await VerificationRequest.findOne({ 
      doctorId: doctorId,
      status: 'pending'
    });

    if (existingRequest) {
      return res.status(400).json({ 
        message: 'Bạn đã có yêu cầu xác thực đang chờ xử lý' 
      });
    }

    // Tạo yêu cầu xác thực mới
    const verificationRequest = new VerificationRequest({
      doctor: doctorId,
      fullName: req.body.fullName,
      email: req.body.email,
      phone: req.body.phone,
      avatar: req.body.avatar,
      specialty: req.body.specialty,
      otherSpecialties: req.body.otherSpecialties,
      experience: req.body.experience,
      currentWorkplace: req.body.currentWorkplace,
      education: req.body.education,
      graduationYear: req.body.graduationYear,
      licenseNumber: req.body.licenseNumber,
      status: 'pending',
      licenseImageUrl: req.body.licenseImageUrl,
      idCardFrontUrl: req.body.idCardFrontUrl,
      idCardBackUrl: req.body.idCardBackUrl
    });

    await verificationRequest.save();

    // Cập nhật verifiID cho Doctor
    await Doctor.findByIdAndUpdate(doctorId, {
      verifiID: verificationRequest._id,
      status: 'pending processing'
    });

    res.status(201).json({
      success: true,
      message: 'Yêu cầu xác thực đã được gửi thành công',
      request: verificationRequest
    });
  } catch (error) {
    console.error('Lỗi khi gửi yêu cầu xác thực:', error);
    res.status(500).json({ 
      success: false,
      message: 'Lỗi server' 
    });
  }
};

// Lấy yêu cầu xác thực của bác sĩ
export const getDoctorVerificationRequest = async (req, res) => {
  try {
    const doctorId = req.doctor._id;
    console.log('Doctor ID:', doctorId);
    
    const request = await VerificationRequest.findOne({ doctorId: doctorId });
    console.log('Request:', request);
    
    if (!request) {
      return res.status(404).json({ 
        success: false,
        message: 'Không tìm thấy yêu cầu xác thực' 
      });
    }

    res.json({
      success: true,
      data: request
    });
  } catch (error) {
    console.error('Lỗi khi lấy yêu cầu xác thực:', error);
    res.status(500).json({ 
      success: false,
      message: 'Lỗi server' 
    });
  }
};

// Lấy danh sách yêu cầu xác thực (admin)
export const getVerificationRequests = async (req, res) => {
  try {
    const requests = await VerificationRequest.find()
      .sort({ submittedAt: -1 });
    res.json(requests);
    console.log('Danh sách yêu cầu xác thực:', requests); // In ra để kiểm tra
  } catch (error) {
    console.error('Lỗi khi lấy danh sách yêu cầu xác thực:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Xử lý yêu cầu xác thực (admin)
export const handleVerificationRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { action, reason } = req.body;
    const adminId = req.user.userId;
    console.log('sữ liệu xác thực từ client gửi lên:', requestId, action, reason, adminId);
    
    // Kiểm tra xem yêu cầu xác thực có tồn tại không
    const request = await VerificationRequest.findById(requestId);
    console.log('yêu cầu xác thực:', request);
    if (!request) {
      return res.status(404).json({ message: 'Không tìm thấy yêu cầu xác thực' });
    }

    if (request.status !== 'pending') {
      return res.status(400).json({ message: 'Yêu cầu này đã được xử lý' });
    }

    // Cập nhật trạng thái yêu cầu
    request.status = action === 'approved' ? 'approved' : 'rejected';
    const doctorId = new mongoose.Types.ObjectId(request.doctor);
    
    // Cập nhật thông tin bác sĩ
    const updatedDoctor = await Doctor.findByIdAndUpdate(
      doctorId,
      { 
        status: action === 'approved' ? 'active' : 'inactive',
        fullName: request.fullName,
        email: request.email,
        phone: request.phone,
        avatar: request.avatar,
        specialty: request.specialty,
        otherSpecialties: request.otherSpecialties,
        experience: request.experience,
        currentWorkplace: request.currentWorkplace,
        education: request.education,
        graduationYear: request.graduationYear,
        licenseNumber: request.licenseNumber,
      },
      { new: true }
    );

    if (!updatedDoctor) {
      return res.status(404).json({ message: 'Không tìm thấy bác sĩ' });
    }

    request.reviewedAt = new Date();
    request.reviewedBy = adminId;
    if (action === 'rejected') {
      request.rejectionReason = reason;
    }
    await request.save();

    res.json({
      message: `Yêu cầu xác thực đã được ${action === 'approved' ? 'duyệt' : 'từ chối'}`,
      request
    });
  } catch (error) {
    console.error('Lỗi khi xử lý yêu cầu xác thực:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Lấy chi tiết đơn xác thực của bác sĩ
export const getDoctorVerificationDetails = async (req, res) => {
  try {
    const doctorId = req.doctor._id;
    console.log('Doctor ID:', doctorId);
    
    // Lấy verifiID từ thông tin bác sĩ
    const doctor = await Doctor.findById(doctorId);
    console.log('=============Doctor:', doctor);
    if (!doctor || !doctor.verifiID) {
      return res.status(404).json({ 
        success: false,
        message: 'Không tìm thấy đơn xác thực' 
      });
    }

    // Tìm đơn xác thực bằng verifiID
    const request = await VerificationRequest.findById(doctor.verifiID);
    console.log('Verification Request:', request);
    
    if (!request) {
      return res.status(404).json({ 
        success: false,
        message: 'Không tìm thấy đơn xác thực' 
      });
    }

    res.json({
      success: true,
      data: request
    });
  } catch (error) {
    console.error('Lỗi khi lấy chi tiết đơn xác thực:', error);
    res.status(500).json({ 
      success: false,
      message: 'Lỗi server' 
    });
  }
}; 