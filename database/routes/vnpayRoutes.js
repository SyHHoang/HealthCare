/**
 * Created by CTT VNPAY
 */

import express from 'express';
import moment from 'moment';
import crypto from 'crypto';
import config from '../config/vnppay.json' with { type: 'json' };
import qs from 'qs';
import request from 'request';
import ConsultationList from '../models/ConsultationList.js';
import Transaction from '../models/Transaction.js';
import Chat from '../models/Chat.js';
import Notification from '../models/notificationModel.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import OrderType from '../models/orderType.js';
import { sendNotification } from '../config/firebase-config.js';
import User from '../models/User.js';
import Doctor from '../models/Doctor.js';
const router = express.Router();

router.get('/', (req, res) => {
    res.render('orderlist', { title: 'Danh sách đơn hàng' });
});

router.get('/create_payment_url', (req, res) => {
    res.render('order', { title: 'Tạo mới đơn hàng', amount: 10000 });
});

router.get('/querydr', (req, res) => {
    res.render('querydr', { title: 'Truy vấn kết quả thanh toán' });
});

router.get('/refund', (req, res) => {
    res.render('refund', { title: 'Hoàn tiền giao dịch thanh toán' });
});

router.post('/create_payment_url',authenticateToken, async (req, res) => {
    process.env.TZ = 'Asia/Ho_Chi_Minh';
    const date = new Date();
    const createDate = moment(date).format('YYYYMMDDHHmmss');
    const ipAddr = req.headers['x-forwarded-for'] || req.socket?.remoteAddress;
    const tmnCode = config.vnp_TmnCode;
    const secretKey = config.vnp_HashSecret;
    let vnpUrl = config.vnp_Url;
    const returnUrl = config.vnp_ReturnUrl;
    const orderType = req.body.orderType
    console.log("orderType",orderType)
    const orderId = `${moment().format('DDHHmmss')}${Math.floor(Math.random() * 1000)}`; // Kết hợp thời gian và 3 số ngẫu nhiên
    const amount = await OrderType.findOne({name: req.body.orderType}).select("-_id price")
    console.log("price",amount.price)
    const bankCode = req.body.bankCode;
    const quantity=req.body.quantity||1;
    let locale = req.body.language || 'vn';
    const currCode = 'VND';
    let vnp_Params = {
        vnp_Version: '2.1.0',
        vnp_Command: 'pay',
        vnp_TmnCode: tmnCode,
        vnp_Locale: locale,
        vnp_CurrCode: currCode,
        vnp_TxnRef: orderId,
        vnp_OrderInfo: `Thanh toan cho ma GD:${orderId}`,
        vnp_OrderType: orderType,
        vnp_Amount: amount.price * 100 * quantity,
        //vnp_Quantity: quantity,
        vnp_ReturnUrl: returnUrl,
        vnp_IpAddr: ipAddr,
        vnp_CreateDate: createDate,
        //vnp_IpnUrl: ipnUrl,
    };

    if (bankCode) {
        vnp_Params['vnp_BankCode'] = bankCode;
    }

    vnp_Params = sortObject(vnp_Params);

    const signData = qs.stringify(vnp_Params, { encode: false });
    const hmac = crypto.createHmac('sha512', secretKey);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
    vnp_Params['vnp_SecureHash'] = signed;

    vnpUrl += '?' + qs.stringify(vnp_Params, { encode: false });
    console.log('vnpUrl: ', vnpUrl);
        // Cập nhật thông tin giao dịch
        const transaction = new Transaction({
            txnRef: orderId,
            amount: amount.price * 100 * req.body.quantity|| 1 ,
            orderType: orderType,
            status: 'pending',
            paymentMethod: 'VNPay',
            bankCode: bankCode,
            userId: req.user.userId,
            doctorId: req.body.doctorId,
            quantity:req.body.quantity|| 1,
            orderType:orderType
        });
        const saveTransaction = await transaction.save();
        return res.json({ vnpUrl });
});

