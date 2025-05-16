import mongoose from 'mongoose';

const orderTypeSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  price: {
    type: Number,
    required: true,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updateAt: {
    type: Date,
    default: Date.now
  },
});
// Tạo index để tìm kiếm nhanh hơn
orderTypeSchema.index({ name: 'text' });
const OrderType = mongoose.model('OrderType', orderTypeSchema);

export default OrderType; 