import querystring from 'qs';
import crypto from 'crypto';

const vnp_TmnCode = ' 6TKZOEY6'; // Mã website của bạn
const vnp_HashSecret = '58DTNAH43B7TX7H90ZAFQI4LCAW3NNNN'; // Chuỗi bí mật
const vnp_Url = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html'; // URL VNPay test
const vnp_ReturnUrl = 'https://3105-42-113-60-233.ngrok-free.app/vnpay_return'; // URL trả về sau thanh toán

export const createVNPayUrl = (amount, orderInfo, req) => {
  const date = new Date();
  const createDate = `${date.getFullYear()}${(date.getMonth() + 1)
    .toString()
    .padStart(2, '0')}${date.getDate().toString().padStart(2, '0')}${date
    .getHours()
    .toString()
    .padStart(2, '0')}${date.getMinutes().toString().padStart(2, '0')}${date
    .getSeconds()
    .toString()
    .padStart(2, '0')}`;

  const orderId = `${date.getTime()}`; // Mã đơn hàng duy nhất

  const ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

  const params = {
    vnp_Version: '2.1.0',
    vnp_Command: 'pay',
    vnp_TmnCode,
    vnp_Locale: 'vn',
    vnp_CurrCode: 'VND',
    vnp_TxnRef: orderId,
    vnp_OrderInfo: orderInfo,
    vnp_OrderType: 'billpayment',
    vnp_Amount: amount * 100, // Số tiền (nhân 100 để chuyển sang đơn vị VNĐ)
    vnp_ReturnUrl,
    vnp_IpAddr: ipAddr,
    vnp_CreateDate: createDate,
  };

  // Tạo URL thanh toán
  const sortedParams = querystring.stringify(params, { encode: false });
  const signData = crypto
    .createHmac('sha512', vnp_HashSecret)
    .update(sortedParams)
    .digest('hex');

  params.vnp_SecureHash = signData;
  return `${vnp_Url}?${querystring.stringify(params)}`;
};

export const verifyVNPayResponse = (query) => {
  const secureHash = query.vnp_SecureHash;
  delete query.vnp_SecureHash;
  delete query.vnp_SecureHashType;

  const sortedParams = querystring.stringify(query, { encode: false });
  const signData = crypto
    .createHmac('sha512', vnp_HashSecret)
    .update(sortedParams)
    .digest('hex');

  return secureHash === signData;
};