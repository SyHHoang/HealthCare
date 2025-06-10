import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
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

const testDoctorAuth = async () => {
  await connectDB();

  const testEmail = 'bs1@gmail.com';
  const testPassword = '111111';

  try {
    console.log('=== DOCTOR AUTH TEST ===');
    console.log('Test email:', testEmail);
    console.log('Test password:', testPassword);
    console.log('Test password type:', typeof testPassword);
    console.log('Test password length:', testPassword.length);

    // 1. Xóa bác sĩ cũ nếu có (để test clean)
    console.log('\n🗑️ Xóa bác sĩ cũ nếu có...');
    await Doctor.deleteOne({ email: testEmail });
    console.log('✅ Đã xóa bác sĩ cũ (nếu có)');

    // 2. Tạo bác sĩ mới
    console.log('\n📝 Tạo bác sĩ mới...');
    const newDoctor = await Doctor.create({
      email: testEmail,
      password: testPassword,
      role: 'doctor'
    });

    console.log('✅ Đã tạo bác sĩ mới:');
    console.log('- Email:', newDoctor.email);
    console.log('- ID:', newDoctor._id);
    console.log('- Status:', newDoctor.status);
    console.log('- Role:', newDoctor.role);

    // 3. Lấy lại bác sĩ với password để test
    console.log('\n🔍 Lấy lại bác sĩ từ database...');
    const doctorWithPassword = await Doctor.findById(newDoctor._id).select('+password');
    console.log('- Password hash trong DB:', doctorWithPassword.password);
    console.log('- Hash length:', doctorWithPassword.password.length);

    // 4. Test so sánh mật khẩu
    console.log('\n🔐 Test so sánh mật khẩu...');
    const isPasswordCorrect = await doctorWithPassword.comparePassword(testPassword);
    console.log('- Kết quả so sánh:', isPasswordCorrect);

    // 5. Test so sánh trực tiếp với bcrypt
    console.log('\n🔐 Test so sánh trực tiếp với bcrypt...');
    const directCompare = await bcrypt.compare(testPassword, doctorWithPassword.password);
    console.log('- Kết quả so sánh trực tiếp:', directCompare);

    // 6. Test với mật khẩu sai
    console.log('\n🔐 Test với mật khẩu sai...');
    const wrongPasswordTest = await doctorWithPassword.comparePassword('wrongpassword');
    console.log('- Kết quả với mật khẩu sai:', wrongPasswordTest);

  } catch (error) {
    console.error('❌ Lỗi:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Đã ngắt kết nối MongoDB');
  }
};

testDoctorAuth();
