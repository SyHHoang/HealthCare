import mongoose from 'mongoose';

const consultationSchema = new mongoose.Schema({
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
    consultationDate: {
        type: Date
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

// Cập nhật updatedAt trước khi lưu
consultationSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
});

const Consultation = mongoose.model('Consultation', consultationSchema);

export default Consultation; 