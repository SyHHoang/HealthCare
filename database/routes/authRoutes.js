import express from "express";
import { login, register, changePassword } from "../controllers/authController.js";
import { authenticateToken } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.post("/login", login);
router.post("/register", register);
router.post("/change-password", authenticateToken, changePassword);

export default router;
