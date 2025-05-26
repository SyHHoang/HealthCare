import mongoose from 'mongoose';

const reviewSchema = new mongoose.Schema({
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
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  content: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Tạo index để đảm bảo mỗi người dùng chỉ đánh giá một bác sĩ một lần
reviewSchema.index({ userId: 1, doctorId: 1 }, { unique: true });

const Review = mongoose.model('Review', reviewSchema);

export default Review; 