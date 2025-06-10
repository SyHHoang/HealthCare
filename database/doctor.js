import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Doctor from './models/Doctor.js';

dotenv.config();

const sampleDoctors = [
  {
    fullName: "Đinh Văn Hoàng",
    email: "dinhvanthoang@gmail.com",
    password: "111111",
    role: "doctor",
    avatar: "https://i.ibb.co/gZp93Z0f/Screenshot-2025-06-09-030805.png",
    status: "active",
    isVerified: true,
    specialty: "Nội tổng quát",
    experience: 5,
    
  },
  {
    fullName: "Nguyễn Tiến Đạt",
    email: "dinhvandat@gmail.com",
    password: "111111",
    role: "doctor",
    avatar: "https://i.ibb.co/HDsDMj7G/Screenshot-2025-06-09-030640.png",
    status: "active",
    isVerified: true,
    specialty: "Dị ứng thức ăn",
    experience: 5,
    
  },
  {
    fullName: "Ngô Thị Hạnh",
    email: "ngothihanh@gmail.com",
     password: "111111",
    role: "doctor",
    avatar: "https://i.ibb.co/wNNCdHT7/Screenshot-2025-06-09-030705.png",
    status: "active",
    isVerified: true,
    specialty: "Dị ứng thức ăn",
    experience: 5,
    
  },
  {
    fullName: "Nguyễn Thị Hương",
    email: "ngothihuong@gmail.com",
    password: "111111",
    role: "doctor",
    avatar: "https://i.ibb.co/P0LMNwf/Screenshot-2025-06-09-030728.png",
    status: "active",
    isVerified: true,
    specialty: "Dị ứng thức ăn",
    experience: 5,
    
  },
  {
    fullName: "Trần Quốc Tuấn",
    email: "tranquoctuan@gmail.com",
    password: "111111",
    role: "doctor",
    avatar: "https://i.ibb.co/0yRgdqNf/Screenshot-2025-06-09-030609.png",
    status: "active",
    isVerified: true,
    specialty: "Dị ứng thức ăn",
    experience: 5,
    
  },
  {
    fullName: "Võ Thị Hoa",
    email: "vonthihoa@gmail.com",
    password: "111111",
    role: "doctor",
    avatar: "https://i.ibb.co/Z16N7pGZ/Screenshot-2025-06-09-030520.png",
    status: "active",
    isVerified: true,
    specialty: "Dị ứng thức ăn",
    experience: 5,
    
  },
];

const seedDoctors = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Đã kết nối với MongoDB');

    // Xóa tất cả dữ liệu cũ
    await Doctor.deleteMany({});
    console.log('Đã xóa dữ liệu cũ');

    // Thêm dữ liệu mới
    const doctors = await Doctor.insertMany(sampleDoctors);
    console.log(`Đã thêm ${doctors.length} bác sĩ vào cơ sở dữ liệu`);

    process.exit(0);
  } catch (error) {
    console.error('Lỗi khi thêm dữ liệu:', error);
    process.exit(1);
  }
};

seedDoctors(); 