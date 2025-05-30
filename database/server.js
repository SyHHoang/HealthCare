import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import { Server } from 'socket.io';
import http from 'http';
import jwt from 'jsonwebtoken';
import connectDB from "./config/connectDB.js";
import userRoutes from "./routes/userRoutes.js";
import newsRoutes from "./routes/newsRoutes.js";
import feedbackRoutes from './routes/feedbackRoutes.js'
import contactRoutes from './routes/contactRoutes.js';
import authRoutes from "./routes/authRoutes.js";
import fileUpload from 'express-fileupload';
import mongoose from 'mongoose';
import doctorRoutes from './routes/doctorRoutes.js';
import specialtyRoutes from './routes/specialtyRoutes.js';
import consultationListRoutes from './routes/consultationListRoutes.js';
import verificationRoutes from './routes/verificationRoutes.js';
import chatRoutes from './routes/chatRoutes.js';
import drugRoutes from './routes/drugRoutes.js';
import medicationRoutes from './routes/MedicalRecordRoutes/medicationRoutes.js';
import allergyRoutes from './routes/MedicalRecordRoutes/allergyRoutes.js';
import vaccinationRoutes from './routes/MedicalRecordRoutes/vaccinationRoutes.js';
import prescriptionRoutes from './routes/MedicalRecordRoutes/prescriptionRoutes.js';
import treatmentRoutes from './routes/MedicalRecordRoutes/treatmentRoutes.js';
import symptomsRoutes from './routes/MedicalRecordRoutes/symptomsRoutes.js';
import lifestyleRoutes from './routes/MedicalRecordRoutes/lifestyleRoutes.js';
import healthDataRoutes from './routes/MedicalRecordRoutes/healthDataRoutes.js';
import appointmentScheduleRoutes from './routes/appointmentScheduleRoutes.js';
import vnpayRoutes from './routes/vnpayRoutes.js';
import transactionRoutes from './routes/transactionRoutes.js';
import notificationRoutes from './routes/notificationRoutes.js';
import Chat from './models/Chat.js';
import Message from './models/Message.js';
import orderTypeRoutes from './routes/orderTypeRoutes.js';
import videoCallRoutes from './routes/videoCallRoutes.js';
import adminRoutes from './routes/adminRoutes.js';
import reviewRoutes from './routes/reviewRoutes.js';
import Consultation from './models/Consultation.js';

// Tạo __dirname cho ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();
connectDB();

const app = express();
const server = http.createServer(app);

// Cấu hình view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

const io = new Server(server, {
  cors: {
    origin: true,
    methods: ["GET", "POST"],
    credentials: true
  }
});

// Lưu trữ kết nối socket của người dùng và bác sĩ
const userSockets = new Map();
const doctorSockets = new Map();

// Lưu trữ thông tin phòng video call
const videoCallRooms = new Map();

// Hàm kiểm tra thời gian tư vấn
const isConsultationTime = (consultationDate) => {
  const now = new Date();
  const consultationTime = new Date(consultationDate);
  const timeDiff = Math.abs(consultationTime - now);
  return timeDiff <= 15 * 60 * 1000; // Cho phép vào phòng trước/sau 15 phút
};

// Hàm tạo phòng video call
const createVideoCallRoom = (consultationId, consultationDate) => {
  const roomId = `video_call_${consultationId}`;
  videoCallRooms.set(roomId, {
    consultationId,
    consultationDate,
    participants: new Set(),
    createdAt: new Date()
  });
  console.log('=== VIDEO CALL ROOM CREATED ===');
  console.log('Room ID:', roomId);
  console.log('Consultation Date:', consultationDate);
  return roomId;
};

// Hàm kiểm tra và dọn dẹp phòng cũ
const cleanupOldRooms = () => {
  const now = new Date();
  for (const [roomId, room] of videoCallRooms.entries()) {
    const consultationTime = new Date(room.consultationDate);
    const timeDiff = Math.abs(consultationTime - now);
    if (timeDiff > 30 * 60 * 1000) { // Xóa phòng sau 30 phút
      console.log('=== CLEANING UP OLD ROOM ===');
      console.log('Room ID:', roomId);
      videoCallRooms.delete(roomId);
    }
  }
};

