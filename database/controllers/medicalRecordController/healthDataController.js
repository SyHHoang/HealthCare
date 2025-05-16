import HealthData from '../../models/MedicalRecord/HealthData.js';

// Lấy tất cả dữ liệu sức khỏe của người dùng
export async function getAllHealthData(req, res) {
  try {
    const healthData = await HealthData.find({ userId: req.user.userId }).sort({ measurementTime: -1 });
    res.json(healthData);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy dữ liệu sức khỏe' });
  }
}
export async function DoctorgetAllHealthDataetAllHealthData(req, res) {
  try {
    const id = req.params.id;
    const healthData = await HealthData.find({ userId: id }).sort({ measurementTime: -1 });
    res.json(healthData);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy dữ liệu sức khỏe' });
  }
}
// Thêm dữ liệu sức khỏe mới
export async function addHealthData(req, res) {
  try {
    const { dataType, value, unit, measurementTime, measurementLocation, measuredBy, notes } = req.body;
    const newHealthData = new HealthData({
      userId: req.user.userId,
      dataType,
      value,
      unit,
      measurementTime,
      measurementLocation,
      notes
    });
    await newHealthData.save();
    res.status(201).json(newHealthData);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi thêm dữ liệu sức khỏe' });
  }
}

// Cập nhật dữ liệu sức khỏe
export async function updateHealthData(req, res) {
  try {
    const { id } = req.params;
      const healthData = await HealthData.findOne({ _id: id });
    
    if (!healthData) {
      return res.status(404).json({ message: 'Không tìm thấy dữ liệu sức khỏe' });
    }

    const updatedHealthData = await HealthData.findByIdAndUpdate(
      id,
      { $set: req.body },
      { new: true }
    );
    res.json(updatedHealthData);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi cập nhật dữ liệu sức khỏe' });
  }
}

// Xóa dữ liệu sức khỏe
export async function deleteHealthData(req, res) {
  try {
    const { id } = req.params;
    const healthData = await HealthData.findOne({ _id: id});
    
    if (!healthData) {
      return res.status(404).json({ message: 'Không tìm thấy dữ liệu sức khỏe' });
    }

    await HealthData.findByIdAndDelete(id);
    res.json({ message: 'Xóa dữ liệu sức khỏe thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi xóa dữ liệu sức khỏe' });
  }
} 