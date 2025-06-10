import express from "express";
import { login, UserRegister, changePassword } from "../controllers/authController.js";
import { authenticateToken } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.post("/login", login);
router.post("/UserRegister", UserRegister);
router.post("/change-password", authenticateToken, changePassword);

export default router;
