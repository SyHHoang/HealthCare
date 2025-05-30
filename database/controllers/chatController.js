import Chat from '../models/Chat.js';
import ConsultationList from '../models/ConsultationList.js';
import User from '../models/User.js';
import Doctor from '../models/Doctor.js';
import Message from '../models/Message.js';

// Lấy danh sách chat của user
export const getUserChats = async (req, res) => {
  try {
    const userId1 = req.user.userId;
    //console.log("userId1",userId1)
    const chats = await Chat.find({ userId:userId1 })
      .populate('doctorId', 'fullName avatar')
      .sort({ updatedAt: -1 });
    //console.log("chat của user",chats)
    res.status(200).json(chats);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Tạo chat mới
export const createChat = async (req, res) => {
  try {
    const { doctorId } = req.body;
    const userId = req.user.userId;

    // Kiểm tra xem chat đã tồn tại chưa
    const existingChat = await Chat.findOne({
      $or: [
        { userId, doctorId },
        { userId: doctorId, doctorId: userId }
      ]
    });

    if (existingChat) {
      return res.status(200).json(existingChat);
    }

    const newChat = new Chat({
      userId,
      doctorId,
      messages: []
    });

    await newChat.save();
    res.status(201).json(newChat);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy tất cả chat của doctor
export const getDoctorChats = async (req, res) => {
  try {
    const doctorId1 = req.doctor.id;
    const chats = await Chat.find({ doctorId: doctorId1 })
      .populate('userId', 'fullname avatar')
      .sort({ updatedAt: -1 });
   //console.log("chat của bác sĩ",chats)
    res.status(200).json(chats);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Gửi tin nhắn
export const sendMessage = async (req, res) => {
  try {
    const { chatId, content } = req.body;
    const chat = await Chat.findById(chatId).populate('userId').populate('doctorId');

    if (!chat) {
      return res.status(404).json({ message: 'Chat không tồn tại' });
    }

    // Xác định người gửi và người nhận
    let sender, senderModel, receiver, receiverModel;
    
    if (req.user) {
      sender = req.user.userId;
      senderModel = 'User';
      receiver = chat.doctorId._id;
      receiverModel = 'Doctor';
      
      if (chat.userId._id.toString() !== req.user.userId) {
        return res.status(403).json({ message: 'Bạn không có quyền gửi tin nhắn trong chat này' });
      }
    } else if (req.doctor) {
      sender = req.doctor._id;
      senderModel = 'Doctor';
      receiver = chat.userId._id;
      receiverModel = 'User';
      
      if (chat.doctorId._id.toString() !== req.doctor._id.toString()) {
        return res.status(403).json({ message: 'Bạn không có quyền gửi tin nhắn trong chat này' });
      }
    }

    const newMessage = new Message({
      sender,
      senderModel,
      receiver,
      receiverModel,
      content,
      chatId
    });

    await newMessage.save();
    chat.messages.push(newMessage._id);
    chat.lastMessage = {
      content,
      timestamp: newMessage.createdAt
    };
    chat.updatedAt = new Date();
    await chat.save();

    // Gửi tin nhắn qua socket
    const io = req.app.get('io');
    const messageData = {
      _id: newMessage._id,
      chatId,
      content,
      sender: {
        id: sender,
        model: senderModel
      },
      receiver: {
        id: receiver,
        model: receiverModel
      },
      createdAt: newMessage.createdAt
    };
    // Gửi tin nhắn đến tất cả client trong room của chat
    io.to(chatId).emit('new_message', messageData);

    res.status(201).json(messageData);
  } catch (error) {
    console.error('Lỗi khi gửi tin nhắn:', error);
    res.status(500).json({ message: error.message });
  }
};

// Lấy tin nhắn của một chat
export const getChatMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const userId = req.user ? req.user.userId : null;
    const doctorId = req.doctor ? req.doctor.id : null;
    const limit = parseInt(req.query.limit) || 10;
    const page = parseInt(req.query.page) || 1;
    const skip = (page - 1) * limit;
    const sort = req.query.sort || 'desc'; // Mặc định lấy tin nhắn mới nhất trước

    // Kiểm tra quyền truy cập
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat không tồn tại' });
    }

    if (userId && chat.userId.toString() !== userId) {
      return res.status(403).json({ message: 'Bạn không có quyền xem tin nhắn của chat này' });
    }

    if (doctorId && chat.doctorId.toString() !== doctorId) {
      return res.status(403).json({ message: 'Bạn không có quyền xem tin nhắn của chat này' });
    }

    // Lấy tin nhắn dựa vào messageId trong chat
    const messages = await Message.find({
      _id: { $in: chat.messages }
    })
    .sort({ createdAt: -1 })  // Sắp xếp theo thứ tự cũ nhất trước
    .skip(skip)
    .limit(limit);
    console.log("messages",messages)
    res.status(200).json(messages);
  } catch (error) {
    console.error('Lỗi khi lấy tin nhắn:', error);
    res.status(500).json({ message: error.message });
  }
};

// Tìm kiếm tin nhắn trong chat
export const searchMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { query } = req.query;
    const userId = req.user?.userId || req.doctor?.id;

    // Kiểm tra quyền truy cập
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat không tồn tại' });
    }

    if (userId && chat.userId.toString() !== userId && chat.doctorId.toString() !== userId) {
      return res.status(403).json({ message: 'Bạn không có quyền tìm kiếm trong chat này' });
    }

    // Tìm kiếm tin nhắn
    const messages = await Message.find({
      chatId,
      content: { $regex: query, $options: 'i' }
    })
    .sort({ createdAt: -1 })
    .limit(20);

    res.status(200).json(messages);
  } catch (error) {
    console.error('Lỗi khi tìm kiếm tin nhắn:', error);
    res.status(500).json({ message: error.message });
  }
};

