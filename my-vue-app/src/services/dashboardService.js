import axios from 'axios'

const API_URL = 'http://localhost:5000/api'

export const dashboardService = {
  // Lấy thống kê tổng quan
  async getStats() {
    try {
      const [userStats, doctorStats] = await Promise.all([
        axios.get(`${API_URL}/users/stats/total`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`
          }
        }),
        axios.get(`${API_URL}/doctors/stats/total`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`
          }
        })
      ])

      return {
        // Thống kê bệnh nhân
        totalUsers: userStats.data.totalUsers,
        activeUsers: userStats.data.activeUsers,
        inactiveUsers: userStats.data.inactiveUsers,
        userRegistrationStats: userStats.data.registrationStats,
        userAgeStats: userStats.data.ageStats,
        userGenderStats: userStats.data.genderStats,

        // Thống kê bác sĩ
        totalDoctors: doctorStats.data.totalDoctors,
        activeDoctors: doctorStats.data.activeDoctors,
        inactiveDoctors: doctorStats.data.inactiveDoctors,
        verifiedDoctors: doctorStats.data.verifiedDoctors,
        unverifiedDoctors: doctorStats.data.unverifiedDoctors,
        doctorSpecialtyStats: doctorStats.data.specialtyStats,
        doctorRegistrationStats: doctorStats.data.registrationStats
      }
    } catch (error) {
      console.error('Lỗi khi lấy thống kê:', error)
      return {
        totalUsers: 0,
        activeUsers: 0,
        inactiveUsers: 0,
        userRegistrationStats: [],
        userAgeStats: [],
        userGenderStats: [],
        totalDoctors: 0,
        activeDoctors: 0,
        inactiveDoctors: 0,
        verifiedDoctors: 0,
        unverifiedDoctors: 0,
        doctorSpecialtyStats: [],
        doctorRegistrationStats: []
      }
    }
  },

  // Lấy thống kê lượt xem
  async getViewStats() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axios.get('/api/news/stats/views', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
  },

  // Lấy thống kê lượt xem của một bài viết cụ thể
  async getArticleViewStats(articleId) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axios.get(`/api/news/stats/views/${articleId}`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
  },

  // Lấy số lượng người dùng
  async getUserCount() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axios.get('/api/users/count', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
  },

  // Lấy số lượng phản hồi
  async getFeedbackCount() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axios.get('/api/feedback/count', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
  },

  async getRevenueStats() {
    const response = await axios.get(`${API_URL}/transactions/stats/revenue`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
    return response.data
  },

  async getTotalPosts() {
    try {
      const response = await axios.get(`${API_URL}/news/stats/summary`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      });
      return response.data.totalPosts || 0;
    } catch (error) {
      console.error('Lỗi khi lấy tổng số bài viết:', error);
      return 0;
    }
  },

  async getTotalFeedbacks() {
    try {
      const response = await axios.get(`${API_URL}/feedback/stats/summary`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      });
      return response.data.totalFeedbacks || 0;
    } catch (error) {
      console.error('Lỗi khi lấy tổng số phản hồi:', error);
      return 0;
    }
  },

  async getTotalRevenue() {
    try {
      const response = await axios.get(`${API_URL}/transactions/stats/summary`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      });
      return response.data.totalRevenue || 0;
    } catch (error) {
      console.error('Lỗi khi lấy tổng doanh thu:', error);
      return 0;
    }
  },

  async getTotalConsultations() {
    try {
      const response = await axios.get(`${API_URL}/consultationList/stats/summary`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      });
      return response.data.totalConsultations || 0;
    } catch (error) {
      console.error('Lỗi khi lấy tổng số lượt tư vấn:', error);
      return 0;
    }
  }
} 