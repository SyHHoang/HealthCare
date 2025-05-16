import express from 'express';
import Transaction from '../models/Transaction.js';
import { authenticateToken, isAdmin } from '../middlewares/authMiddleware.js';
import moment from 'moment';

const router = express.Router();

// Lấy danh sách giao dịch (chỉ admin)
router.get('/', authenticateToken, isAdmin, async (req, res) => {
    try {
        const { page = 1, limit = 10, status, startDate, endDate } = req.query;
        
        // Xây dựng query
        let query = {};
        
        if (status) {
            query.status = status;
        }
        
        if (startDate || endDate) {
            query.transactionDate = {};
            if (startDate) {
                query.transactionDate.$gte = new Date(startDate);
            }
            if (endDate) {
                query.transactionDate.$lte = new Date(endDate);
            }
        }

        // Thực hiện query với phân trang
        const transactions = await Transaction.find(query)
            .populate('userId', 'fullname email')
            .populate('doctorId', 'fullName specialty')
            .sort({ transactionDate: -1 })
            .skip((page - 1) * limit)
            .limit(parseInt(limit));

        // Đếm tổng số giao dịch
        const total = await Transaction.countDocuments(query);

        res.json({
            transactions,
            total,
            currentPage: parseInt(page),
            totalPages: Math.ceil(total / limit)
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Lấy chi tiết một giao dịch
router.get('/:id', authenticateToken, isAdmin, async (req, res) => {
    try {
        const transaction = await Transaction.findById(req.params.id)
            .populate('userId', 'fullname email phone')
            .populate('doctorId', 'fullName specialty')
            .populate('consultationId');

        if (!transaction) {
            return res.status(404).json({ message: 'Không tìm thấy giao dịch' });
        }

        res.json(transaction);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Thống kê giao dịch
router.get('/stats/summary', authenticateToken, isAdmin, async (req, res) => {
    try {
        const today = moment().startOf('day');
        const last7Days = moment().subtract(6, 'days').startOf('day');

        // Thống kê hôm nay
        const dailyStats = await Transaction.aggregate([
            {
                $match: {
                    transactionDate: {
                        $gte: today.toDate(),
                        $lte: moment().endOf('day').toDate()
                    }
                }
            },
            {
                $group: {
                    _id: null,
                    totalAmount: { $sum: '$amount' },
                    count: { $sum: 1 }
                }
            }
        ]);

        // Thống kê theo trạng thái
        const statusStats = await Transaction.aggregate([
            {
                $group: {
                    _id: '$status',
                    count: { $sum: 1 }
                }
            }
        ]);

        // Doanh thu 7 ngày gần nhất
        const revenueData = await Transaction.aggregate([
            {
                $match: {
                    transactionDate: {
                        $gte: last7Days.toDate(),
                        $lte: moment().endOf('day').toDate()
                    },
                    status: { $in: ['success', 'paid_to_doctor'] }
                }
            },
            {
                $group: {
                    _id: {
                        $dateToString: {
                            format: '%Y-%m-%d',
                            date: '$transactionDate'
                        }
                    },
                    totalAmount: { $sum: '$amount' }
                }
            },
            {
                $sort: { '_id': 1 }
            }
        ]);

        // Xử lý dữ liệu cho biểu đồ
        const labels = [];
        const data = [];
        let currentDate = last7Days;

        while (currentDate <= moment()) {
            const dateStr = currentDate.format('YYYY-MM-DD');
            const revenue = revenueData.find(item => item._id === dateStr);
            
            labels.push(currentDate.format('DD/MM'));
            data.push(revenue ? revenue.totalAmount : 0);
            
            currentDate = currentDate.clone().add(1, 'day');
        }

        // Chuyển đổi mảng statusStats thành đối tượng
        const byStatus = {};
        statusStats.forEach(item => {
            byStatus[item._id] = item.count;
        });

        // Đảm bảo tất cả các trạng thái đều có giá trị
        const allStatuses = ['success', 'failed', 'pending', 'paid_to_doctor'];
        allStatuses.forEach(status => {
            if (!byStatus[status]) {
                byStatus[status] = 0;
            }
        });

        // Định dạng dữ liệu trả về
        const response = {
            daily: {
                totalAmount: dailyStats[0]?.totalAmount || 0,
                count: dailyStats[0]?.count || 0
            },
            byStatus,
            revenueChart: {
                labels,
                data
            }
        };

        console.log('Stats response:', response);
        res.json(response);
    } catch (error) {
        console.error('Error getting stats:', error);
        res.status(500).json({ message: 'Lỗi khi lấy thống kê' });
    }
});

// Route cập nhật trạng thái giao dịch
router.patch('/:id/status', authenticateToken, isAdmin, async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const transaction = await Transaction.findByIdAndUpdate(
            id,
            { status },
            { new: true }
        ).populate('doctorId', 'fullName email');

        if (!transaction) {
            return res.status(404).json({ message: 'Không tìm thấy giao dịch' });
        }

        // Nếu trạng thái là đã gửi tiền cho bác sĩ, gửi thông báo cho bác sĩ
        if (status === 'paid_to_doctor' && transaction.doctorId) {
            // TODO: Gửi email thông báo cho bác sĩ
            console.log(`Đã gửi tiền cho bác sĩ ${transaction.doctorId.fullName} - ${transaction.amount}đ`);
            
            // Thêm vào đây code gửi email cho bác sĩ nếu cần
        }

        res.json(transaction);
    } catch (error) {
        console.error('Error updating transaction status:', error);
        res.status(500).json({ message: 'Lỗi khi cập nhật trạng thái giao dịch' });
    }
});

export default router; 