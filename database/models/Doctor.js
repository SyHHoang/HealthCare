import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const doctorSchema = new mongoose.Schema({
  fullName: {
    type: String,
    required: [true, 'Vui lòng nhập họ và tên'],
    trim: true
  },
  fcmToken: {
    type: String,
    default: null
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
    required: [true, 'Vui lòng nhập số điện thoại'],
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
  price: {
    type: Number,
    required: true,
    min: 0,
    default: 0
    },
  verifiID: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'VerificationRequest',
    default: null
  },
});

// Hash mật khẩu trước khi lưu
doctorSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    return next();
  }
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Phương thức kiểm tra mật khẩu
doctorSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

const Doctor = mongoose.model('Doctor', doctorSchema);

export default Doctor; 