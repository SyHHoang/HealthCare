import mongoose from 'mongoose';

const symptomSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    symptoms: {
        type: String,
        required: true
    },
    duration: {
        type: String,
        required: true
    },
    severity: {
        type: String,
        enum: ['Nhẹ', 'Trung bình', 'Nặng'],
        required: true
    },
    startDate: {
        type: Date,
        required: true
    },
    notes: {
        type: String
    }
}, {
    timestamps: true
});

const Symptom = mongoose.model('Symptom', symptomSchema);

export default Symptom; 