// Lấy danh sách ảnh trong chat
export const getChatImages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const userId = req.user?.userId || req.doctor?.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Kiểm tra quyền truy cập
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat không tồn tại' });
    }

    if (userId && chat.userId.toString() !== userId && chat.doctorId.toString() !== userId) {
      return res.status(403).json({ message: 'Bạn không có quyền xem ảnh trong chat này' });
    }

    // Lấy tin nhắn có ảnh
    const messages = await Message.find({
      chatId,
      image: { $exists: true, $ne: null }
    })
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

    // Đếm tổng số ảnh
    const total = await Message.countDocuments({
      chatId,
      image: { $exists: true, $ne: null }
    });

    res.status(200).json({
      messages,
      total,
      currentPage: page,
      totalPages: Math.ceil(total / limit)
    });
  } catch (error) {
    console.error('Lỗi khi lấy danh sách ảnh:', error);
    res.status(500).json({ message: error.message });
  }
};

// Lấy tin nhắn cũ hơn của một chat
export const getOlderMessages = async (req, res) => {
  try {
    console.log("hàm đang chạy")
    const { chatId } = req.params;
    const { beforeId } = req.query;
    const userId = req.user ? req.user.userId : null;
    const doctorId = req.doctor ? req.doctor.id : null;
    const limit = parseInt(req.query.limit) || 10;
    console.log("chatId", chatId,"beforeId",beforeId,"userId",userId,"doctorId",doctorId )
    // Kiểm tra quyền truy cập
    const chat = await Chat.findById(chatId);
    console.log("chat=========", chat)
    if (!chat) {
      return res.status(404).json({ message: 'Chat không tồn tại' });
    }
    console.log("=============================================== tin nhắn cũ0")
    if (userId && chat.userId.toString() !== userId) {
      return res.status(403).json({ message: 'Bạn không có quyền xem tin nhắn của chat này' });
    }

    if (doctorId && chat.doctorId.toString() !== doctorId) {
      return res.status(403).json({ message: 'Bạn không có quyền xem tin nhắn của chat này' });
    }
    console.log("=============================================== tin nhắn cũ11")
    // Tìm vị trí của tin nhắn có ID beforeId trong mảng messages
    const beforeIndex = chat.messages.findIndex(msg => msg.toString() === beforeId);
    if (beforeIndex === -1) {
      return res.status(404).json({ message: 'Không tìm thấy tin nhắn' });
    }

    // Lấy các tin nhắn cũ hơn từ mảng messages (ở trước vị trí beforeIndex)
    const olderMessageIds = chat.messages.slice(
      Math.max(0, beforeIndex - limit), // Lấy từ vị trí trước beforeIndex
      beforeIndex // Đến vị trí beforeIndex
    );
    console.log("=============================================== tin nhắn cũ22")
    // Lấy thông tin chi tiết của các tin nhắn
    const messages = await Message.find({
      _id: { $in: olderMessageIds }
    }).sort({ createdAt: 1 }); // Sắp xếp từ cũ đến mới

    res.status(200).json(messages);
  } catch (error) {
    console.error('Lỗi khi lấy tin nhắn cũ:', error);
    res.status(500).json({ message: error.message });
  }
}; 