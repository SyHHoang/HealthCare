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
    endTime: {
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

// Cập nhật updatedAt và tính endTime trước khi lưu
consultationSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    
    // Luôn tính lại endTime là consultationDate + 30 phút
    if (this.consultationDate) {
        this.endTime = new Date(this.consultationDate.getTime() + 30 * 60 * 1000);
    }
    
    next();
});

const Consultation = mongoose.model('Consultation', consultationSchema);

export default Consultation; 