import querystring from 'qs';
import crypto from 'crypto';
import { createVNPayUrl, verifyVNPayResponse } from '../utils/vnpayHelper.js';

export  const createPaymentUrl = (req, res) => {
  try {
    const { amount, orderInfo } = req.body;

    if (!amount || !orderInfo) {
      return res.status(400).json({ message: 'Thiếu thông tin thanh toán' });
    }

    const paymentUrl = createVNPayUrl(amount, orderInfo, req);
    res.status(200).json({ paymentUrl });
  } catch (error) {
    console.error('Error creating VNPay payment URL:', error);
    res.status(500).json({ message: 'Không thể tạo URL thanh toán' });
  }
};

export  const vnpayReturn = (req, res) => {
  try {
    const isValid = verifyVNPayResponse(req.query);

    if (!isValid) {
      return res.status(400).send('Chữ ký không hợp lệ!');
    }

    if (req.query.vnp_ResponseCode === '00') {
      res.send('Thanh toán thành công!');
    } else {
      res.send('Thanh toán không thành công!');
    }
  } catch (error) {
    console.error('Error verifying VNPay response:', error);
    res.status(500).send('Đã xảy ra lỗi khi xử lý thanh toán');
  }
};
