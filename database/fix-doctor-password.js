import mongoose from 'mongoose';
import Doctor from './models/Doctor.js';
import dotenv from 'dotenv';

dotenv.config();

// Kết nối MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("✅ Kết nối MongoDB thành công");
  } catch (err) {
    console.error("❌ Lỗi kết nối MongoDB:", err);
    process.exit(1);
  }
};

const fixDoctorPassword = async () => {
  await connectDB();
  
  const testEmail = 'bs1@gmail.com';
  const newPassword = '111111';
  
  try {
    console.log('🔍 Tìm kiếm bác sĩ với email:', testEmail);
    
    // Tìm bác sĩ
    const doctor = await Doctor.findOne({ email: testEmail });
    
    if (!doctor) {
      console.log('❌ Không tìm thấy bác sĩ với email:', testEmail);
      return;
    }
    
    console.log('👨‍⚕️ Đã tìm thấy bác sĩ:');
    console.log('- ID:', doctor._id);
    console.log('- Email:', doctor.email);
    console.log('- Status:', doctor.status);
    
    // Reset mật khẩu - sẽ được hash tự động bởi pre-save middleware
    doctor.password = newPassword;
    await doctor.save();
    
    console.log('✅ Đã reset mật khẩu thành công!');
    console.log('- Mật khẩu mới:', newPassword);
    
    // Test đăng nhập
    const doctorWithPassword = await Doctor.findById(doctor._id).select('+password');
    const isPasswordCorrect = await doctorWithPassword.comparePassword(newPassword);
    console.log('🔐 Test đăng nhập:', isPasswordCorrect ? 'THÀNH CÔNG' : 'THẤT BẠI');
    
  } catch (error) {
    console.error('❌ Lỗi:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Đã ngắt kết nối MongoDB');
  }
};

fixDoctorPassword();
