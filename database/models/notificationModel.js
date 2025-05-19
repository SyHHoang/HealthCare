import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['authentication', 'consultation', 'cancel', 'payment_success'],
    default: 'authentication'
  },
  data: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  read: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Index để tối ưu truy vấn
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ read: 1 });

export default mongoose.model('Notification', notificationSchema); 