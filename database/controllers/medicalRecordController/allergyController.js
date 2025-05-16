import Allergy from '../../models/MedicalRecord/Allergy.js';

// Thêm dị ứng mới
export const addAllergy = async (req, res) => {
    try {
        const { allergen, type, severity, symptoms, firstOccurrence, lastOccurrence, treatment, notes, isActive } = req.body;
        console.log(req.body);
        // Validate required fields
        if (!allergen || !type || !severity || !symptoms || symptoms.length === 0) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin bắt buộc' });
        }

        const allergy = new Allergy({
            userId: req.user.userId,
            allergen,
            type,
            severity,
            symptoms: symptoms.filter(s => s.trim() !== ''),
            firstOccurrence: firstOccurrence ? new Date(firstOccurrence) : null,
            lastOccurrence: lastOccurrence ? new Date(lastOccurrence) : null,
            treatment,
            notes,
            isActive: isActive !== undefined ? isActive : true
        });

        await allergy.save();
        res.status(201).json({ message: 'Thêm thông tin dị ứng thành công', allergy });
    } catch (error) {
        console.error('Error in addAllergy:', error);
        res.status(500).json({ message: 'Lỗi khi thêm thông tin dị ứng', error: error.message });
    }
};

// Lấy danh sách dị ứng của người dùng
export const getUserAllergies = async (req, res) => {
    try {
        const allergies = await Allergy.find({ userId: req.user.userId }).sort({ createdAt: -1 });
        res.status(200).json(allergies);
    } catch (error) {
        console.error('Error in getUserAllergies:', error);
        res.status(500).json({ message: 'Lỗi khi lấy thông tin dị ứng', error: error.message });
    }
};
export const DoctorgetUserAllergies = async (req, res) => {
    try {
        const id = req.params.id;
        const allergies = await Allergy.find({ userId: id }).sort({ createdAt: -1 });
        res.status(200).json(allergies);
    } catch (error) {
        console.error('Error in getUserAllergies:', error);
        res.status(500).json({ message: 'Lỗi khi lấy thông tin dị ứng', error: error.message });
    }
};
// Cập nhật dị ứng
export const updateAllergy = async (req, res) => {
    try {
        const { id } = req.params;
        
        const allergy = await Allergy.findOne({ _id: id, userId: req.user.userId });
        if (!allergy) {
            return res.status(404).json({ message: 'Không tìm thấy thông tin dị ứng' });
        }

        // Validate required fields
        if (!req.body.allergen || !req.body.type || !req.body.severity || !req.body.symptoms || req.body.symptoms.length === 0) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin bắt buộc' });
        }

        const updateData = {
            ...req.body,
            symptoms: req.body.symptoms.filter(s => s.trim() !== ''),
            firstOccurrence: req.body.firstOccurrence ? new Date(req.body.firstOccurrence) : null,
            lastOccurrence: req.body.lastOccurrence ? new Date(req.body.lastOccurrence) : null
        };

        const updatedAllergy = await Allergy.findByIdAndUpdate(
            id,
            { $set: updateData },
            { new: true }
        );

        res.status(200).json({ message: 'Cập nhật thông tin dị ứng thành công', allergy: updatedAllergy });
    } catch (error) {
        console.error('Error in updateAllergy:', error);
        res.status(500).json({ message: 'Lỗi khi cập nhật thông tin dị ứng', error: error.message });
    }
};

// Xóa dị ứng
export const deleteAllergy = async (req, res) => {
    try {
        const { id } = req.params;

        const allergy = await Allergy.findOne({ _id: id, userId: req.user.userId });
        if (!allergy) {
            return res.status(404).json({ message: 'Không tìm thấy thông tin dị ứng' });
        }

        await Allergy.findByIdAndDelete(id);
        res.status(200).json({ message: 'Xóa thông tin dị ứng thành công' });
    } catch (error) {
        console.error('Error in deleteAllergy:', error);
        res.status(500).json({ message: 'Lỗi khi xóa thông tin dị ứng', error: error.message });
    }
}; 