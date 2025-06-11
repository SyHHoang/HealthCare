import express from "express";
import { getAllNews, getNewsById, addNews, uploadImage, getNewsStats, updateNews, deleteNews, getLatestNews, getNewsSummary } from "../controllers/newsController.js";
import { authenticateToken, isAdmin } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Route để lấy tin tức mới nhất - phải đặt trước route /:id
router.get("/latest", getLatestNews);

// Các route khác
router.get("/", getAllNews);
router.get("/:id", getNewsById);
router.post("/", authenticateToken, isAdmin, addNews);

// Route để upload hình ảnh (yêu cầu đăng nhập và quyền admin)
router.post("/upload-image", authenticateToken, isAdmin, uploadImage);

// Route để lấy thống kê lượt xem
router.get("/stats/views", authenticateToken, isAdmin, getNewsStats);
router.get("/stats/views/:id", authenticateToken, isAdmin, getNewsStats);

// Route để lấy tổng số bài viết
router.get("/stats/summary", authenticateToken, isAdmin, getNewsSummary);

// Route để cập nhật và xóa bài viết
router.put("/:id", authenticateToken, isAdmin, updateNews);
router.delete("/:id", authenticateToken, isAdmin, deleteNews);

export default router;