// Chạy cleanup mỗi 5 phút
setInterval(cleanupOldRooms, 5 * 60 * 1000);

// Middleware xác thực socket
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Không có token'));
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.id || decoded.userId;
    socket.role = decoded.role;
    console.log("Socket connected:", socket.userId, socket.role);
    next();
  } catch (error) {
    next(new Error('Token không hợp lệ'));
  }
});

// Xử lý kết nối socket
io.on('connection', (socket) => {
  console.log('Client connected:', socket.userId, socket.role);

  // Lưu socket vào Map tương ứng
  if (socket.role === 'user') {
    userSockets.set(socket.userId, socket);
    // Tham gia vào room của user
    socket.join(`user_${socket.userId}`);
    console.log(`User ${socket.userId} joined room`);
    // Thông báo user online cho tất cả doctor
    io.to('doctor_room').emit('user_online', { userId: socket.userId });
  } else if (socket.role === 'doctor') {
    doctorSockets.set(socket.userId, socket);
    // Tham gia vào room của doctor
    socket.join(`doctor_${socket.userId}`);
    console.log(`Doctor ${socket.userId} joined room doctor`);
    // Tham gia vào room chung của doctor
    socket.join('doctor_room');
    // Thông báo doctor online cho tất cả user
    io.emit('doctor_online', { doctorId: socket.userId });
  } else if (socket.role === 'admin') {
    // Tham gia vào room của admin
    socket.join(`user_${socket.userId}`);
  }

  // Tham gia vào các room chat của user/doctor
  socket.on('join_chat', (chatId) => {
    socket.join(chatId);
    console.log(`${socket.role} ${socket.userId} and ${socket.userId} joined chat ${chatId}`);
    
  });

  // Rời khỏi room chat
  socket.on('leave_chat', (chatId) => {
    socket.leave(chatId);
    console.log(`${socket.role} ${socket.userId} left chat ${chatId}`);
  });

  // Xử lý gửi tin nhắn mới
  socket.on('send_message', async (data) => {
    try {
      const { chatId, content, image } = data;
      const chat = await Chat.findById(chatId).populate('userId').populate('doctorId');
      
      if (!chat) {
        return socket.emit('error', { message: 'Chat không tồn tại' });
      }

      // Xác định người gửi và người nhận
      let sender, senderModel, receiver, receiverModel;
      
      if (socket.role === 'user') {
        sender = socket.userId;
        senderModel = 'User';
        receiver = chat.doctorId._id;
        receiverModel = 'Doctor';
        
        if (chat.userId._id.toString() !== socket.userId) {
          return socket.emit('error', { message: 'Bạn không có quyền gửi tin nhắn trong chat này' });
        }
      } else if (socket.role === 'doctor') {
        sender = socket.userId;
        senderModel = 'Doctor';
        receiver = chat.userId._id;
        receiverModel = 'User';
        
        if (chat.doctorId._id.toString() !== socket.userId) {
          return socket.emit('error', { message: 'Bạn không có quyền gửi tin nhắn trong chat này' });
        }
      }

      const newMessage = new Message({
        sender,
        senderModel,
        receiver,
        receiverModel,
        content,
        image,
        chatId
      });

      await newMessage.save();
      chat.messages.push(newMessage._id);
      chat.lastMessage = {
        content: content || 'Đã gửi một hình ảnh',
        timestamp: newMessage.createdAt
      };
      chat.updatedAt = new Date();
      await chat.save();

      // Gửi tin nhắn đến tất cả client trong room của chat
      const messageData = {
        _id: newMessage._id,
        chatId,
        content,
        image,
        sender: {
          id: sender,
          model: senderModel
        },
        receiver: {
          id: receiver,
          model: receiverModel
        },
        createdAt: newMessage.createdAt,
        isRead: false
      };
      console.log('messageData', messageData);
      io.to(chatId).emit('new_message', messageData);
      
    } catch (error) {
      console.error('Lỗi khi xử lý tin nhắn:', error);
      socket.emit('error', { message: 'Lỗi khi gửi tin nhắn' });
    }
  });

  // Xử lý ngắt kết nối
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.userId, socket.role);
    
    // Xóa socket khỏi Map và thông báo offline
    if (socket.role === 'user') {
      userSockets.delete(socket.userId);
      io.to('doctor_room').emit('user_offline', { userId: socket.userId });
    } else if (socket.role === 'doctor') {
      doctorSockets.delete(socket.userId);
      io.emit('doctor_offline', { doctorId: socket.userId });
    }
  });

  // Video call events
  socket.on('join_video_call', async (data, callback) => {
    const { consultationId } = data;
    
    if (!consultationId) {
      console.error('=== VIDEO CALL ERROR ===');
      console.error('Consultation ID is undefined');
      console.error('User ID:', socket.userId);
      console.error('Role:', socket.role);
      console.error('Socket ID:', socket.id);
      if (callback) {
        callback({ success: false, message: 'Consultation ID is required' });
      }
      socket.emit('error', { message: 'Consultation ID is required' });
      return;
    }

    try {
      // Lấy thông tin cuộc tư vấn từ database
      const consultation = await Consultation.findById(consultationId);
      if (!consultation) {
        throw new Error('Consultation not found');
      }

      // Kiểm tra thời gian
      if (!isConsultationTime(consultation.consultationDate)) {
        throw new Error('Not consultation time');
      }

      // Tạo hoặc lấy phòng
      let roomId = `video_call_${consultationId}`;
      if (!videoCallRooms.has(roomId)) {
        roomId = createVideoCallRoom(consultationId, consultation.consultationDate);
      }

      const room = videoCallRooms.get(roomId);
      
      // Tham gia vào room video call
      socket.join(roomId);
      room.participants.add(socket.id);
      
      console.log('=== VIDEO CALL JOIN ===');
      console.log(`Room ID: ${roomId}`);
      console.log(`User ID: ${socket.userId}`);
      console.log(`Role: ${socket.role}`);
      console.log(`Socket ID: ${socket.id}`);
      console.log(`Participants: ${room.participants.size}`);
      console.log('=====================');

      // Thông báo cho người kia biết đã vào phòng
      socket.to(roomId).emit('participant_joined', {
        userId: socket.userId,
        role: socket.role,
        socketId: socket.id
      });

      // Gọi callback để thông báo thành công
      if (callback) {
        callback({ 
          success: true, 
          roomId: roomId,
          userId: socket.userId,
          role: socket.role,
          socketId: socket.id,
          participants: Array.from(room.participants)
        });
      }
    } catch (error) {
      console.error('=== VIDEO CALL ERROR ===');
      console.error(error.message);
      if (callback) {
        callback({ success: false, message: error.message });
      }
      socket.emit('error', { message: error.message });
    }
  });

  socket.on('leave_video_call', (data) => {
    const { consultationId } = data;
    const roomId = `video_call_${consultationId}`;
    
    // Rời khỏi room video call
    socket.leave(roomId);
    
    // Cập nhật danh sách người tham gia
    const room = videoCallRooms.get(roomId);
    if (room) {
      room.participants.delete(socket.id);
      console.log('=== VIDEO CALL LEAVE ===');
      console.log(`Room ID: ${roomId}`);
      console.log(`User ID: ${socket.userId}`);
      console.log(`Role: ${socket.role}`);
      console.log(`Socket ID: ${socket.id}`);
      console.log(`Remaining participants: ${room.participants.size}`);
      console.log('======================');

      // Thông báo cho người kia biết đã rời phòng
      socket.to(roomId).emit('participant_left', {
        userId: socket.userId,
        role: socket.role,
        socketId: socket.id
      });

      // Nếu không còn người tham gia, xóa phòng
      if (room.participants.size === 0) {
        videoCallRooms.delete(roomId);
        console.log('=== ROOM DELETED ===');
        console.log(`Room ID: ${roomId}`);
      }
    }
  });

  socket.on('video_call_offer', (data) => {
    const { consultationId, offer } = data;
    const roomId = `video_call_${consultationId}`;
    
    console.log('=== VIDEO CALL OFFER ===');
    console.log(`Room ID: ${roomId}`);
    console.log(`From User ID: ${socket.userId}`);
    console.log(`From Role: ${socket.role}`);
    console.log(`From Socket ID: ${socket.id}`);
    console.log('======================');
    
    // Gửi offer đến người kia trong room
    socket.to(roomId).emit('video_call_offer', {
      offer,
      from: socket.userId,
      role: socket.role,
      socketId: socket.id
    });
  });

  socket.on('video_call_answer', (data) => {
    const { consultationId, answer } = data;
    const roomId = `video_call_${consultationId}`;
    
    console.log('=== VIDEO CALL ANSWER ===');
    console.log(`Room ID: ${roomId}`);
    console.log(`From User ID: ${socket.userId}`);
    console.log(`From Role: ${socket.role}`);
    console.log(`From Socket ID: ${socket.id}`);
    console.log('=======================');
    
    // Gửi answer đến người kia trong room
    socket.to(roomId).emit('video_call_answer', {
      answer,
      from: socket.userId,
      role: socket.role,
      socketId: socket.id
    });
  });

  socket.on('video_call_ice_candidate', (data) => {
    const { consultationId, candidate } = data;
    const roomId = `video_call_${consultationId}`;
    
    console.log('=== VIDEO CALL ICE CANDIDATE ===');
    console.log(`Room ID: ${roomId}`);
    console.log(`From User ID: ${socket.userId}`);
    console.log(`From Role: ${socket.role}`);
    console.log(`From Socket ID: ${socket.id}`);
    console.log('=============================');
    
    // Gửi ICE candidate đến người kia trong room
    socket.to(roomId).emit('video_call_ice_candidate', {
      candidate,
      from: socket.userId,
      role: socket.role,
      socketId: socket.id
    });
  });

  socket.on('video_call_end', (data) => {
    const { consultationId } = data;
    const roomId = `video_call_${consultationId}`;
    
    // Thông báo kết thúc cuộc gọi cho tất cả trong room
    io.to(roomId).emit('video_call_ended', {
      by: socket.userId,
      role: socket.role
    });
  });

  socket.on('connect', () => {
    console.log('Client connected with ID:', socket.id);
    console.log('User ID:', socket.userId);
    console.log('Role:', socket.role);
  });

  // socket.on('send_message', (data) => {
  //   console.log('Received message from client:', data);
  //   console.log('hàm này đang hoạt động');
  //   // Xử lý tin nhắn
  // });
});

