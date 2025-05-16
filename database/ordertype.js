import mongoose from 'mongoose';
import dotenv from 'dotenv';
import OrderType from './models/orderType.js';

dotenv.config();

const sampleOrderTypes = [
  { name: 'Đăng ký bác sỹ tư vấn', price: 500 },
  { name: 'Gia hạn thời gian tư vấn', price: 300},
  { name: 'Thêm 1 lần gọi video tư vấn', price: 200 }
];

const seedOrderTypes = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Đã kết nối với MongoDB');

    await OrderType.deleteMany({});
    console.log('🗑️ Đã xóa dữ liệu OrderType cũ');

    const inserted = await OrderType.insertMany(sampleOrderTypes);
    console.log(`✅ Đã thêm ${inserted.length} loại đơn hàng`);

    process.exit(0);
  } catch (err) {
    console.error('❌ Lỗi khi seed:', err);
    process.exit(1);
  }
};

seedOrderTypes();
