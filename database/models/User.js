import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  fullname: {
    type: String,
    required: false,
    default: ''
  },
  fcmTokens: [{
    type: String,
    default: []
  }],
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  avatar: {
    type: String,
    default: 'https://ibb.co/WWjN48Gf'
  },
  imageId: {
    type: String,
    default: ''
  },
  delete_token: {
    type: String,
    default: ''
  },
  age: {
    type: Number,
    required: false
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: false
  },
  phone: {
    type: String,
    required: false
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  isActive: {
    type: Boolean,
    default: true
  },
  notificationSettings: {
    systemNotifications: {
      type: Boolean,
      default: true
    },
    paymentNotifications: {
      type: Boolean,
      default: true
    },
    messageNotifications: {
      type: Boolean,
      default: true
    },
    appointmentNotifications: {
      type: Boolean,
      default: true
    }
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Middleware để tự động cập nhật updatedAt
userSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

const User = mongoose.model('User', userSchema);

export default User; 