// Thêm socket.io vào app
app.set('io', io);

app.use(express.json());
app.use(cors({
  origin: true,
  credentials: true,
}));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/api/feedback', feedbackRoutes);
app.use("/api/users", userRoutes);
app.use("/api/news", newsRoutes);
app.use("/api/contact", contactRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/doctors", doctorRoutes);
app.use("/api/specialties", specialtyRoutes);
app.use("/api/consultationList", consultationListRoutes);
app.use("/api/verification", verificationRoutes);
app.use("/api/chat", chatRoutes);
app.use('/api/drugs', drugRoutes);
app.use('/api/medical-record/medications', medicationRoutes);
app.use('/api/medical-record/allergies', allergyRoutes);
app.use('/api/medical-record/vaccinations', vaccinationRoutes);
app.use('/api/medical-record/prescriptions', prescriptionRoutes);
app.use('/api/medical-record/treatments', treatmentRoutes);
app.use('/api/medical-record/symptoms', symptomsRoutes);
app.use('/api/medical-record/lifestyles', lifestyleRoutes);
app.use('/api/medical-record/health-data', healthDataRoutes);
app.use('/api/appointment-schedule', appointmentScheduleRoutes);
app.use('/api/vnpay', vnpayRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/order-types', orderTypeRoutes);
app.use('/api/video-call', videoCallRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/reviews', reviewRoutes);
app.use(fileUpload({
  limits: { fileSize: 10 * 1024 * 1024 },
  useTempFiles: true
}));

app.get("/", (req, res) => res.send("🚀 Server đang chạy!"));

// Kết nối MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('Đã kết nối với MongoDB'))
  .catch((err) => console.error('Lỗi kết nối MongoDB:', err));

const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server chạy tại http://localhost:${PORT}`);
  console.log(`🚀 Socket.IO Server chạy tại ws://localhost:${PORT}`);
});