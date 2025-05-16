import { Schema, model } from 'mongoose';

const healthDataSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  dataType: {
    type: String,
    required: true,
    enum: ['Huyết áp', 'Đường huyết', 'Nhịp tim', 'Cân nặng', 'Chiều cao', 'Nhiệt độ', 'Khác']
  },
  value: {
    type: Number,
    required: true
  },
  unit: {
    type: String,
    required: true
  },
  measurementTime: {
    type: Date,
    required: true
  },
  measurementLocation: {
    type: String
  },
  notes: {
    type: String
  }
}, {
  timestamps: true
});

export default model('HealthData', healthDataSchema); 