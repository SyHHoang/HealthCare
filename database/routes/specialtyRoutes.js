import express from 'express';
import * as specialtyController from '../controllers/specialtyController.js';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';
import axios from 'axios';
import dotenv from 'dotenv';
import Specialty from '../models/Specialty.js';

dotenv.config();
const router = express.Router();

// Public routes
router.get('/', specialtyController.getAllSpecialties);
router.get('/:specialtyId/doctors', specialtyController.getDoctorsBySpecialty);
router.get('/search', specialtyController.searchSpecialtiesAndDoctors);

// Route để gọi API bên ngoài và lấy danh sách chuyên khoa
router.get('/fetch-external', async (req, res) => {
    try {
        // Gọi API bên ngoài
        const response = await axios.get('https://api.example.com/specialties');
        
        // Xử lý dữ liệu trả về
        let specialties = response.data;
        
        // Nếu dữ liệu là chuỗi được phân cách bởi dấu phẩy
        if (typeof specialties === 'string') {
            specialties = specialties.split(',').map(s => s.trim());
        }

        // Tìm các chuyên khoa trong cơ sở dữ liệu
        const foundSpecialties = await Specialty.find({
            name: { $in: specialties }
        });

        // Tạo danh sách các chuyên khoa không có trong cơ sở dữ liệu
        const existingNames = foundSpecialties.map(s => s.name);
        const missingSpecialties = specialties.filter(name => !existingNames.includes(name));

        // Trả về kết quả
        res.json({
            success: true,
            data: {
                found: foundSpecialties,
                missing: missingSpecialties
            }
        });
    } catch (error) {
        console.error('Lỗi khi lấy danh sách chuyên khoa từ API bên ngoài:', error);
        res.status(500).json({
            success: false,
            message: 'Lỗi khi lấy danh sách chuyên khoa từ API bên ngoài',
            error: error.message
        });
    }
});

// Route để proxy request đến API bên ngoài
router.post('/predict', async (req, res) => {
    try {
        const { description } = req.body;
        
        // Gọi API bên ngoài
        const response = await axios.post('http://3151-34-48-51-147.ngrok-free.app/predict', {
            description
        });
        
        // Lấy danh sách chuyên khoa từ kết quả API
        const specialties = response.data.specialties || [];
        const confidences = response.data.confidences || {};
        
        // Tìm thông tin chi tiết của các chuyên khoa trong database
        const specialtyDetails = await Specialty.find({
            name: { $in: specialties }
        });
        
        // Tạo map để dễ dàng truy cập thông tin chuyên khoa
        const specialtyMap = {};
        specialtyDetails.forEach(specialty => {
            specialtyMap[specialty.name] = {
                description: specialty.description,
                icon: specialty.icon
            };
        });
        
        // Tạo danh sách mô tả cho các chuyên khoa
        const descriptions = {};
        specialties.forEach(specialty => {
            descriptions[specialty] = specialtyMap[specialty]?.description || 'Chưa có mô tả chi tiết';
        });
        
        // Trả về kết quả với thông tin mô tả
        res.json({
            specialties,
            confidences,
            descriptions
        });
    } catch (error) {
        console.error('Lỗi khi gọi API bên ngoài:', error);
        res.status(500).json({
            success: false,
            message: 'Lỗi khi gọi API bên ngoài',
            error: error.message
        });
    }
});

