import express from 'express';
import { body } from 'express-validator';
import { createAppointment, getUserAppointments, getDoctorAppointments } from '../controllers/appointmentScheduleController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { authenticateDoctor } from '../middlewares/doctorAuthMiddleware.js';

const router = express.Router();

// Validation middleware
const appointmentValidation = [
  body('doctorId').notEmpty().withMessage('Vui lòng chọn bác sĩ'),
  body('startTime').notEmpty().withMessage('Vui lòng chọn thời gian bắt đầu'),
  body('endTime').notEmpty().withMessage('Vui lòng chọn thời gian kết thúc'),
  body('date').notEmpty().withMessage('Vui lòng chọn ngày')
];

// Routes cho người dùng
router.post('/create', authenticateToken , appointmentValidation, createAppointment);
router.get('/user', authenticateToken , getUserAppointments);

// Routes cho bác sĩ
router.get('/doctor', authenticateDoctor, getDoctorAppointments);

export default router;
