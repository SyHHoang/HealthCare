import Doctor from '../models/Doctor.js';
import jwt from 'jsonwebtoken';
import { validationResult } from 'express-validator';
import VerificationRequest from '../models/VerificationRequest.js';

// Đăng ký bác sĩ mới
export const register = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { fullName, email, phone, password } = req.body;

    // Kiểm tra email đã tồn tại
    const existingDoctor = await Doctor.findOne({ email });
    if (existingDoctor) {
      return res.status(400).json({
        message: 'Email đã được sử dụng. Vui lòng sử dụng email khác.'
      });
    }
    // Tạo bác sĩ mới
    const doctor = await Doctor.create({
      fullName,
      email,
      phone,
      password
    });

    // Tạo token
    const token = jwt.sign({ id: doctor._id, role: doctor.role }, process.env.JWT_SECRET, {
      expiresIn: '30d'
    });

    // Loại bỏ password khỏi response
    doctor.password = undefined;

    res.status(201).json({
      status: 'success',
      token,
      doctor
    });
  } catch (error) {
    console.error('Lỗi đăng ký:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi khi đăng ký. Vui lòng thử lại sau.'
    });
  }
};

// Đăng nhập bác sĩ
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Kiểm tra email và password có được cung cấp
    if (!email || !password) {
      return res.status(400).json({
        message: 'Vui lòng cung cấp email và mật khẩu'
      });
    }

    // Tìm bác sĩ theo email và lấy cả password
    const doctor = await Doctor.findOne({ email }).select('+password');
    if (!doctor) {
      return res.status(401).json({
        message: 'Email hoặc mật khẩu không chính xác'
      });
    }

    // Kiểm tra mật khẩu
    const isPasswordCorrect = await doctor.comparePassword(password);
    if (!isPasswordCorrect) {
      return res.status(401).json({
        message: 'Email hoặc mật khẩu không chính xác'
      });
    }
    // Tạo token
    const token = jwt.sign({ id: doctor._id, role: doctor.role }, process.env.JWT_SECRET, {
      expiresIn: '30d'
    });

    // Loại bỏ password khỏi response
    doctor.password = undefined;

    res.status(200).json({
      status: 'success',
      token,
      doctor
    });
  } catch (error) {
    console.error('Lỗi đăng nhập:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi khi đăng nhập. Vui lòng thử lại sau.'
    });
  }
};

// Quên mật khẩu
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    // Tìm bác sĩ theo email
    const doctor = await Doctor.findOne({ email });
    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy tài khoản với email này'
      });
    }

    // TODO: Gửi email chứa reset token
    // Đây là nơi bạn sẽ thêm logic gửi email

    res.status(200).json({
      message: 'Vui lòng kiểm tra email của bạn để đặt lại mật khẩu'
    });
  } catch (error) {
    console.error('Lỗi quên mật khẩu:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi. Vui lòng thử lại sau.'
    });
  }
};

// Lấy thông tin profile
export const getProfile = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.doctor.id);
    console.log("------------------------------------------req.doctor",req.doctor);
    console.log("------------------------------------------doctor",doctor);
    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy thông tin bác sĩ'
      });
    }

    res.status(200).json({
      status: 'success',
      data: doctor
    });
  } catch (error) {
    console.error('Lỗi lấy thông tin profile:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi. Vui lòng thử lại sau.'
    });
  }
};

// Cập nhật thông tin bác sĩ
export const updateProfile = async (req, res) => {
  try {
    const doctorId = req.doctor.id;
    const updateData = req.body;

    // Kiểm tra xem bác sĩ có tồn tại không
    const doctor = await Doctor.findById(doctorId);
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông tin bác sĩ'
      });
    }

    // Cập nhật thông tin
    const updatedDoctor = await Doctor.findByIdAndUpdate(
      doctorId,
      { $set: updateData },
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Cập nhật thông tin thành công',
      data: updatedDoctor
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật thông tin:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server khi cập nhật thông tin'
    });
  }
};

// Đổi mật khẩu
export const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // Kiểm tra mật khẩu mới
    if (newPassword.length < 6) {
      return res.status(400).json({
        message: 'Mật khẩu mới phải có ít nhất 6 ký tự'
      });
    }

    // Lấy thông tin bác sĩ với password
    const doctor = await Doctor.findById(req.doctor._id).select('+password');
    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Kiểm tra mật khẩu hiện tại
    const isPasswordCorrect = await doctor.comparePassword(currentPassword);
    if (!isPasswordCorrect) {
      return res.status(401).json({
        message: 'Mật khẩu hiện tại không chính xác'
      });
    }

    // Cập nhật mật khẩu mới
    doctor.password = newPassword;
    await doctor.save();

    res.status(200).json({
      status: 'success',
      message: 'Đổi mật khẩu thành công'
    });
  } catch (error) {
    console.error('Lỗi đổi mật khẩu:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi khi đổi mật khẩu. Vui lòng thử lại sau.'
    });
  }
};

