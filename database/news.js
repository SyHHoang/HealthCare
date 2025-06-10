import mongoose from 'mongoose';
import dotenv from 'dotenv';
import News from './models/News.js';

dotenv.config();

const sampleNews = [
  {
    title: "Dị ứng thức ăn có thể gây sốc phản vệ nguy kịch",
    summary: "SKĐS - Dị ứng thức ăn là tình trạng khá phổ biến, không chỉ ảnh hưởng đến làn da mà còn ảnh hưởng đến đường tiêu hóa, hệ hô hấp hoặc tim mạch...",
    content: "Điều trị các triệu chứng đau nhẹ đến vừa và hạ sốt",
    category: "lifestyle",
    coverImage: "https://i.ibb.co/KxzjCTzn/Screenshot-2025-06-09-023715.png",
  },
  {
    title: "Đau đầu cảnh giác với u màng não",
    summary: "U màng não là sự xuất hiện của khối u trên màng não, đây là phần màng bao phủ não bộ và tủy sống bên trong hộp sọ. Khối u màng não thường phát triển khá chậm, có tỷ lệ lành tính cao...",
    content: "Điều trị nhiễm khuẩn đường hô hấp, tiết niệu, da và mô mềm",
    category: "lifestyle",
    coverImage: "https://i.ibb.co/6J15FqsH/Screenshot-2025-06-09-023842.png",
  },
  {
    title: "Suy thận có những biểu hiện gì?",
    summary: "Suy thận là tình trạng chức năng thận bị suy giảm nghiêm trọng. Khi chức năng của thận giảm sẽ không thể lọc máu và loại bỏ chất thải cùng nước dư thừa khỏi cơ thể...",
    content: "Điều trị loét dạ dày, trào ngược dạ dày thực quản",
    category: "lifestyle",
    coverImage: "https://i.ibb.co/jkhSyhWz/Screenshot-2025-06-09-023959.png",
  },
  {
    title: "Tầm quan trọng của canxi trong thai kỳ",
    summary: "Canxi đóng vai trò quan trọng trong giai đoạn thai kỳ, việc ăn uống đầy đủ nhằm đáp ứng đủ nhu cầu canxi giúp cả mẹ lẫn bé khỏe mạnh...",
    content: "Điều trị các triệu chứng dị ứng như viêm mũi dị ứng, mề đay",
    category: "lifestyle",
    coverImage: "https://i.ibb.co/DDpj9Ltv/Screenshot-2025-06-09-024138.png",
  },
  {
    title: "Thải độc, giải nhiệt cho cơ thể mùa nắng nóng với những loại nước dễ kiếm, rẻ tiền",
    summary: "Thời tiết nắng nóng khiến cơ thể mất nước và dẫn đến các vấn đề xấu về sức khỏe. Có thể thải độc, giải nhiệt cho cơ thể mùa nắng nóng với những loại nước dễ kiếm, rẻ tiền dưới đây...",
    content: "Bổ sung vitamin C, tăng sức đề kháng",
    category: "lifestyle",
    coverImage: "https://i.ibb.co/RT1LFLjg/Screenshot-2025-06-09-024254.png",
  },
  {
    title: "Yếu tố nguy cơ khiến trẻ mắc rối loạn tăng động giảm chú ý",
    summary: "Rối loạn tăng động giảm chú ý (ADHD) ảnh hưởng lớn đến sự phát triển của trẻ. Nhận biết sớm và điều trị đúng giúp con bạn tự tin hơn trong học tập và cuộc sống...",
    content: "Bổ sung vitamin C, tăng sức đề kháng",
    category: "lifestyle",
    coverImage: "https://i.ibb.co/tpPgnh68/Screenshot-2025-06-09-024354.png",
  }
];

const seedNews = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Đã kết nối với MongoDB');

    // Xóa tất cả dữ liệu cũ
    await News.deleteMany({});
    console.log('Đã xóa dữ liệu cũ');

    // Thêm dữ liệu mới
    const news = await News.insertMany(sampleNews);
    console.log(`Đã thêm ${news.length} tin tức vào cơ sở dữ liệu`);

    process.exit(0);
  } catch (error) {
    console.error('Lỗi khi thêm dữ liệu:', error);
    process.exit(1);
  }
};

seedNews(); 