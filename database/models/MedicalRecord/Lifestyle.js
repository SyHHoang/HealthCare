import { Schema, model } from 'mongoose';

const lifestyleSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  activityType: {
    type: String,
    required: true,
    enum: ['Tập thể dục', 'Ăn uống', 'Giấc ngủ', 'Hút thuốc', 'Uống rượu', 'Khác']
  },
  description: {
    type: String,
    required: true
  },
  frequency: {
    type: String,
    required: true,
    enum: ['Hàng ngày', 'Hàng tuần', 'Hàng tháng', 'Thỉnh thoảng']
  },
  duration: {
    type: String
  },
  startDate: {
    type: Date,
  },
  notes: {
    type: String
  }
}, {
  timestamps: true
});

export default model('Lifestyle', lifestyleSchema); 