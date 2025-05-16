import express from 'express';
import * as specialtyController from '../controllers/specialtyController.js';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Public routes
router.get('/', specialtyController.getAllSpecialties);
router.get('/:specialtyId/doctors', specialtyController.getDoctorsBySpecialty);
router.get('/search', specialtyController.searchSpecialtiesAndDoctors);

// Admin routes
router.post('/', authenticateToken, isAdmin, specialtyController.createSpecialty);
router.put('/:specialtyId', authenticateToken, isAdmin, specialtyController.updateSpecialty);
router.delete('/:specialtyId',authenticateToken, isAdmin, specialtyController.deleteSpecialty);

// Lấy danh sách chuyên khoa
router.get('/', specialtyController.getSpecialties);

export default router; 