router.get('/vnpay_return', (req, res) => {
    let vnp_Params = { ...req.query };
    const secureHash = vnp_Params['vnp_SecureHash'];

    delete vnp_Params['vnp_SecureHash'];
    delete vnp_Params['vnp_SecureHashType'];

    vnp_Params = sortObject(vnp_Params);

    const secretKey = config.vnp_HashSecret;
    const signData = qs.stringify(vnp_Params, { encode: false });
    const hmac = crypto.createHmac('sha512', secretKey);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');

    if (secureHash === signed) {
        // Thanh toán thành công, render template với dữ liệu
        res.render('success', {
            code: vnp_Params['vnp_ResponseCode'],
            txnRef: vnp_Params['vnp_TxnRef'],
            amount: vnp_Params['vnp_Amount'] / 100, // Chuyển về VNĐ
            date: moment(vnp_Params['vnp_PayDate'], 'YYYYMMDDHHmmss').format('DD/MM/YYYY HH:mm:ss')
        });
    } else {
        // Chữ ký không hợp lệ
        res.render('success', {
            code: '97',
            txnRef: '',
            amount: 0,
            date: moment().format('DD/MM/YYYY HH:mm:ss')
        });
    }
});

router.get('/vnpay_ipn', async (req, res) => {
    let vnp_Params = { ...req.query };
    const secureHash = vnp_Params['vnp_SecureHash'];
    const orderId = vnp_Params['vnp_TxnRef'];
    const rspCode = vnp_Params['vnp_ResponseCode'];
    const ordertype=vnp_Params['vnp_OrderType'];
    const amount = parseInt(vnp_Params['vnp_Amount']) / 100; // Chuyển về VNĐ
    
    console.log("ordertype",ordertype)
    delete vnp_Params['vnp_SecureHash'];
    delete vnp_Params['vnp_SecureHashType'];
    vnp_Params = sortObject(vnp_Params);
    const secretKey = config.vnp_HashSecret;
    const signData = qs.stringify(vnp_Params, { encode: false });
    const hmac = crypto.createHmac('sha512', secretKey);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
    try {
        if (secureHash === signed) {
            // Kiểm tra và cập nhật giao dịch trong database
            console.log("orderId",orderId);
            const transaction = await Transaction.findOne({ txnRef: orderId });
            console.log("=======================================transaction",transaction)
            if (transaction) {
                // Cập nhật thông tin giao dịch
                transaction.status = rspCode === "00" ? "success" : "failed";
                transaction.responseCode = rspCode;
                transaction.paymentDetails = vnp_Params;
                transaction.bankCode = vnp_Params['vnp_BankCode'];
                transaction.transactionDate = moment(vnp_Params['vnp_PayDate'], 'YYYYMMDDHHmmss').toDate();
                const result = await transaction.save();
                let nameOrderType;
                switch (transaction.orderType) {
                    case 'consultation':
                        nameOrderType = 'Đăng ký bác sĩ tư vấn y tế';
                        break;
                    case 'Extend':
                        nameOrderType = 'Gia hạn thời gian tư vấn';
                        break;
                    case 'AddCallVideo':
                        nameOrderType = 'Thêm số lượt gọi video trực tuyến với bác sĩ';
                        break;
                    default:
                        nameOrderType = 'Dịch vụ không xác định';
                }
                // Lưu thông báo vào database
                const notification = new Notification({
                    userId: transaction.userId || transaction.doctorId,
                    title: `${nameOrderType} thành công`,
                    message: `${nameOrderType} thành công`,
                    type: 'payment_success',
                    data: {
                        'Mã đơn hàng':orderId,
                        'Số tiền':amount,
                        'Tên bác sĩ':transaction.doctorId.name,
                        'Loại giao dịch':nameOrderType,
                        'Ngày thanh toán':transaction.transactionDate
                    }
                });
                await notification.save();

                // Gửi thông báo qua FCM nếu thanh toán thành công
                if (rspCode === "00") {
                    try {
                        // Lấy FCM tokens của user từ database
                        const user = await User.findById(transaction.userId).select('fcmTokens');
                        console.log("user",user)
                        if (user && user.fcmTokens && user.fcmTokens.length > 0) {
                          const data = {
                            orderId: orderId.toString(),
                            quantity: String(transaction.quantity || 1),
                            transactionDate: transaction.transactionDate.toISOString(),
                            doctorName: transaction.doctorId?.name || '',
                            orderType: transaction.orderType || '',
                            type: 'payment_success'
                          };
                        
                          // Gửi thông báo đến tất cả các token của user
                          for (const token of user.fcmTokens) {
                            try {
                              await sendNotification(
                                token,
                                'Thanh toán thành công',
                                `Giao dịch ${nameOrderType} đã được thanh toán thành công`,
                                data
                              );
                              console.log(`Gửi thông báo thành công đến token: ${token}`);
                            } catch (error) {
                              console.error(`Lỗi khi gửi thông báo đến token ${token}:`, error);
                              // Nếu token không hợp lệ, xóa khỏi mảng
                              if (error.message.includes('Invalid registration token')) {
                                user.fcmTokens = user.fcmTokens.filter(t => t !== token);
                                await user.save();
                                console.log(`Đã xóa token không hợp lệ: ${token}`);
                              }
                            }
                          }
                        }

                        // Gửi thông báo cho bác sĩ nếu có
                        if (transaction.doctorId) {
                            const doctor = await Doctor.findById(transaction.doctorId).select('fcmTokens fullName');
                            if (doctor && doctor.fcmTokens && doctor.fcmTokens.length > 0) {
                                const doctorData = {
                                    orderId: orderId.toString(),
                                    amount: amount.toString(),
                                    orderType: transaction.orderType,
                                    transactionDate: transaction.transactionDate.toISOString(),
                                    type: 'payment_success',
                                    userId: transaction.userId.toString(),
                                    userName: doctor.fullName || 'Người dùng'
                                };
                                
                                // Gửi thông báo đến tất cả các token của bác sĩ
                                for (const token of doctor.fcmTokens) {
                                  try {
                                    await sendNotification(
                                      token,
                                      'Bạn có người đăng ký tư vấn mới',
                                      `Bệnh nhân ${doctor.fullName || 'Người dùng'} đã đăng ký tư vấn, số tiền sẽ được chuyển lại sau`,
                                      doctorData
                                    );
                                    console.log(`Gửi thông báo thành công đến token bác sĩ: ${token}`);
                                  } catch (error) {
                                    console.error(`Lỗi khi gửi thông báo đến token bác sĩ ${token}:`, error);
                                    // Nếu token không hợp lệ, xóa khỏi mảng
                                    if (error.message.includes('Invalid registration token')) {
                                      doctor.fcmTokens = doctor.fcmTokens.filter(t => t !== token);
                                      await doctor.save();
                                      console.log(`Đã xóa token không hợp lệ của bác sĩ: ${token}`);
                                    }
                                  }
                                }

                                // Lưu thông báo vào database
                                const notification = new Notification({
                                    userId: transaction.doctorId,
                                    title: 'Bạn có bệnh nhân mới',
                                    message: `Bệnh nhân ${doctor.fullName || 'Người dùng'} đã đăng ký tư vấn`,
                                    type: 'payment_success',
                                    data: {
                                        orderId: orderId,
                                        amount: amount,
                                        orderType: transaction.orderType,
                                        transactionDate: transaction.transactionDate,
                                        userId: transaction.userId,
                                        userName: doctor.fullName
                                    }
                                });
                                await notification.save();
                            }
                        }
                    } catch (error) {
                        console.error('Error sending FCM notification:', error);
                    }
                }
            } else {
                res.status(200).json({ RspCode: '01', Message: 'Order not found' });
            }
            if(transaction.orderType=='consultation'){
                const newConsultation=new ConsultationList({
                userId:transaction.userId,
                doctorId:transaction.doctorId,
                createdAt:transaction.createdAt
               });
               const saveConsultation=await newConsultation.save();
               const newChat=new Chat({
                userId:transaction.userId,
                doctorId:transaction.doctorId,
               });
               const saveChat=await newChat.save();
               if(saveConsultation && saveChat){
                res.status(200).json({ RspCode: '00', Message: 'Success' });
               }else{
                res.status(200).json({ RspCode: '01', Message: 'Order not found' });
               }
            }
            else if(transaction.orderType=='Extend'){
                console.log("Extend")
                const response = await ConsultationList.findOne({ doctorId: transaction.doctorId, userId: transaction.userId }).select("EndDate");

// Kiểm tra nếu response.EndDate đã tồn tại
if (response && response.EndDate) {
    // Chuyển EndDate từ chuỗi ISO thành đối tượng Date
    const endDate = new Date(response.EndDate);

    // Cộng thêm 14 ngày vào EndDate
    endDate.setDate(endDate.getDate() + 14);

    // Cập nhật lại EndDate
    response.EndDate = endDate;

    // Lưu thay đổi vào cơ sở dữ liệu
    await response.save();
} else {
    console.log("Không tìm thấy EndDate hợp lệ.");
}
            }
            else if(transaction.orderType=="AddCallVideo"){
                const response= await ConsultationList.findOne({doctorId:transaction.doctorId, userId:transaction.userId}).select("call")
                response.call+= transaction.quantity||1;
                console.log("call",response.call)
                await response.save();
            } 
        } else {
            res.status(200).json({ RspCode: '97', Message: 'Checksum failed' });
        }
    } catch (error) {
        console.error('Error processing IPN:', error);
        res.status(200).json({ RspCode: '99', Message: 'Unknown error' });
    }
});
router.post('/querydr', (req, res) => {
    process.env.TZ = 'Asia/Ho_Chi_Minh';
    const date = new Date();
    const vnp_TmnCode = config.vnp_TmnCode;
    const secretKey = config.vnp_HashSecret;
    const vnp_Api = config.vnp_Api;
    const vnp_TxnRef = req.body.orderId;
    const vnp_TransactionDate = req.body.transDate;
    const vnp_RequestId = moment(date).format('HHmmss');
    const vnp_Version = '2.1.0';
    const vnp_Command = 'querydr';
    const vnp_OrderInfo = `Truy van GD ma:${vnp_TxnRef}`;
    const vnp_IpAddr = req.headers['x-forwarded-for'] || req.socket?.remoteAddress;
    const vnp_CreateDate = moment(date).format('YYYYMMDDHHmmss');
    const data = `${vnp_RequestId}|${vnp_Version}|${vnp_Command}|${vnp_TmnCode}|${vnp_TxnRef}|${vnp_TransactionDate}|${vnp_CreateDate}|${vnp_IpAddr}|${vnp_OrderInfo}`;
    const hmac = crypto.createHmac('sha512', secretKey);
    const vnp_SecureHash = hmac.update(Buffer.from(data, 'utf-8')).digest('hex');
    const dataObj = {
        vnp_RequestId,
        vnp_Version,
        vnp_Command,
        vnp_TmnCode,
        vnp_TxnRef,
        vnp_OrderInfo,
        vnp_TransactionDate,
        vnp_CreateDate,
        vnp_IpAddr,
        vnp_SecureHash,
    };
    request({
        url: vnp_Api,
        method: 'POST',
        json: true,
        body: dataObj,
    }, (error, response, body) => {
        console.log(response.body);
        res.json(response.body);
    });
});

