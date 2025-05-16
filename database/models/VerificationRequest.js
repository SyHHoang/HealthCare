import mongoose from 'mongoose';

const verificationRequestSchema = new mongoose.Schema({
  doctor: {
    type: String,
    required: true
  },
  fullName: {
    type: String,
    required: true
  },
  email: {
    type: String, 
    required: true,
  },
  phone: {
    type: String,
    required: true
  },
  avatar: {
    type: String
  },
  specialty: {
    type: String,
    required: true
  },
  otherSpecialties: {
    type: String
  },
  experience: {
    type: Number,
    required: true
  },
  currentWorkplace: {
    type: String,
    required: true
  },
  education: {
    type: String,
    required: true
  },
  graduationYear: {
    type: Number,
    required: true
  },
  licenseNumber: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'pending processing'],
    default: 'pending'
  },
  submittedAt: {
    type: Date,
    default: Date.now
  },
  reviewedAt: {
    type: Date
  },
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  rejectionReason: {
    type: String
  }
});

// Tạo index cho trường doctorId để tìm kiếm nhanh hơn
verificationRequestSchema.index({ doctorId: 1 });

// Tạo index cho trường status để lọc nhanh hơn
verificationRequestSchema.index({ status: 1 });

const VerificationRequest = mongoose.model('VerificationRequest', verificationRequestSchema);

export default VerificationRequest; 