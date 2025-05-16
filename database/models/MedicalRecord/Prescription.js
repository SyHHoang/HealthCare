import { Schema, model } from 'mongoose';

const prescriptionSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    doctorId: {
        type: Schema.Types.ObjectId,
        ref: 'Doctor',
    },
    diagnosis: {//chẩn đoán
        type: String,
        required: true
    },
    medicines: [{
        name: {
            type: String,
            required: true
        },
        dosage: {
            type: String,
            required: true
        },
        frequency: {
            type: String,
            required: true
        },
        duration: {
            type: String,
            required: true
        },
        notes: String
    }],
    notes: String,
    date: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

export default model('Prescription', prescriptionSchema); 