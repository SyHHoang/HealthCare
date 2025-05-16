import Vaccination from '../../models/MedicalRecord/Vaccination.js';

// Thêm thông tin tiêm chủng mới
export const addVaccination = async (req, res) => {
    try {
        const { vaccineName, vaccineType, dateAdministered, nextDueDate, sideEffects, notes } = req.body;
        const userId = req.user.userId;

        const vaccination = new Vaccination({
            userId,
            vaccineName,
            vaccineType,
            dateAdministered,
            nextDueDate,
            sideEffects,
            notes
        });

        await vaccination.save();
        res.status(201).json({ message: 'Thêm thông tin tiêm chủng thành công', vaccination });
    } catch (error) {
        console.error('Lỗi khi thêm thông tin tiêm chủng:', error);
        res.status(500).json({ message: 'Lỗi khi thêm thông tin tiêm chủng' });
    }
};

// Lấy lịch sử tiêm chủng của người dùng
export const getUserVaccinations = async (req, res) => {
    try {
        const userId = req.user.userId;
        const vaccinations = await Vaccination.find({ userId })
            .sort({ dateAdministered: -1 });
        res.json(vaccinations);
    } catch (error) {
        console.error('Lỗi khi lấy thông tin tiêm chủng:', error);
        res.status(500).json({ message: 'Lỗi khi lấy thông tin tiêm chủng' });
    }
};
export const DoctorgetUserVaccinations = async (req, res) => {
    try {
        const id = req.params.id;
        const vaccinations = await Vaccination.find({ userId: id }).sort({ dateAdministered: -1 });
        res.json(vaccinations);
    } catch (error) {
        console.error('Lỗi khi lấy thông tin tiêm chủng:', error);
        res.status(500).json({ message: 'Lỗi khi lấy thông tin tiêm chủng' });
    }
}   
// Cập nhật thông tin tiêm chủng
export const updateVaccination = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, dateAdministered, nextDueDate, notes } = req.body;
        const userId = req.user.userId;

        const vaccination = await Vaccination.findOneAndUpdate(
            { _id: id, userId },
            { name, dateAdministered, nextDueDate, notes },
            { new: true }
        );

        if (!vaccination) {
            return res.status(404).json({ message: 'Không tìm thấy thông tin tiêm chủng' });
        }

        res.json({ message: 'Cập nhật thông tin tiêm chủng thành công', vaccination });
    } catch (error) {
        console.error('Lỗi khi cập nhật thông tin tiêm chủng:', error);
        res.status(500).json({ message: 'Lỗi khi cập nhật thông tin tiêm chủng' });
    }
};

// Xóa thông tin tiêm chủng
export const deleteVaccination = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.userId;

        const vaccination = await Vaccination.findOneAndDelete({ _id: id, userId });

        if (!vaccination) {
            return res.status(404).json({ message: 'Không tìm thấy thông tin tiêm chủng' });
        }

        res.json({ message: 'Xóa thông tin tiêm chủng thành công' });
    } catch (error) {
        console.error('Lỗi khi xóa thông tin tiêm chủng:', error);
        res.status(500).json({ message: 'Lỗi khi xóa thông tin tiêm chủng' });
    }
}; 