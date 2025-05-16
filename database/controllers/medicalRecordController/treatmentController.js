import Treatment  from '../../models/MedicalRecord/Treatment.js';

// Thêm phác đồ điều trị mới
export async function addTreatment(req, res) {
    try {
        const { diagnosis, treatmentPlan, startDate, endDate, status, medications, procedures, followUp, notes } = req.body;
        const newTreatment = new Treatment({
            userId: req.user.userId,
            diagnosis,
            treatmentPlan,
            startDate,
            endDate,
            status,
            medications,
            procedures,
            followUp,
            notes
        });
        console.log("newTreatment",newTreatment);
        await newTreatment.save();
        res.status(201).json({ message: 'Thêm phác đồ điều trị thành công', data: newTreatment });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}

// Lấy lịch sử điều trị của người dùng
export async function getUserTreatments(req, res) {
    try {
        const treatments = await Treatment.find({ userId: req.user.userId })
            .sort({ startDate: -1 });
        res.status(200).json(treatments);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}
export async function DoctorgetUserTreatments(req, res) {
    try {
        const id = req.params.id;
        const treatments = await Treatment.find({ userId: id }).sort({ startDate: -1 });
        res.status(200).json(treatments);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}   
// Cập nhật phác đồ điều trị
export async function updateTreatment(req, res) {
    try {
        const { id } = req.params;
        const { diagnosis, treatmentPlan, startDate, endDate, status, medications, procedures, followUp, notes } = req.body;
        
        const updatedTreatment = await Treatment.findOneAndUpdate(
            { _id: id, userId: req.user.userId },
            { diagnosis, treatmentPlan, startDate, endDate, status, medications, procedures, followUp, notes },
            { new: true }
        );
        
        if (!updatedTreatment) {
            return res.status(404).json({ message: 'Không tìm thấy phác đồ điều trị' });
        }
        
        res.status(200).json({ message: 'Cập nhật thành công', data: updatedTreatment });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}

// Xóa phác đồ điều trị
export async function deleteTreatment(req, res) {
    try {
        const { id } = req.params;
        const deletedTreatment = await Treatment.findOneAndDelete({ 
            _id: id, 
            userId: req.user.userId 
        });
        
        if (!deletedTreatment) {
            return res.status(404).json({ message: 'Không tìm thấy phác đồ điều trị' });
        }
        
        res.status(200).json({ message: 'Xóa thành công' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
} 