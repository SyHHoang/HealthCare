import mongoose from 'mongoose';

const serviceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true,
    trim: true
  },
  image: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: ['Khám tổng quát', 'Xét nghiệm', 'Chẩn đoán hình ảnh', 'Điều trị', 'Tư vấn']
  },
  price: {
    type: Number,
    required: true
  },
  duration: {
    type: Number, // Thời gian thực hiện (phút)
    required: true
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  status: {
    type: String,
    enum: ['active', 'inactive'],
    default: 'active'
  }
}, {
  timestamps: true
});

const Service = mongoose.model('Service', serviceSchema);

export default Service; 