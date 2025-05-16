import User from '../models/User.js';
import path from 'path';
import fs from 'fs';
import bcrypt from 'bcryptjs';
export const doctorGetUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "Người dùng không tồn tại!" });
    res.json({ 
      fullname: user.fullname, 
      age: user.age, 
      gender: user.gender, 
      phone: user.phone,
      avatar: user.avatar,
    });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};
export const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user) return res.status(404).json({ message: "Người dùng không tồn tại!" });
    res.json({ 
      fullname: user.fullname, 
      email: user.email, 
      age: user.age, 
      gender: user.gender, 
      phone: user.phone,
      avatar: user.avatar,
      imageId: user.imageId
    });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};
export const getId = async (req, res) => {
  try {

    res.json({ 
      userId: req.user.userId, 
    });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};
export const getImageId = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    res.json({ imageId: user.imageId, delete_token: user.delete_token });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};
export const updateProfile = async (req, res) => {
  try {
    const { fullname, age, gender, phone, avatar,imageId,delete_token } = req.body;
    console.log(req.body);
    const updatedUser = await User.findByIdAndUpdate(
      req.user.userId, 
      { fullname, age, gender, phone, avatar,imageId,delete_token }, 
      { new: true, runValidators: true }
    );
    
    if (!updatedUser) return res.status(404).json({ message: "Người dùng không tồn tại!" });
    res.json({ message: "Cập nhật thông tin thành công!", user: updatedUser });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

export const getAllUsers = async (req, res) => {
  try {
    const { page = 1, limit = 10, sort = 'fullname', order = 'asc', search = '' } = req.query;
    const skip = (page - 1) * limit;
    const searchCondition = search ? { $or: [{ fullname: { $regex: search, $options: 'i' } }, { email: { $regex: search, $options: 'i' } }] } : {};
    const total = await User.countDocuments(searchCondition);
    const users = await User.find(searchCondition)
      .select('-password')
      .sort({ [sort]: order === 'desc' ? -1 : 1 })
      .skip(skip)
      .limit(Number(limit));
    res.json({ total, totalPages: Math.ceil(total / limit), currentPage: Number(page), users });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Kiểm tra xem user có tồn tại không
    const userToDelete = await User.findById(id);
    if (!userToDelete) {
      return res.status(404).json({ message: "Không tìm thấy người dùng!" });
    }

    // Không cho phép xóa chính mình
    if (userToDelete._id.toString() === req.user.userId) {
      return res.status(403).json({ message: "Không thể xóa tài khoản của chính mình!" });
    }

    // Xóa user
    await User.findByIdAndDelete(id);
    
    res.json({ message: "Xóa người dùng thành công!" });
  } catch (error) {
    console.error('Lỗi khi xóa user:', error);
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Lấy dữ liệu từ request body
    const { fullname, age, gender, phone, avatar, imageId, delete_token } = req.body;

    console.log('Request body:', req.body);
    console.log('User ID:', id);

    // Kiểm tra người dùng có tồn tại không
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }

    // Cập nhật thông tin người dùng
    if (fullname) user.fullname = fullname;
    if (age !== undefined) user.age = age;
    if (gender) user.gender = gender;
    if (phone) user.phone = phone;
    if (avatar) user.avatar = avatar;
    if (imageId) user.imageId = imageId;
    if (delete_token) user.delete_token = delete_token;

    await user.save();

    res.json({
      message: 'Cập nhật thông tin người dùng thành công',
      user: {
        _id: user._id,
        fullname: user.fullname,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
        age: user.age,
        gender: user.gender,
        phone: user.phone,
        createdAt: user.createdAt
      }
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật người dùng:', error);
    res.status(500).json({ message: 'Lỗi server khi cập nhật người dùng' });
  }
};

export const createUser = async (req, res) => {
  try {
    const { fullname, email, password, role, age, gender, phone, avatar, imageId, delete_token } = req.body;

    // Kiểm tra email đã tồn tại chưa
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email đã được sử dụng!" });
    }

    // Kiểm tra vai trò hợp lệ
    if (role !== 'user' && role !== 'admin') {
      return res.status(400).json({ message: "Vai trò không hợp lệ! Chỉ cho phép 'user' hoặc 'admin'" });
    }

    // Mã hóa mật khẩu
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Tạo user mới
    const newUser = new User({
      fullname,
      email,
      password: hashedPassword,
      role: role || 'user', // Mặc định là user nếu không chỉ định
      age,
      gender,
      phone,
      avatar,
      imageId,
      delete_token,
      isActive: true
    });

    await newUser.save();

    res.status(201).json({
      message: "Tạo người dùng thành công!",
      user: {
        _id: newUser._id,
        fullname: newUser.fullname,
        email: newUser.email,
        role: newUser.role,
        avatar: newUser.avatar,
        age: newUser.age,
        gender: newUser.gender,
        phone: newUser.phone,
        createdAt: newUser.createdAt
      }
    });
  } catch (error) {
    console.error('Lỗi khi tạo người dùng:', error);
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

// Lấy cài đặt thông báo
export const getNotificationSettings = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng" });
    }

    res.json({
      success: true,
      settings: user.notificationSettings
    });
  } catch (error) {
    console.error('Lỗi khi lấy cài đặt thông báo:', error);
    res.status(500).json({ 
      success: false, 
      message: "Lỗi server khi lấy cài đặt thông báo" 
    });
  }
};

// Cập nhật cài đặt thông báo
export const updateNotificationSettings = async (req, res) => {
  try {
    const { 
      systemNotifications,
      paymentNotifications,
      messageNotifications,
      appointmentNotifications
    } = req.body;

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng" });
    }

    // Cập nhật cài đặt thông báo
    user.notificationSettings = {
      systemNotifications: systemNotifications ?? user.notificationSettings.systemNotifications,
      paymentNotifications: paymentNotifications ?? user.notificationSettings.paymentNotifications,
      messageNotifications: messageNotifications ?? user.notificationSettings.messageNotifications,
      appointmentNotifications: appointmentNotifications ?? user.notificationSettings.appointmentNotifications
    };

    await user.save();

    res.json({
      success: true,
      message: "Cập nhật cài đặt thông báo thành công",
      settings: user.notificationSettings
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật cài đặt thông báo:', error);
    res.status(500).json({ 
      success: false, 
      message: "Lỗi server khi cập nhật cài đặt thông báo" 
    });
  }
};
