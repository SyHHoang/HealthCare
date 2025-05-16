import Specialty from '../models/Specialty.js';
import Doctor from '../models/Doctor.js';

// Lấy danh sách tất cả chuyên môn
export const getAllSpecialties = async (req, res) => {
  try {
    const specialties = await Specialty.find({ isActive: true });
    res.json(specialties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy danh sách bác sĩ theo chuyên môn
export const getDoctorsBySpecialty = async (req, res) => {
  try {
    const { specialtyId } = req.params;
    console.log('Finding doctors for specialty ID:', specialtyId);
    
    // Tìm chuyên khoa để lấy tên
    const specialty = await Specialty.findById(specialtyId).select('name');
    if (!specialty) {
      return res.status(404).json({ message: 'Không tìm thấy chuyên khoa' });
    }
    const doctors = await Doctor.find({ specialty: specialty.name });
    console.log('Found specialty:', specialty.name);
    res.json(doctors);
  } catch (error) {
    console.error('Error in getDoctorsBySpecialty:', error);
    res.status(500).json({ message: error.message });
  }
};

// Tìm kiếm chuyên môn và bác sĩ
export const searchSpecialtiesAndDoctors = async (req, res) => {
  try {
    const { query } = req.query;
    const specialties = await Specialty.find({
      isActive: true,
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } }
      ]
    });

    const doctors = await Doctor.find({
      isActive: true,
      $or: [
        { fullName: { $regex: query, $options: 'i' } },
        { specialty: { $regex: query, $options: 'i' } }
      ]
    }).select('name avatar specialty experience');

    res.json({
      specialties,
      doctors
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Tạo chuyên môn mới
export const createSpecialty = async (req, res) => {
  try {
    const specialty = new Specialty(req.body);
    const newSpecialty = await specialty.save();
    res.status(201).json(newSpecialty);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Cập nhật chuyên môn
export const updateSpecialty = async (req, res) => {
  try {
    const { specialtyId } = req.params;
    const specialty = await Specialty.findByIdAndUpdate(
      specialtyId,
      req.body,
      { new: true }
    );
    if (!specialty) {
      return res.status(404).json({ message: 'Không tìm thấy chuyên môn' });
    }
    res.json(specialty);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Xóa chuyên môn
export const deleteSpecialty = async (req, res) => {
  try {
    const { specialtyId } = req.params;
    const specialty = await Specialty.findByIdAndDelete(specialtyId);
    if (!specialty) {
      return res.status(404).json({ message: 'Không tìm thấy chuyên môn' });
    }
    res.json({ message: 'Đã xóa chuyên môn thành công' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ĐẾM SỐ BÁC SỸ TỪNG CHUYÊN KHOA
export const countDoctorsBySpecialty = async (req, res) => {
  const { name } = req.params;
  try {
        const count = await Doctor.countDocuments({
          specialty: name,
        });
    res.json(count);  
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy danh sách chuyên khoa
export const getSpecialties = async (req, res) => {
  try {
    const specialties = await Specialty.find({}, 'name _id');
    res.json(specialties);
  } catch (error) {
    console.error('Lỗi khi lấy danh sách chuyên khoa:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};


