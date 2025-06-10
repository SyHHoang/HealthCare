import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const doctorSchema = new mongoose.Schema({
  fullName: {
    type: String,
    trim: true
  },
  fcmTokens: {
    web: {
      type: String,
      default: ''
    },
    mobile: {
      type: String,
      default: ''
    }
  },
  notificationsEnabled: {
    type: Boolean,
    default: true
  },
  email: {
    type: String,
    required: [true, 'Vui lòng nhập email'],
    unique: true,
    trim: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Vui lòng nhập email hợp lệ']
  },
  phone: {
    type: String,
    trim: true,
    match: [/^[0-9]{10}$/, 'Vui lòng nhập số điện thoại hợp lệ']
  },
  address: {
    type: String,
    trim: true
  },
  specialty: {
    type: String,
    default: ''
  },
  otherSpecialties: {
    type: String,
    trim: true
  },
  academicTitle:{//học hàm
    type:String,
    trim:true
  },
  education: {
    type: String,
    trim: true
  },
  graduationYear: {
    type: Number,
    min: [1900, 'Năm tốt nghiệp không hợp lệ'],
    max: [new Date().getFullYear(), 'Năm tốt nghiệp không hợp lệ']
  },
  licenseNumber: {
    type: String,
    trim: true
  },
  experience: {
    type: Number,
    min: [0, 'Số năm kinh nghiệm không hợp lệ']
  },
  currentWorkplace: {
    type: String,
    trim: true
  },
  avatar: {
    type: String,
    default: '',
  },
  imageId: {
    type: String,
    default: ''
  },
  delete_token: {
    type: String,
    default: ''
  },
  password: {
    type: String,
    required: [true, 'Vui lòng nhập mật khẩu'],
    minlength: [6, 'Mật khẩu phải có ít nhất 6 ký tự'],
    select: false
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  role: {
    type: String,
    default: 'doctor'
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'pending','pending processing'],
    default: 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  schedule: {
    type: Map,
    of: [{
      startTime: {
        type: String,
        required: true
      },
    }],
    default: new Map()
  },
  verifiID: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'VerificationRequest',
    default: null
  },
});
// Phương thức kiểm tra mật khẩu
const Doctor = mongoose.model('Doctor', doctorSchema);

export default Doctor; 