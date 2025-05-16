import mongoose from 'mongoose';

const allergySchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    allergen: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: ['Thực phẩm', 'Thuốc', 'Môi trường', 'Khác'],
        required: true
    },
    severity: {
        type: String,
        enum: ['Nhẹ', 'Trung bình', 'Nặng', 'Nguy hiểm đến tính mạng'],
        required: true
    },
    symptoms: {
        type: [String],
        required: true
    },
    firstOccurrence: {
        type: Date
    },
    lastOccurrence: {
        type: Date
    },
    treatment: {
        type: String
    },
    notes: {
        type: String
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

const Allergy = mongoose.model('Allergy', allergySchema);

export default Allergy; 