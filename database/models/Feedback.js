import mongoose from 'mongoose';

const feedbackSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  rating: { type: Number, required: true, min: 1, max: 5 },
  service: { type: String, required: true, enum: ['ai', 'online', 'appointment', 'other'] },
  pros: { type: String },
  cons: { type: String },
  suggestions: { type: String },
  email: { type: String },
  phone: { type: String },
  images: [{ type: String }],
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model('Feedback', feedbackSchema); 