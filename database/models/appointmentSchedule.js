import mongoose from 'mongoose';

const appointmentScheduleSchema = new mongoose.Schema({
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
  startTime: {
    type: String,
    required: true
  },
  date: {
    type: String,
    required: true
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled','completed','waiting','missed'],
    default: 'pending'
  }
}, {
  timestamps: true
});



const AppointmentSchedule = mongoose.model('AppointmentSchedule', appointmentScheduleSchema);

export default AppointmentSchedule; 