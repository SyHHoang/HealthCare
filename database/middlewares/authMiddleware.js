import jwt from "jsonwebtoken";
import User from "../models/User.js";
//xác thực các chức năng sau khi đăng nhập
export const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];
    
    if (!token) {
      console.log("Không có token!");
      return res.status(401).json({ message: "Không có token!" });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password');

    if (!user) {
      return res.status(401).json({ message: "Người dùng không tồn tại!" });
    }
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ message: "Token không hợp lệ!" });
  }
};

export const isAdmin = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user || user.role !== "admin") {
      return res.status(403).json({ message: "Chỉ admin mới có quyền!" });
    }
    next();
  } catch (err) {
    res.status(500).json({ message: "Lỗi server!", error: err.message });
  }
};