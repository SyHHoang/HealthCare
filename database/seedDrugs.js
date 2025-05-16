import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Drug from './models/Drug.js';

dotenv.config();

const sampleDrugs = [
  {
    name: "Paracetamol 500mg",
    category: "Hạ sốt",
    type: "Viên nén",
    activeIngredient: "Paracetamol",
    manufacturer: "Dược Hậu Giang",
    uses: "Điều trị các triệu chứng đau nhẹ đến vừa và hạ sốt",
    dosage: "Người lớn: 1-2 viên/lần, 3-4 lần/ngày. Trẻ em: 10-15mg/kg/lần, 4-6 lần/ngày",
    contraindications: "Quá mẫn với paracetamol, suy gan nặng",
    sideEffects: "Hiếm gặp: phát ban, buồn nôn, đau bụng"
  },
  {
    name: "Amoxicillin 500mg",
    category: "Kháng sinh",
    type: "Viên nang",
    activeIngredient: "Amoxicillin",
    manufacturer: "Dược phẩm OPV",
    uses: "Điều trị nhiễm khuẩn đường hô hấp, tiết niệu, da và mô mềm",
    dosage: "Người lớn: 250-500mg/lần, 3 lần/ngày. Trẻ em: 20-40mg/kg/ngày, chia 3 lần",
    contraindications: "Dị ứng với penicillin, suy gan nặng",
    sideEffects: "Tiêu chảy, buồn nôn, phát ban, nhiễm nấm Candida"
  },
  {
    name: "Omeprazole 20mg",
    category: "Tiêu hóa",
    type: "Viên nang",
    activeIngredient: "Omeprazole",
    manufacturer: "Dược phẩm Traphaco",
    uses: "Điều trị loét dạ dày, trào ngược dạ dày thực quản",
    dosage: "1 viên/lần, 1 lần/ngày, uống trước bữa ăn sáng",
    contraindications: "Quá mẫn với omeprazole, phụ nữ có thai",
    sideEffects: "Đau đầu, buồn nôn, tiêu chảy, đau bụng"
  },
  {
    name: "Loratadine 10mg",
    category: "Da liễu",
    type: "Viên nén",
    activeIngredient: "Loratadine",
    manufacturer: "Dược phẩm Imexpharm",
    uses: "Điều trị các triệu chứng dị ứng như viêm mũi dị ứng, mề đay",
    dosage: "1 viên/lần, 1 lần/ngày",
    contraindications: "Quá mẫn với loratadine",
    sideEffects: "Buồn ngủ, khô miệng, đau đầu"
  },
  {
    name: "Vitamin C 500mg",
    category: "Vitamin",
    type: "Viên sủi",
    activeIngredient: "Acid Ascorbic",
    manufacturer: "Dược phẩm Hà Tây",
    uses: "Bổ sung vitamin C, tăng sức đề kháng",
    dosage: "1 viên/lần, 1 lần/ngày, hòa tan trong nước",
    contraindications: "Sỏi thận, tăng oxalat niệu",
    sideEffects: "Tiêu chảy, buồn nôn khi dùng liều cao"
  }
];

const seedDrugs = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Đã kết nối với MongoDB');

    // Xóa tất cả dữ liệu cũ
    await Drug.deleteMany({});
    console.log('Đã xóa dữ liệu cũ');

    // Thêm dữ liệu mới
    const drugs = await Drug.insertMany(sampleDrugs);
    console.log(`Đã thêm ${drugs.length} thuốc vào cơ sở dữ liệu`);

    process.exit(0);
  } catch (error) {
    console.error('Lỗi khi thêm dữ liệu:', error);
    process.exit(1);
  }
};

seedDrugs(); 