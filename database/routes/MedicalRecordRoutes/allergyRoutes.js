import express from 'express';
import { addAllergy, getUserAllergies, updateAllergy, deleteAllergy, DoctorgetUserAllergies } from '../../controllers/medicalRecordController/allergyController.js';
import { authenticateToken } from '../../middlewares/authMiddleware.js';
import { authenticateDoctor} from '../../middlewares/doctorAuthMiddleware.js';
const router = express.Router();

// Áp dụng middleware xác thực cho tất cả các route


// Route thêm dị ứng mới
router.post('/', authenticateToken, addAllergy);

// Route lấy danh sách dị ứng của người dùng
router.get('/', authenticateToken, getUserAllergies);

// Route cập nhật dị ứng
router.put('/:id', authenticateToken, updateAllergy);

// Route xóa dị ứng
router.delete('/:id', authenticateToken, deleteAllergy);

router.get('/doctor/:id',authenticateDoctor, DoctorgetUserAllergies);
export default router; 