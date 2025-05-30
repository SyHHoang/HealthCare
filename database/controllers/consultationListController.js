import ConsultationList from '../models/ConsultationList.js';
import Doctor from '../models/Doctor.js';
import Consultation from '../models/Consultation.js';
import mongoose from 'mongoose';
import Chat from '../models/Chat.js';

export const checkConsultation = async (req, res) => {
  try {
    const userId = req.user.userId;
    const doctorId=req.body.doctorId;
    const consultation = await ConsultationList.findOne({ userId,doctorId }).select('createdAt');
    if(consultation){
      res.json({ consultation });
    }else{
      res.json({ consultation: false });
    }
  } catch (error) {
    console.error('Lỗi kiểm tra danh sách tư vấn:', error);
  }
}

// Thêm bác sĩ vào danh sách tư vấn
export const addDoctor = async (req, res) => {
  try {
    const { doctorId } = req.body;

    // Kiểm tra xem bác sĩ có tồn tại không
    const doctor = await Doctor.findById(doctorId);
    if (!doctor) {
      return res.status(404).json({ message: 'Không tìm thấy bác sĩ' });
    }
   const idUser=req.user.userId
    // Kiểm tra xem đã thêm bác sĩ này vào danh sách chưa
    const existingConsultation = await ConsultationList.findOne({ userId:idUser, doctorId });
    if (existingConsultation) {
      return res.status(400).json({ message: 'Bác sĩ đã có trong danh sách tư vấn' });
    }

    // Thêm vào danh sách tư vấn
    const consultation = new ConsultationList({
      userId: req.user.userId,
      doctorId,
    });
    const chat=new Chat({
      userId:req.user.userId,
      doctorId:doctorId
    })
    const saveChat=await chat.save();
    const saveConsultation=await consultation.save();
    res.status(201).json({ message: 'Đã thêm bác sĩ vào danh sách tư vấn' });
  } catch (error) {
    console.error('Lỗi thêm bác sĩ vào danh sách tư vấn:', error);
    res.status(500).json({ message: 'Đã xảy ra lỗi khi thêm bác sĩ vào danh sách tư vấn' });
  }
};

// Lấy danh sách bác sĩ tư vấn
export const getConsultationList = async (req, res) => {
  try {
    const userIdString = req.user.userId;
    const userIdObject = new mongoose.Types.ObjectId(userIdString); 
    const consultationList = await ConsultationList.find({ userId: userIdObject })
      .populate({
        path: 'doctorId',
        select: 'fullName academicTitle specialty otherSpecialties experience avatar schedule services'
      });

    // Format lại dữ liệu để phù hợp với frontend
    const formattedList = consultationList.map(item => ({
      _id: item.doctorId._id,
      fullName: item.doctorId.fullName,
      academicTitle: item.doctorId.academicTitle || 'Bác sĩ',
      specialty: item.doctorId.specialty || item.doctorId.otherSpecialties || '',
      experience: item.doctorId.experience || 0,
      avatar: item.doctorId.avatar || '/images/default-doctor.jpg',
      schedule: item.doctorId.schedule || new Map(),
      services: item.doctorId.services || [],
      StartDate: item.StartDate,
      EndDate: item.EndDate,
      call: item.call 
    }));
    console.log("formattedList",formattedList);
    res.json({
      success: true,
      data: formattedList
    });
  } catch (error) {
    console.error('Lỗi lấy danh sách tư vấn:', error);
    res.status(500).json({ 
      success: false,
      message: 'Đã xảy ra lỗi khi lấy danh sách tư vấn' 
    });
  }
};

export const getConsultationListUser = async (req, res) => {
  try {
    const doctorIdString = req.doctor.id;
    const doctorIdObject = new mongoose.Types.ObjectId(doctorIdString);
    const consultationList = await ConsultationList.find({ doctorId: doctorIdObject })
      .populate({
        path: 'userId',
        select: 'fullname age gender avatar phone'
      })
      .sort({ createdAt: -1 });

    res.json(consultationList);
  } catch (error) {
    console.error('Lỗi lấy danh sách tư vấn:', error);
    res.status(500).json({ message: 'Đã xảy ra lỗi khi lấy danh sách tư vấn' });
  }
};

// Xóa bác sĩ khỏi danh sách tư vấn
export const removeDoctor = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const userId = req.user.userId; 
    // Kiểm tra xem bác sĩ có tồn tại trong danh sách không
    const existingConsultation = await ConsultationList.findOne({ userId, doctorId });
    if (!existingConsultation) {
      return res.status(404).json({ 
        success: false,
        message: 'Không tìm thấy bác sĩ trong danh sách tư vấn' 
      });
    }
    
    // Xóa bác sĩ khỏi danh sách
    const result = await ConsultationList.findOneAndDelete({ userId, doctorId });
    
    if (result) {
      res.json({ 
        success: true,
        message: 'Đã xóa bác sĩ khỏi danh sách tư vấn' 
      });
    } else {
      res.status(500).json({ 
        success: false,
        message: 'Không thể xóa bác sĩ khỏi danh sách tư vấn' 
      });
    }
  } catch (error) {
    console.error('Lỗi xóa bác sĩ khỏi danh sách tư vấn:', error);
    res.status(500).json({ 
      success: false,
      message: 'Đã xảy ra lỗi khi xóa bác sĩ khỏi danh sách tư vấn' 
    });
  }
};