// Lấy danh sách tất cả bác sĩ (chỉ admin)
export const getAllDoctors = async (req, res) => {
  try {
    const { specialty, search, page = 1, limit = 10, isActive } = req.query;
    const query = {};
    // Thêm điều kiện tìm kiếm theo chuyên khoa
    if (specialty) {
      query.specialty = specialty;
    }
    // Thêm điều kiện tìm kiếm theo tên hoặc email
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    // Thêm điều kiện lọc theo trạng thái hoạt động
    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    // Tính toán skip cho phân trang
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Thực hiện query với phân trang
    const doctors = await Doctor.find(query)
      .select('-password')
      .populate('specialty', 'name')
      .skip(skip)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });

    // Đếm tổng số bác sĩ
    const total = await Doctor.countDocuments(query);

    res.status(200).json({
      success: true,
      data: doctors,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Lỗi lấy danh sách bác sĩ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lấy danh sách bác sĩ'
    });
  }
};

export const getDoctorsActive = async (req, res) => {
  try {
    const doctors = await Doctor.find({ status: 'active' }).select('-password');
    console.log(doctors);
    res.status(200).json({
      status: 'success',
      results: doctors.length,
      data: { doctors }
    });
  } catch (error) {
    console.error('Lỗi lấy danh sách bác sĩ:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi. Vui lòng thử lại sau.'
    });
  }
};

// Cập nhật trạng thái bác sĩ (chỉ admin)
export const updateDoctorStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const doctor = await Doctor.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true, runValidators: true }
    ).select('-password');

    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy bác sĩ'
      });
    }

    res.status(200).json({
      status: 'success',
      data: { doctor }
    });
  } catch (error) {
    console.error('Lỗi cập nhật trạng thái:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi. Vui lòng thử lại sau.'
    });
  }
};

// Cập nhật avatar
export const updateAvatar = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        message: 'Vui lòng tải lên một ảnh'
      });
    }

    const doctor = await Doctor.findByIdAndUpdate(
      req.doctor.id,
      { avatar: req.file.path },
      { new: true, runValidators: true }
    );

    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy bác sĩ'
      });
    }

    res.status(200).json({
      status: 'success',
      avatarUrl: doctor.avatar
    });
  } catch (error) {
    console.error('Lỗi cập nhật avatar:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi khi cập nhật ảnh đại diện. Vui lòng thử lại sau.'
    });
  }
};

// Lấy thông tin chi tiết bác sĩ
export const getPublicProfileDoctorById = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id).select(' _id fullName specialty academicTitle experience otherSpecialties avatar schedule services');
    
    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Không tìm thấy bác sĩ'
      });
    }
    console.log('doctor',doctor);
    res.status(200).json({
      status: 'success',
      data: doctor
    });
  } catch (error) {
    console.error('Lỗi lấy thông tin bác sĩ:', error);
    res.status(500).json({
      status: 'error',
      message: 'Đã xảy ra lỗi. Vui lòng thử lại sau.'
    });
  }
};

// Lấy thông tin ảnh của bác sĩ
export const getDoctorImageId = async (req, res) => {
  try {
    const doctorId = req.doctor.id; // Lấy ID từ token
    const doctor = await Doctor.findById(doctorId).select('imageId delete_token avatar');
    
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông tin bác sĩ'
      });
    }

    res.json({
      success: true,
      imageId: doctor.imageId || '',
      delete_token: doctor.delete_token || '',
      avatar: doctor.avatar || ''
    });
  } catch (error) {
    console.error('Lỗi khi lấy thông tin ảnh:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server khi lấy thông tin ảnh'
    });
  }
};

// Thêm bác sĩ mới (admin)
export const createDoctor = async (req, res) => {
  try {
    const { fullName, email, phone, experience, specialty, isActive } = req.body;

    // Kiểm tra email đã tồn tại
    const existingDoctor = await Doctor.findOne({ email });
    if (existingDoctor) {
      return res.status(400).json({
        success: false,
        message: 'Email đã được sử dụng'
      });
    }

    // Tạo mật khẩu mặc định
    const defaultPassword = '123456';

    // Tạo bác sĩ mới
    const doctor = await Doctor.create({
      fullName,
      email,
      phone,
      password: defaultPassword,
      experience,
      specialty,
      isActive: isActive === 'true',
      avatar: req.file ? req.file.path : undefined
    });

    res.status(201).json({
      success: true,
      message: 'Thêm bác sĩ thành công',
      data: doctor
    });
  } catch (error) {
    console.error('Lỗi thêm bác sĩ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi thêm bác sĩ'
    });
  }
};

