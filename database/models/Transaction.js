import mongoose from 'mongoose';

const transactionSchema = new mongoose.Schema({
    txnRef: {
        type: String,
        required: true,
    },
    amount: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['success', 'failed', 'pending', 'paid_to_doctor'],
        default: 'pending'
    },
    paymentMethod: {
        type: String,
        default: 'VNPay'
    },
    quantity:{
        type:Number,
        default: 1
    },
    orderType: {
        type: String,
        required: true
    },
    bankCode: String,
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
    consultationId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Consultation'
    },
    responseCode: String,
    transactionDate: {
        type: Date,
        default: Date.now
    },
    paymentDetails: {
        type: Object
    }
}, {
    timestamps: true
});

export default mongoose.model('Transaction', transactionSchema); 