// Route để tạo các chuyên khoa mặc định
router.post('/create-default', async (req, res) => {
    try {
        const defaultSpecialties = [
            {
                name: "Nội tổng quát",
                description: "Chuyên khoa Nội tổng quát chẩn đoán và điều trị các bệnh lý nội khoa thông thường như: cao huyết áp, tiểu đường, bệnh tim mạch, bệnh hô hấp, bệnh tiêu hóa... Bác sĩ nội tổng quát là người đầu tiên tiếp xúc với bệnh nhân, thực hiện khám tổng quát và chuyển đến các chuyên khoa chuyên sâu khi cần thiết.",
                icon: "fa-solid fa-stethoscope"
            },
            {
                name: "Da liễu",
                description: "Chuyên khoa Da liễu chẩn đoán và điều trị các bệnh về da, tóc, móng và các bệnh lây truyền qua đường tình dục. Bao gồm: mụn trứng cá, viêm da, dị ứng, nấm da, bệnh vẩy nến, ung thư da và các vấn đề thẩm mỹ liên quan đến da.",
                icon: "fa-solid fa-hand-dots"
            },
            {
                name: "Tâm thần",
                description: "Chuyên khoa Tâm thần chẩn đoán và điều trị các rối loạn tâm thần, tâm lý như: trầm cảm, lo âu, rối loạn giấc ngủ, tâm thần phân liệt, rối loạn nhân cách, nghiện chất và các vấn đề tâm lý khác. Bác sĩ tâm thần có thể kê đơn thuốc và thực hiện các liệu pháp tâm lý.",
                icon: "fa-solid fa-brain"
            },
            {
                name: "Phụ khoa",
                description: "Chuyên khoa Phụ khoa chăm sóc sức khỏe sinh sản của phụ nữ, bao gồm: khám phụ khoa định kỳ, điều trị các bệnh phụ khoa, tư vấn kế hoạch hóa gia đình, chăm sóc thai kỳ, điều trị vô sinh và các vấn đề liên quan đến nội tiết tố nữ.",
                icon: "fa-solid fa-venus"
            },
            {
                name: "Nhi khoa",
                description: "Chuyên khoa Nhi chăm sóc sức khỏe cho trẻ em từ sơ sinh đến 18 tuổi. Bao gồm: khám sức khỏe định kỳ, tiêm chủng, điều trị các bệnh thông thường ở trẻ em, theo dõi sự phát triển thể chất và tinh thần, tư vấn dinh dưỡng và chăm sóc trẻ sơ sinh.",
                icon: "fa-solid fa-baby"
            },
            {
                name: "Dinh dưỡng",
                description: "Chuyên khoa Dinh dưỡng tư vấn và điều trị các vấn đề liên quan đến dinh dưỡng. Bao gồm: đánh giá tình trạng dinh dưỡng, xây dựng chế độ ăn phù hợp, điều trị béo phì, suy dinh dưỡng, tư vấn dinh dưỡng cho người bệnh, phụ nữ mang thai và trẻ em.",
                icon: "fa-solid fa-apple-whole"
            },
            {
                name: "Tiêu hóa",
                description: "Chuyên khoa Tiêu hóa chẩn đoán và điều trị các bệnh về đường tiêu hóa như: viêm dạ dày, loét dạ dày, viêm đại tràng, bệnh gan, bệnh túi mật, ung thư đường tiêu hóa. Thực hiện các thủ thuật nội soi tiêu hóa để chẩn đoán và điều trị.",
                icon: "fa-solid fa-stomach"
            },
            {
                name: "Nội tiết",
                description: "Chuyên khoa Nội tiết chẩn đoán và điều trị các rối loạn nội tiết tố và chuyển hóa. Bao gồm: bệnh tiểu đường, bệnh tuyến giáp, rối loạn hormone, bệnh về tuyến yên, tuyến thượng thận và các vấn đề về chuyển hóa.",
                icon: "fa-solid fa-vial"
            }
        ];

        // Kiểm tra và tạo các chuyên khoa
        const results = [];
        for (const specialty of defaultSpecialties) {
            const existingSpecialty = await Specialty.findOne({ name: specialty.name });
            if (!existingSpecialty) {
                const newSpecialty = new Specialty(specialty);
                await newSpecialty.save();
                results.push({
                    name: specialty.name,
                    status: 'created'
                });
            } else {
                results.push({
                    name: specialty.name,
                    status: 'already exists'
                });
            }
        }

        res.json({
            success: true,
            message: 'Đã tạo các chuyên khoa mặc định',
            results
        });
    } catch (error) {
        console.error('Lỗi khi tạo chuyên khoa mặc định:', error);
        res.status(500).json({
            success: false,
            message: 'Lỗi khi tạo chuyên khoa mặc định',
            error: error.message
        });
    }
});

// Admin routes
router.post('/', authenticateToken, isAdmin, specialtyController.createSpecialty);
router.put('/:specialtyId', authenticateToken, isAdmin, specialtyController.updateSpecialty);
router.delete('/:specialtyId', authenticateToken, isAdmin, specialtyController.deleteSpecialty);

export default router; 