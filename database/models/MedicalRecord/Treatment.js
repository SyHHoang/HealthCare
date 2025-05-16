import { Schema, model } from 'mongoose';

const treatmentSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    doctorId: {
        type: Schema.Types.ObjectId,
        ref: 'Doctor',
    },
    diagnosis: {
        type: String,
        required: true
    },
    treatmentPlan: {
        type: String,
        required: true
    },
    startDate: {
        type: Date,
        required: true
    },
    endDate: {
        type: Date
    },
    status: {
        type: String,
        enum: ['Đang điều trị', 'Đã hoàn thành', 'Đã hủy'],
        default: 'Đang điều trị'
    },
    medications: [{
        name: String,
        dosage: String,
        frequency: String,
        duration: String
    }],
    procedures: [{
        name: String,
        date: Date,
        notes: String
    }],
    followUp: {
        date: Date,
        notes: String
    },
    notes: String
}, {
    timestamps: true
});

export default model('Treatment', treatmentSchema); 