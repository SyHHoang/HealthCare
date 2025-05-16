import { io } from 'socket.io-client';
import axiosInstance from './axiosInstance';

class SocketService {
  constructor() {
    this.socket = null;
    this.isConnected = false;
    this.eventHandlers = new Map();
    this.pendingEvents = [];
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }

  connect() {
    if (this.isConnected) return;

    const token = localStorage.getItem('token');
    console.log("token là", token);
    if (!token) return;

    // Sử dụng URL từ biến môi trường hoặc fallback về localhost:3000
    const SOCKET_URL = import.meta.env.VITE_BASE_URL;
    console.log('Kết nối socket đến:', SOCKET_URL);

    this.socket = io(SOCKET_URL, {
      auth: { token },
      transports: ['websocket'],
      reconnection: true,
      reconnectionAttempts: this.maxReconnectAttempts,
      reconnectionDelay: 1000,
      timeout: 10000,
      forceNew: true
    });

    this.socket.on('connect', () => {
      console.log('Socket đã kết nối');
      this.isConnected = true;
      this.reconnectAttempts = 0;
      // Gửi các event đang chờ
      this.sendPendingEvents();
      // Thông báo online
      this.notifyOnline();
    });

    this.socket.on('connect_error', (error) => {
      console.error('Lỗi kết nối socket:', error);
      this.reconnectAttempts++;
      
      if (this.reconnectAttempts >= this.maxReconnectAttempts) {
        console.error('Đã vượt quá số lần thử kết nối lại');
        this.disconnect();
      }
    });

    this.socket.on('disconnect', (reason) => {
      console.log('Socket đã ngắt kết nối:', reason);
      this.isConnected = false;
      
      // Tự động kết nối lại nếu bị ngắt kết nối không mong muốn
      if (reason === 'io server disconnect' || reason === 'transport close') {
        this.connect();
      }
    });

    this.socket.on('error', (error) => {
      console.error('Lỗi socket:', error);
    });

    // Khôi phục các event handlers đã đăng ký trước đó
    this.eventHandlers.forEach((handler, event) => {
      this.socket.on(event, handler);
    });
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
      this.isConnected = false;
      this.eventHandlers.clear();
      this.pendingEvents = [];
      this.reconnectAttempts = 0;
    }
  }

  on(event, handler) {
    if (this.socket) {
      this.socket.on(event, handler);
    }
    // Lưu handler để khôi phục khi reconnect
    this.eventHandlers.set(event, handler);
  }

  off(event, handler) {
    if (this.socket) {
      this.socket.off(event, handler);
    }
    this.eventHandlers.delete(event);
  }

  emit(event, data) {
    if (this.socket && this.isConnected) {
      this.socket.emit(event, data);
    } else {
      console.warn('Socket chưa kết nối, lưu event để gửi sau:', event);
      this.pendingEvents.push({ event, data });
      // Thử kết nối lại nếu chưa kết nối
      if (!this.isConnected) {
        this.connect();
      }
    }
  }

  sendPendingEvents() {
    while (this.pendingEvents.length > 0) {
      const { event, data } = this.pendingEvents.shift();
      this.socket.emit(event, data);
    }
  }

  // Các phương thức tiện ích
  joinChat(chatId) {
    this.emit('join_chat', chatId);
  }

  leaveChat(chatId) {
    this.emit('leave_chat', chatId);
  }

  sendMessage(messageData) {
    this.emit('send_message', messageData);
  }

  notifyOnline() {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}');
    if (userInfo.role === 'user') {
      this.emit('user_online', { userId: userInfo._id });
    } else if (userInfo.role === 'doctor') {
      this.emit('doctor_online', { doctorId: userInfo._id });
    }
  }

  async notifyOffline() {
    try {
      await axiosInstance.post('/api/users/offline');
    } catch (error) {
      console.error('Error notifying offline status:', error);
    }
  }
}

export default new SocketService(); 