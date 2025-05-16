import mongoose from 'mongoose';

const consultationListSchema = new mongoose.Schema({
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
  doctorEmail: {
    type: String,
    trim: true
  },
  call:{
    type:Number,
    default: 1
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  StartDate:{
    type: Date,
    default: Date.now
  },
  EndDate: {
    type: Date,
    default: function() {
      const startDate = this.StartDate || Date.now();
      return new Date(startDate.getTime() + 14 * 24 * 60 * 60 * 1000);
    }
  },
});

// Tạo index để đảm bảo mỗi cặp userId-doctorId là duy nhất
consultationListSchema.index({ userId: 1, doctorId: 1 }, { unique: true });

const ConsultationList = mongoose.model('ConsultationList', consultationListSchema);

export default ConsultationList; 