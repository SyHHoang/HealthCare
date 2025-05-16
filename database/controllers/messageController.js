import Message from '../models/Message.js';

// Gửi tin nhắn
export const sendMessage = async (req, res) => {
  try {
    const { receiverId, content } = req.body;
    const senderId = req.user?.userId || req.doctor?._id;
    const senderModel = req.user ? 'User' : 'Doctor';
    const receiverModel = req.user ? 'Doctor' : 'User';

    const message = await Message.create({
      sender: senderId,
      senderModel,
      receiver: receiverId,
      receiverModel,
      content
    });

    // Emit socket event
    req.io.to(receiverId.toString()).emit('newMessage', message);

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi gửi tin nhắn', error: error.message });
  }
};

// Lấy lịch sử chat giữa user và doctor
export const getChatHistory = async (req, res) => {
  try {
    const { partnerId } = req.params;
    const userId = req.user?.userId || req.doctor?._id;
    const userModel = req.user ? 'User' : 'Doctor';
    const partnerModel = req.user ? 'Doctor' : 'User';

    const messages = await Message.find({
      $or: [
        { sender: userId, receiver: partnerId, senderModel: userModel, receiverModel: partnerModel },
        { sender: partnerId, receiver: userId, senderModel: partnerModel, receiverModel: userModel }
      ]
    }).sort({ createdAt: 1 });
    console.log("=============================messages2",messages)
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy lịch sử chat', error: error.message });
  }
};

// Đánh dấu tin nhắn đã đọc
export const markAsRead = async (req, res) => {
  try {
    const { messageId } = req.params;
    const userId = req.user?.userId || req.doctor?._id;

    const message = await Message.findOneAndUpdate(
      { _id: messageId, receiver: userId },
      { isRead: true },
      { new: true }
    );

    if (!message) {
      return res.status(404).json({ message: 'Không tìm thấy tin nhắn' });
    }

    res.json(message);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi cập nhật trạng thái tin nhắn', error: error.message });
  }
};

// Lấy danh sách tin nhắn chưa đọc
export const getUnreadMessages = async (req, res) => {
  try {
    const userId = req.user?.userId || req.doctor?._id;
    const userModel = req.user ? 'User' : 'Doctor';

    const unreadMessages = await Message.find({
      receiver: userId,
      receiverModel: userModel,
      isRead: false
    }).populate('sender', 'name');

    res.json(unreadMessages);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy tin nhắn chưa đọc', error: error.message });
  }
}; 