router.post('/refund', (req, res) => {
    process.env.TZ = 'Asia/Ho_Chi_Minh';
    const date = new Date();
    const vnp_TmnCode = config.vnp_TmnCode;
    const secretKey = config.vnp_HashSecret;
    const vnp_Api = config.vnp_Api;
    const vnp_TxnRef = req.body.orderId;
    const vnp_TransactionDate = req.body.transDate;
    const vnp_Amount = req.body.amount * 100;
    const vnp_TransactionType = req.body.transType;
    const vnp_CreateBy = req.body.user;
    const vnp_RequestId = moment(date).format('HHmmss');
    const vnp_Version = '2.1.0';
    const vnp_Command = 'refund';
    const vnp_OrderInfo = `Hoan tien GD ma:${vnp_TxnRef}`;
    const vnp_IpAddr = req.headers['x-forwarded-for'] || req.socket?.remoteAddress;
    const vnp_CreateDate = moment(date).format('YYYYMMDDHHmmss');
    const vnp_TransactionNo = '0';
    const data = `${vnp_RequestId}|${vnp_Version}|${vnp_Command}|${vnp_TmnCode}|${vnp_TransactionType}|${vnp_TxnRef}|${vnp_Amount}|${vnp_TransactionNo}|${vnp_TransactionDate}|${vnp_CreateBy}|${vnp_CreateDate}|${vnp_IpAddr}|${vnp_OrderInfo}`;
    const hmac = crypto.createHmac('sha512', secretKey);
    const vnp_SecureHash = hmac.update(Buffer.from(data, 'utf-8')).digest('hex');
    const dataObj = {
        vnp_RequestId,
        vnp_Version,
        vnp_Command,
        vnp_TmnCode,
        vnp_TransactionType,
        vnp_TxnRef,
        vnp_Amount,
        vnp_TransactionNo,
        vnp_CreateBy,
        vnp_OrderInfo,
        vnp_TransactionDate,
        vnp_CreateDate,
        vnp_IpAddr,
        vnp_SecureHash,
    };
    request({
        url: vnp_Api,
        method: 'POST',
        json: true,
        body: dataObj,
    }, (error, response, body) => {
        console.log(response.body);
        res.json(response.body);
    });
});

// Hàm sort object
function sortObject(obj) {
    const sorted = {};
    const keys = Object.keys(obj).sort();
    for (const key of keys) {
        sorted[key] = encodeURIComponent(obj[key]).replace(/%20/g, '+');
    }
    return sorted;
}

export default router;
