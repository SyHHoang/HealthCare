import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Specialty from '../database/models/Specialty.js';

dotenv.config();

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

const createDefaultSpecialties = async () => {
    try {
        // Kết nối đến MongoDB
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Đã kết nối đến MongoDB');

        // Kiểm tra và tạo các chuyên khoa
        const results = [];
        for (const specialty of defaultSpecialties) {
            const existingSpecialty = await Specialty.findOne({ name: specialty.name });
            if (!existingSpecialty) {
                const newSpecialty = new Specialty(specialty);
                await newSpecialty.save();
                console.log(`Đã tạo chuyên khoa: ${specialty.name}`);
                results.push({
                    name: specialty.name,
                    status: 'created'
                });
            } else {
                console.log(`Chuyên khoa đã tồn tại: ${specialty.name}`);
                results.push({
                    name: specialty.name,
                    status: 'already exists'
                });
            }
        }

        console.log('Kết quả tạo chuyên khoa:', results);
        console.log('Đã hoàn thành việc tạo chuyên khoa mặc định');

    } catch (error) {
        console.error('Lỗi khi tạo chuyên khoa mặc định:', error);
    } finally {
        // Đóng kết nối MongoDB
        await mongoose.connection.close();
        console.log('Đã đóng kết nối MongoDB');
    }
};

// Chạy script
createDefaultSpecialties(); 