import Chat from '../models/Chat.js';
import ConsultationList from '../models/ConsultationList.js';

// Lấy danh sách chat của doctor
export const getDoctorChats = async (req, res) => {
  try {
    const doctorId = req.doctor.id;
    console.log("doctorId",doctorId)
    // Lấy danh sách chat của doctor
    const chats = await Chat.find({ doctorId })
      .populate('userId', 'name avatar')
      .sort({ lastMessageTime: -1 });

    res.json(chats);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Gửi tin nhắn
export const sendMessage = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { content } = req.body;
    const doctorId = req.doctor.id;

    // Kiểm tra chat có tồn tại không
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat không tồn tại' });
    }

    // Kiểm tra doctor có quyền gửi tin nhắn trong chat này không
    if (chat.doctorId.toString() !== doctorId) {
      return res.status(403).json({ message: 'Bạn không có quyền gửi tin nhắn trong chat này' });
    }

    // Thêm tin nhắn mới
    chat.messages.push({
      sender: 'doctor',
      content
    });

    // Cập nhật tin nhắn cuối cùng
    chat.lastMessage = content;
    chat.lastMessageTime = new Date();

    await chat.save();

    res.json(chat);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}; 