// Cập nhật thông tin bác sĩ (admin)
export const updateDoctor = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Kiểm tra bác sĩ có tồn tại không
    const doctor = await Doctor.findById(id);
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Nếu có thay đổi email, kiểm tra email mới có trùng không
    if (updateData.email && updateData.email !== doctor.email) {
      const existingDoctor = await Doctor.findOne({ email: updateData.email });
      if (existingDoctor) {
        return res.status(400).json({
          success: false,
          message: 'Email đã được sử dụng'
        });
      }
    }

    // Cập nhật thông tin
    const updatedDoctor = await Doctor.findByIdAndUpdate(
      id,
      { 
        ...updateData,
        avatar: req.file ? req.file.path : doctor.avatar
      },
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Cập nhật thông tin bác sĩ thành công',
      data: updatedDoctor
    });
  } catch (error) {
    console.error('Lỗi cập nhật bác sĩ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi cập nhật thông tin bác sĩ'
    });
  }
};

// Xóa bác sĩ (admin)
export const deleteDoctor = async (req, res) => {
  try {
    const { id } = req.params;

    // Kiểm tra bác sĩ có tồn tại không
    const doctor = await Doctor.findById(id);
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Xóa bác sĩ
    await Doctor.findByIdAndDelete(id);

    res.json({
      success: true,
      message: 'Xóa bác sĩ thành công'
    });
  } catch (error) {
    console.error('Lỗi xóa bác sĩ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi xóa bác sĩ'
    });
  }
};

export const getPublicDoctors = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 3;
    
    const doctors = await Doctor.find({ status: 'active' })
      .select('fullName email phone specialty education experience currentWorkplace avatar schedule')
      .sort({ createdAt: -1 })
      .limit(limit);

    if (!doctors || doctors.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ nào'
      });
    }

    res.status(200).json({
      success: true,
      doctors: doctors.map(doctor => ({
        _id: doctor._id,
        fullname: doctor.fullName,
        position: doctor.education,
        specialty: doctor.specialty,
        experience: doctor.experience,
        workplace: doctor.currentWorkplace,
        avatar: doctor.avatar || '/images/default-doctor.jpg'
      }))
    });
  } catch (error) {
    console.error('Error in getPublicDoctors:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server'
    });
  }
};

// Lấy lịch làm việc của bác sĩ
export const getSchedule = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.doctor.id);
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }
    // Chuyển Map thành Object để gửi về client
    const schedule = {};
    doctor.schedule.forEach((timeSlots, day) => {
      // Sắp xếp thời gian theo thứ tự từ sớm đến muộn
      const sortedSlots = [...timeSlots].sort((a, b) => {
        return a.startTime.localeCompare(b.startTime);
      });
      schedule[day] = sortedSlots;
    });

    res.status(200).json({
      success: true,
      schedule
    });
  } catch (error) {
    console.error('Lỗi lấy lịch làm việc:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lấy lịch làm việc'
    });
  }
};

// Thêm thời gian làm việc
export const addWorkingTime = async (req, res) => {
  try {
    const { day, startTime} = req.body;
    const doctor = await Doctor.findById(req.doctor.id);

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Kiểm tra xung đột thời gian
    const existingSlots = doctor.schedule.get(day) || [];
    const hasConflict = existingSlots.some(slot => {
      return (
        (startTime >= slot.startTime && startTime < slot.endTime) 
      );
    });

    if (hasConflict) {
      return res.status(400).json({
        success: false,
        message: 'Thời gian này đã có lịch làm việc'
      });
    }

    // Thêm thời gian mới và sắp xếp lại
    const newSlot = { startTime };
    const updatedSlots = [...existingSlots, newSlot].sort((a, b) => {
      return a.startTime.localeCompare(b.startTime);
    });
    doctor.schedule.set(day, updatedSlots);
    await doctor.save();

    res.status(200).json({
      success: true,
      message: 'Thêm thời gian làm việc thành công',
      schedule: doctor.schedule.get(day)
    });
  } catch (error) {
    console.error('Lỗi thêm thời gian làm việc:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi thêm thời gian làm việc'
    });
  }
};


