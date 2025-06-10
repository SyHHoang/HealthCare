import axios from 'axios';

// Tạo instance của axios với cấu hình mặc định
const axiosInstance = axios.create({
  baseURL: import.meta.env.VITE_BASE_URL, // URL của backend
  headers: {
    'Content-Type': 'application/json'
  }
});

// Thêm interceptor để tự động thêm token vào header
axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    console.log('Token:', token); // In ra để kiểm tra
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    console.error('Request Error:', error);
    return Promise.reject(error);
  }
);

// Thêm interceptor để xử lý lỗi
axiosInstance.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Log chi tiết lỗi
    console.error('Response Error:', {
      status: error.response?.status,
      statusText: error.response?.statusText,
      data: error.response?.data,
      config: {
        url: error.config?.url,
        method: error.config?.method,
        data: error.config?.data
      }
    });

    if (error.response?.status === 401) {
      // Xử lý khi token hết hạn hoặc không hợp lệ
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      localStorage.removeItem('user');
      // Kiểm tra nếu không phải đang ở trang đăng nhập thì mới điều hướng
  
    }
    return Promise.reject(error);
  }
);

export default axiosInstance; 