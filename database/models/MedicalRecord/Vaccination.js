import { Schema, model } from 'mongoose';

const vaccinationSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    vaccineName: {
        type: String,
        required: true
    },
    vaccineType: {
        type: String,
        enum: ['Bắt buộc', 'Khuyến nghị', 'Khác'],
        required: true
    },
    dateAdministered: {
        type: Date,
    },
    nextDoseDate: {
        type: Date
    },
    batchNumber: {
        type: String
    },
    manufacturer: {
        type: String
    },
    sideEffects: [{
        description: String,
        severity: {
            type: String,
            enum: ['Nhẹ', 'Trung bình', 'Nặng']
        },
        duration: String
    }],
    notes: String,
    status: {
        type: String,
        enum: ['Đã tiêm', 'Đã hoãn', 'Đã hủy'],
        default: 'Đã tiêm'
    }
}, {
    timestamps: true
});

export default model('Vaccination', vaccinationSchema); 