export const checkDuplicateConsultation = async (req, res) => {
  try {
    const { doctorId, consultationDate } = req.body;
    
    // Chuyển đổi consultationDate thành đối tượng Date
    const date = new Date(consultationDate);
    
    // Tìm các lịch tư vấn trong cùng ngày
    const existingConsultations = await Consultation.find({
      doctorId,
      consultationDate: {
        $gte: new Date(date.setHours(0, 0, 0, 0)),
        $lt: new Date(date.setHours(23, 59, 59, 999))
      }
    });

    // Trả về danh sách thời gian đã được đặt
    const bookedTimes = existingConsultations.map(consultation => {
      const time = new Date(consultation.consultationDate);
      return time.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
    });

    res.json({
      success: true,
      data: bookedTimes
    });

  } catch (error) {
    console.error('Lỗi kiểm tra lịch trùng:', error);
    res.status(500).json({ 
      success: false,
      message: 'Đã xảy ra lỗi khi kiểm tra lịch trùng' 
    });
  }
};

export const bookConsultation = async (req, res) => {
  try {
    const { doctorId, consultationDate } = req.body;
    const userId = req.user.userId;
    console.log("doctorId",doctorId);
    console.log("consultationDate",consultationDate);
    // Kiểm tra số lần tư vấn còn lại
    const consultationList = await ConsultationList.findOne({ userId, doctorId });
    if (!consultationList) {
      return res.status(404).json({ 
        success: false,
        message: 'Không tìm thấy bác sĩ trong danh sách tư vấn' 
      });
    }

    if (consultationList.call < 1) {
      return res.status(400).json({ 
        success: false,
        message: 'Bạn đã hết số lần tư vấn. Vui lòng gia hạn để tiếp tục sử dụng dịch vụ.' 
      });
    }

    // Kiểm tra lịch trùng
    const date = new Date(consultationDate);
    const existingConsultation = await Consultation.findOne({
      doctorId,
      consultationDate: date
    });

    if (existingConsultation) {
      return res.status(400).json({ 
        success: false,
        message: 'Thời gian này đã được đặt. Vui lòng chọn thời gian khác.' 
      });
    }

    // Tạo lịch tư vấn mới
    const consultation = new Consultation({
      userId,
      doctorId,
      consultationDate: new Date(consultationDate)
    });

    await consultation.save();

    // Giảm số lần tư vấn còn lại
    consultationList.call -= 1;
    await consultationList.save();

    res.json({
      success: true,
      message: 'Đã đặt lịch tư vấn thành công',
      data: consultation
    });

  } catch (error) {
    console.error('Lỗi đặt lịch tư vấn:', error);
    res.status(500).json({ 
      success: false,
      message: 'Đã xảy ra lỗi khi đặt lịch tư vấn' 
    });
  }
};

export const getConsultationHistory = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Lấy tất cả cuộc hẹn của người dùng, sắp xếp theo thời gian
    const consultations = await Consultation.find({ userId })
      .populate({
        path: 'doctorId',
        select: 'fullName specialty avatar'
      })
      .sort({ consultationDate: -1 });

    console.log("danh sách tư vấn", consultations);

    // Tách thành 2 danh sách: đã qua và sắp tới
    const now = new Date();
    const pastConsultations = consultations.filter(c => {
      // Cuộc hẹn đã qua nếu thời gian hiện tại sau thời gian kết thúc
      return now > c.endTime;
    });

    const upcomingConsultations = consultations.filter(c => {
      // Cuộc hẹn sắp tới nếu thời gian hiện tại trước thời gian bắt đầu
      // hoặc đang trong khoảng thời gian diễn ra (từ consultationDate đến endTime)
      return now <= c.endTime;
    });

    // Lấy cuộc hẹn sớm nhất
    const nextConsultation = upcomingConsultations.length > 0 ? upcomingConsultations[0] : null;
    console.log("pastConsultations", pastConsultations);
    console.log("upcomingConsultations", upcomingConsultations);
    console.log("nextConsultation", nextConsultation);
  
    res.json({
      success: true,
      data: {
        pastConsultations,
        upcomingConsultations,
        nextConsultation
      }
    });

  } catch (error) {
    console.error('Lỗi lấy lịch sử cuộc hẹn:', error);
    res.status(500).json({ 
      success: false,
      message: 'Đã xảy ra lỗi khi lấy lịch sử cuộc hẹn' 
    });
  }
};

export const getDoctorConsultationHistory = async (req, res) => {
  try {
    const doctorId = req.doctor.id;
    
    // Lấy tất cả cuộc hẹn của bác sĩ, sắp xếp theo thời gian
    const consultations = await Consultation.find({ doctorId })
      .populate({
        path: 'userId',
        select: 'fullname age gender avatar phone'
      })
      .sort({ consultationDate: -1 });

    // Tách thành 2 danh sách: đã qua và sắp tới
    const now = new Date();
    const pastConsultations = consultations.filter(c => {
      // Cuộc hẹn đã qua nếu thời gian hiện tại sau thời gian kết thúc
      return now > c.endTime;
    });

    const upcomingConsultations = consultations.filter(c => {
      // Cuộc hẹn sắp tới nếu thời gian hiện tại trước thời gian bắt đầu
      // hoặc đang trong khoảng thời gian diễn ra (từ consultationDate đến endTime)
      return now <= c.endTime;
    });

    // Lấy cuộc hẹn sớm nhất
    const nextConsultation = upcomingConsultations.length > 0 ? upcomingConsultations[0] : null;

    res.json({
      success: true,
      data: {
        pastConsultations,
        upcomingConsultations,
        nextConsultation
      }
    });

  } catch (error) {
    console.error('Lỗi lấy lịch sử cuộc hẹn của bác sĩ:', error);
    res.status(500).json({ 
      success: false,
      message: 'Đã xảy ra lỗi khi lấy lịch sử cuộc hẹn' 
    });
  }
};