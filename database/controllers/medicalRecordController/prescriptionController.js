import Prescription from '../../models/MedicalRecord/Prescription.js';

// Thêm đơn thuốc mới
export const addPrescription = async (req, res) => {
    try {
        const {  diagnosis, medicines, instructions, notes } = req.body;
        
        const prescription = new Prescription({
            userId: req.user.userId,
            diagnosis,
            medicines,
            instructions,
            notes
        });
        console.log("prescription",prescription);
        await prescription.save();
        res.status(201).json({ message: 'Thêm đơn thuốc thành công', prescription });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi thêm đơn thuốc', error: error.message });
    }
};

export const DoctoraddPrescription = async (req, res) => {
    try {
        const {  patientId ,diagnosis, medicines, instructions, notes } = req.body;
        const prescription = new Prescription({
            userId: patientId,
            doctorId: req.doctor.id,
            diagnosis,
            medicines,
            instructions,
            notes
        });
        console.log("prescription",prescription);
        await prescription.save();
        res.status(201).json({ message: 'Thêm đơn thuốc thành công', prescription });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi thêm đơn thuốc', error: error.message });
    }
};
// Lấy lịch sử đơn thuốc của người dùng
export const getUserPrescriptions = async (req, res) => {
    try {
        const prescriptions = await Prescription.find({ userId: req.user.userId }).sort({ createdAt: -1 });
        res.status(200).json(prescriptions);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy danh sách đơn thuốc', error: error.message });
    }
};
export const DoctorgetUserPrescriptions = async (req, res) => {
    try {
        const id = req.params.id;
        const prescriptions = await Prescription.find({ userId: id }).sort({ createdAt: -1 });
        res.status(200).json(prescriptions);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy danh sách đơn thuốc', error: error.message });
    }
};      
// Cập nhật đơn thuốc
export const updatePrescription = async (req, res) => {
    try {
        const { id } = req.params;
        
        const prescription = await Prescription.findOne({ _id: id, userId: req.user.userId });
        if (!prescription) {
            return res.status(404).json({ message: 'Không tìm thấy đơn thuốc' });
        }

        const updatedPrescription = await Prescription.findByIdAndUpdate(
            id,
            { $set: req.body },
            { new: true }
        );

        res.status(200).json({ message: 'Cập nhật đơn thuốc thành công', prescription: updatedPrescription });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi cập nhật đơn thuốc', error: error.message });
    }
};

// Xóa đơn thuốc
export const deletePrescription = async (req, res) => {
    try {
        const { id } = req.params;

        const prescription = await Prescription.findOne({ _id: id, userId: req.user.userId });
        if (!prescription) {
            return res.status(404).json({ message: 'Không tìm thấy đơn thuốc' });
        }

        await Prescription.findByIdAndDelete(id);
        res.status(200).json({ message: 'Xóa đơn thuốc thành công' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi xóa đơn thuốc', error: error.message });
    }
}; 