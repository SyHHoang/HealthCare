import Lifestyle from '../../models/MedicalRecord/Lifestyle.js';

// Lấy tất cả thông tin lối sống của người dùng
export async function getAllLifestyles(req, res) {
  try {
    const lifestyles = await Lifestyle.find({ userId: req.user.userId }).sort({ createdAt: -1 });
    res.json(lifestyles);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy thông tin lối sống' });
  }
}
export async function DoctorgetAllLifestyles(req, res) {
  try {
    const id = req.params.id;
    const lifestyles = await Lifestyle.find({ userId: id }).sort({ createdAt: -1 });
    res.json(lifestyles);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy thông tin lối sống' });
  }
}
// Thêm thông tin lối sống mới
export async function addLifestyle(req, res) {
  try {
    const { activityType, description, frequency, duration, startDate, notes } = req.body;
    const newLifestyle = new Lifestyle({
      userId: req.user.userId,
      activityType,
      description,
      frequency,
      duration,
      startDate,
      notes
    });
    console.log("req.body",req.body);
    console.log("newLifestyle",newLifestyle);
    const result = await newLifestyle.save();
    console.log("result",result);
    res.status(201).json({ message: 'Thêm thông tin lối sống thành công', data: newLifestyle });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
}

// Cập nhật thông tin lối sống
export async function updateLifestyle(req, res) {
  try {
    const { id } = req.params;
    console.log("id",id);
    const lifestyle = await Lifestyle.findOne({ _id: id });
    console.log("lifestyle",lifestyle);
    if (!lifestyle) {
      return res.status(404).json({ message: 'Không tìm thấy thông tin lối sống' });
    }
    const { activityType, description, frequency, duration, startDate, notes } = req.body;
    const updatedLifestyle = await Lifestyle.findByIdAndUpdate(
      id,
      { $set: { activityType, description, frequency, duration, startDate, notes } },
      { new: true }
    );
    res.json(updatedLifestyle);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi cập nhật thông tin lối sống' });
  }
}

// Xóa thông tin lối sống
export async function deleteLifestyle(req, res) {
  try {
    const { id } = req.params;
    const lifestyle = await Lifestyle.findOne({ _id: id});
    
    if (!lifestyle) {
      return res.status(404).json({ message: 'Không tìm thấy thông tin lối sống' });
    }

    await Lifestyle.findByIdAndDelete(id);
    res.json({ message: 'Xóa thông tin lối sống thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi xóa thông tin lối sống' });
  }
} 
