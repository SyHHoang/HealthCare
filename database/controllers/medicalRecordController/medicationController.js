import Medication from '../../models/MedicalRecord/Medication.js';

// Thêm thuốc mới
export async function addMedication(req, res) {
    try {
        const { name, dosage, frequency, startDate, endDate, purpose, sideEffects, notes } = req.body;
        const newMedication = new Medication({
            userId: req.user.userId,
            name,
            dosage,
            frequency,
            startDate,
            endDate,
            purpose,
            sideEffects,
            notes
        });
        const result = await newMedication.save();
        console.log(result);
        res.status(201).json({ message: 'Thêm thuốc thành công', data: newMedication });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}

// Lấy danh sách thuốc của người dùng
export async function getUserMedications(req, res) {
    try {
        const medications = await find({ userId: req.user.userId })
            .sort({ startDate: -1 });
        res.status(200).json(medications);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}
export async function DoctorgetUserMedications(req, res) {
    try {
        const id = req.params.id;
        const medications = await find({ userId: id })
            .sort({ startDate: -1 });
        res.status(200).json(medications);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}
// Cập nhật thuốc
export async function updateMedication(req, res) {
    try {
        const { id } = req.params;
        const { name, dosage, frequency, startDate, endDate, purpose, sideEffects, notes, isActive } = req.body;
        
        const updatedMedication = await findOneAndUpdate(
            { _id: id, userId: req.user.userId },
            { name, dosage, frequency, startDate, endDate, purpose, sideEffects, notes, isActive },
            { new: true }
        );
        
        if (!updatedMedication) {
            return res.status(404).json({ message: 'Không tìm thấy thuốc' });
        }
        
        res.status(200).json({ message: 'Cập nhật thành công', data: updatedMedication });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}

// Xóa thuốc
export async function deleteMedication(req, res) {
    try {
        const { id } = req.params;
        const deletedMedication = await findOneAndDelete({ 
            _id: id, 
            userId: req.user.userId
        });
        
        if (!deletedMedication) {
            return res.status(404).json({ message: 'Không tìm thấy thuốc' });
        }
        
        res.status(200).json({ message: 'Xóa thành công' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
} 