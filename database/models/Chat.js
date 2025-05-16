import mongoose from 'mongoose';

const chatSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true
  },
  messages: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message'
  }],
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Tạo index để đảm bảo mỗi cặp userId-doctorId là duy nhất
chatSchema.index({ userId: 1, doctorId: 1 }, { unique: true });

const Chat = mongoose.model('Chat', chatSchema);

export default Chat; 