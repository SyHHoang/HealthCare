import { defineStore } from 'pinia';
import { io } from 'socket.io-client';
import axiosInstance from '../services/axiosInstance';

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    unreadCount: 0,
    socket: null
  }),

  actions: {
    connectSocket() {
      const token = localStorage.getItem('token');
      if (!token) return;

      const SOCKET_URL = import.meta.env.VITE_BASE_URL;
      this.socket = io(SOCKET_URL, {
        auth: { token },
        transports: ['websocket']
      });

      this.socket.on('connect', () => {
        console.log('Socket connected for notifications');
      });

      this.socket.on('disconnect', () => {
        console.log('Socket disconnected');
      });
    },

    disconnectSocket() {
      if (this.socket) {
        this.socket.disconnect();
        this.socket = null;
      }
    },

    addNotification(notification) {
      this.notifications.unshift({
        ...notification,
        time: new Date(),
        read: false
      });
      this.unreadCount++;
    },

    async fetchNotifications() {
      try {
        const response = await axiosInstance.get('/api/notifications');
        this.notifications = response.data;
        this.unreadCount = this.notifications.filter(n => !n.read).length;
      } catch (error) {
        console.error('Error fetching notifications:', error);
        throw error;
      }
    },

    async markAsRead(notificationId) {
      try {
        await axiosInstance.patch(`/api/notifications/${notificationId}/read`);
        const notification = this.notifications.find(n => n._id === notificationId);
        if (notification && !notification.read) {
          notification.read = true;
          this.unreadCount--;
        }
      } catch (error) {
        console.error('Error marking notification as read:', error);
        throw error;
      }
    },

    async markAllAsRead() {
      try {
        await axiosInstance.patch('/api/notifications/read-all');
        this.notifications.forEach(notification => {
          notification.read = true;
        });
        this.unreadCount = 0;
      } catch (error) {
        console.error('Error marking all notifications as read:', error);
        throw error;
      }
    },

    async deleteNotification(notificationId) {
      try {
        await axiosInstance.delete(`/api/notifications/${notificationId}`);
        this.notifications = this.notifications.filter(n => n._id !== notificationId);
        const deletedNotification = this.notifications.find(n => n._id === notificationId);
        if (deletedNotification && !deletedNotification.read) {
          this.unreadCount--;
        }
      } catch (error) {
        console.error('Error deleting notification:', error);
        throw error;
      }
    }
  }
}); 