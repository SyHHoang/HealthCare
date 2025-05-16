import AppointmentSchedule from '../models/appointmentSchedule.js';
import { validationResult } from 'express-validator';

// Tạo lịch hẹn mới
export const createAppointment = async (req, res) => {
  try {
    const { doctorId, startTime, date } = req.body;
    const userId = req.user.userId; // Lấy từ middleware auth
    console.log("req.body",req.body)
    console.log("userId",userId)
    // Kiểm tra xem đã có lịch hẹn nào trùng thời gian chưa
    const existingAppointment = await AppointmentSchedule.findOne({
      doctorId,
      date,
      $or: [
        {
          startTime:startTime
        }
      ]

    });

    if (existingAppointment) {
      return res.status(400).json({
        success: false,
        message: 'Thời gian này đã có người đặt. Vui lòng chọn thời gian khác.'
      });
    }

    const newAppointment = new AppointmentSchedule({
      userId,
      doctorId,
      startTime,
      date
    });

    await newAppointment.save();

    res.status(201).json({
      success: true,
      message: 'Đặt lịch hẹn thành công',
      data: newAppointment
    });
  } catch (error) {
    console.error('Error creating appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server. Vui lòng thử lại sau.'
    });
  }
};
// Lấy danh sách lịch hẹn của người dùng
export const getUserAppointments = async (req, res) => {
  try {
    const userId = req.user.userId;
    const appointments = await AppointmentSchedule.find({ userId })
      .populate('doctorId', 'fullName specialty avatar')
      .sort({ date: 1, startTime: 1 });

    res.json({
      success: true,
      data: appointments
    });
  } catch (error) {
    console.error('Error getting user appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server. Vui lòng thử lại sau.'
    });
  }
};

// Lấy danh sách lịch hẹn của bác sĩ
export const getDoctorAppointments = async (req, res) => {
  try {
    const doctorId = req.doctor.id;
    const appointments = await AppointmentSchedule.find({ doctorId })
      .populate('userId', 'fullName email phone')
      .sort({ date: 1, startTime: 1 });

    res.json({
      success: true,
      data: appointments
    });
  } catch (error) {
    console.error('Error getting doctor appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi server. Vui lòng thử lại sau.'
    });
  }
};
