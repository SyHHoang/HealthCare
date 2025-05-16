import mongoose from 'mongoose';

const contactSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    trim: true
  },
  phone: {
    type: String,
    trim: true
  },
  subject: {
    type: String,
    trim: true
  },
  message: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['new', 'in-progress', 'completed'],
    default: 'new'
  },
  isDeleted: {
    type: Boolean,
    default: false
  },
  replies: [{
    message: String,
    sentAt: {
      type: Date,
      default: Date.now
    }
  }]
}, { timestamps: true });

const Contact = mongoose.model('Contact', contactSchema);

export default Contact; 