// Xóa thời gian làm việc
export const deleteWorkingTime = async (req, res) => {
  try {
    const { day, index } = req.params;
    const doctor = await Doctor.findById(req.doctor.id);

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    const timeSlots = doctor.schedule.get(day);
    if (!timeSlots || !timeSlots[index]) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thời gian làm việc'
      });
    }

    // Xóa thời gian làm việc
    timeSlots.splice(index, 1);
    if (timeSlots.length === 0) {
      doctor.schedule.delete(day);
    } else {
      doctor.schedule.set(day, timeSlots);
    }
    await doctor.save();

    res.status(200).json({
      success: true,
      message: 'Xóa thời gian làm việc thành công'
    });
  } catch (error) {
    console.error('Lỗi xóa thời gian làm việc:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi xóa thời gian làm việc'
    });
  }
};

// Lưu dịch vụ tư vấn
export const saveServices = async (req, res) => {
  try {
    const { services } = req.body;
    const doctor = await Doctor.findById(req.doctor.id);

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Kiểm tra giá dịch vụ có nằm trong khoảng cho phép không
    const serviceOptions = {
      15: { min: 100000, max: 200000 },
      30: { min: 200000, max: 400000 },
      45: { min: 300000, max: 600000 },
      60: { min: 400000, max: 800000 }
    };

    for (const service of services) {
      const option = serviceOptions[service.duration];
      if (!option || service.price < option.min || service.price > option.max) {
        return res.status(400).json({
          success: false,
          message: `Giá dịch vụ ${service.duration} phút phải nằm trong khoảng ${option.min} - ${option.max} VNĐ`
        });
      }
    }

    // Lưu dịch vụ
    doctor.services = services;
    await doctor.save();

    res.status(200).json({
      success: true,
      message: 'Lưu dịch vụ thành công',
      services: doctor.services
    });
  } catch (error) {
    console.error('Lỗi lưu dịch vụ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lưu dịch vụ'
    });
  }
};

// Lấy danh sách dịch vụ
export const getServices = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.doctor.id);

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    res.status(200).json({
      success: true,
      services: doctor.services || []
    });
  } catch (error) {
    console.error('Lỗi lấy danh sách dịch vụ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lấy danh sách dịch vụ'
    });
  }
};

// Lấy thông tin profile để chỉnh sửa
export const getProfileForEdit = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.doctor.id).select('-password');
    
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông tin bác sĩ'
      });
    }

    // Format dữ liệu trả về
    const formattedDoctor = {
      status: doctor.status,
      fullName: doctor.fullName,
      email: doctor.email,
      phone: doctor.phone,
      avatar: doctor.avatar,
      specialty: doctor.specialty,
      otherSpecialties: doctor.otherSpecialties,
      experience: doctor.experience,
      currentWorkplace: doctor.currentWorkplace,
      education: doctor.education,
      graduationYear: doctor.graduationYear,
      licenseNumber: doctor.licenseNumber,
      academicTitle: doctor.academicTitle,
      address: doctor.address
    };

    res.status(200).json({
      success: true,
      data: formattedDoctor
    });
  } catch (error) {
    console.error('Lỗi lấy thông tin profile để chỉnh sửa:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lấy thông tin profile'
    });
  }
};

// Lấy toàn bộ thông tin bác sĩ
export const getFullDoctorInfo = async (req, res) => {
  try {
    const doctorId = req.params.id;
    console.log('doctorId',doctorId);
    // Lấy thông tin cơ bản của bác sĩ
    const doctor = await Doctor.findById(doctorId).select('-password');
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Lấy thông tin yêu cầu xác thực gần nhất
    const verificationRequest = await VerificationRequest.findOne({ 
      doctorId: doctorId 
    }).sort({ submittedAt: -1 });

    // Format dữ liệu trả về
    const formattedDoctor = {
      basicInfo: {
        _id: doctor._id,
        fullName: doctor.fullName,
        email: doctor.email,
        phone: doctor.phone,
        avatar: doctor.avatar,
        status: doctor.status,
        createdAt: doctor.createdAt
      },
      professionalInfo: {
        specialty: doctor.specialty,
        otherSpecialties: doctor.otherSpecialties,
        experience: doctor.experience,
        currentWorkplace: doctor.currentWorkplace,
        academicTitle: doctor.academicTitle
      },
      educationInfo: {
        education: doctor.education,
        graduationYear: doctor.graduationYear,
        licenseNumber: doctor.licenseNumber
      },
      schedule: doctor.schedule,
      services: doctor.services,
      verificationInfo: verificationRequest ? {
        status: verificationRequest.status,
        submittedAt: verificationRequest.submittedAt,
        reviewedAt: verificationRequest.reviewedAt,
        rejectionReason: verificationRequest.rejectionReason
      } : null
    };

    res.status(200).json({
      success: true,
      data: formattedDoctor
    });
  } catch (error) {
    console.error('Lỗi khi lấy thông tin chi tiết bác sĩ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lấy thông tin bác sĩ'
    });
  }
}; 