import mongoose from 'mongoose';

const drugSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  category: {
    type: String,
    required: true,
    trim: true
  },
  type: {
    type: String,
    required: true,
    trim: true
  },
  activeIngredient: {
    type: String,
    required: true,
    trim: true
  },
  manufacturer: {
    type: String,
    required: true,
    trim: true
  },
  uses: {
    type: String,
    required: true,
    trim: true
  },
  dosage: {
    type: String,
    required: true,
    trim: true
  },
  contraindications: {
    type: String,
    required: true,
    trim: true
  },
  sideEffects: {
    type: String,
    required: true,
    trim: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Tạo index để tìm kiếm nhanh hơn
drugSchema.index({ name: 'text', activeIngredient: 'text', uses: 'text' });
drugSchema.index({ category: 1, type: 1 });

const Drug = mongoose.model('Drug', drugSchema);

export default Drug; 