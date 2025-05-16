import Symptom from '../../models/MedicalRecord/Symptom.js';
import mongoose from 'mongoose';

// Thêm triệu chứng mới
export const addSymptom = async (req, res) => {
    try {
        const { symptoms, severity, startDate, notes, duration } = req.body;
        console.log("req.body",req.body);
        const symptom = new Symptom({
            userId: req.user.userId,
            symptoms,
            duration: duration,
            severity,
            startDate: new Date(startDate),
            notes
        });

        await symptom.save();
        res.status(201).json({ message: 'Thêm triệu chứng thành công', data: symptom });
    } catch (error) {
        console.error('Error in addSymptom:', error);
        res.status(500).json({ message: 'Lỗi khi thêm triệu chứng', error: error.message });
    }
};

// Lấy danh sách triệu chứng của người dùng
export const getUserSymptoms = async (req, res) => {
    try {
        const symptoms = await Symptom.find({ userId: req.user.userId }).sort({ createdAt: -1 });
        console.log("symptoms",symptoms);
        res.status(200).json({ data: symptoms });
    } catch (error) {
        console.error('Error in getUserSymptoms:', error);
        res.status(500).json({ message: 'Lỗi khi lấy danh sách triệu chứng', error: error.message });
    }
};

// Lấy danh sách triệu chứng của bệnh nhân (cho bác sĩ)
export const getDoctorUserSymptoms = async (req, res) => {
    try {
        const userId = req.params.id;
        const symptoms = await Symptom.find({ userId }).sort({ createdAt: -1 });
        console.log("symptoms",symptoms);
        res.status(200).json({ data: symptoms });
    } catch (error) {
        console.error('Error in getDoctorUserSymptoms:', error);
        res.status(500).json({ message: 'Lỗi khi lấy danh sách triệu chứng', error: error.message });
    }
};

// Cập nhật triệu chứng
export const updateSymptom = async (req, res) => {
    try {
        const { id } = req.params;
        const { symptoms, severity, startDate, notes, duration } = req.body;

        const symptom = await Symptom.findOne({ _id: id, userId: req.user.userId });
        if (!symptom) {
            return res.status(404).json({ message: 'Không tìm thấy triệu chứng' });
        }

        // Validate required fields


        const updatedSymptom = await Symptom.findByIdAndUpdate(
            id,
            {
                symptoms,
                severity,
                startDate: new Date(startDate),
                notes,
                duration
            },
            { new: true }
        );

        res.status(200).json({ message: 'Cập nhật triệu chứng thành công', data: updatedSymptom });
    } catch (error) {
        console.error('Error in updateSymptom:', error);
        res.status(500).json({ message: 'Lỗi khi cập nhật triệu chứng', error: error.message });
    }
};

// Xóa triệu chứng
export const deleteSymptom = async (req, res) => {
    try {
        const { id } = req.params;

        const symptom = await Symptom.findOne({ _id: id, userId: req.user.userId });
        if (!symptom) {
            return res.status(404).json({ message: 'Không tìm thấy triệu chứng' });
        }

        await Symptom.findByIdAndDelete(id);
        res.status(200).json({ message: 'Xóa triệu chứng thành công' });
    } catch (error) {
        console.error('Error in deleteSymptom:', error);
        res.status(500).json({ message: 'Lỗi khi xóa triệu chứng', error: error.message });
    }
}; 