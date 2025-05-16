import Contact from '../models/Contact.js';
import nodemailer from 'nodemailer';

// Cấu hình nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Tạo liên hệ mới
export const createContact = async (req, res) => {
  try {
    const { name, email, phone, subject, message, status } = req.body;

    const contact = new Contact({
      name,
      email,
      phone,
      subject,
      message,
      status: status || 'new'
    });

    await contact.save();

    // Gửi email thông báo cho admin
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: process.env.ADMIN_EMAIL || 'admin@example.com',
      subject: 'Liên hệ mới từ website',
      html: `
        <h2>Thông tin liên hệ mới</h2>
        <p><strong>Tên:</strong> ${name}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Số điện thoại:</strong> ${phone || 'Không có'}</p>
        <p><strong>Chủ đề:</strong> ${subject || 'Không có chủ đề'}</p>
        <p><strong>Nội dung:</strong></p>
        <p>${message}</p>
      `
    };

    // Gửi email không đồng bộ
    transporter.sendMail(mailOptions).catch(err => {
      console.error('Lỗi khi gửi email thông báo:', err);
    });

    // Gửi email xác nhận cho người dùng
    const userMailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Xác nhận liên hệ - HealthRight',
      html: `
        <h2>Cảm ơn bạn đã liên hệ với HealthRight</h2>
        <p>Chúng tôi đã nhận được tin nhắn của bạn và sẽ phản hồi trong thời gian sớm nhất.</p>
        <p>Dưới đây là thông tin bạn đã gửi:</p>
        <p><strong>Chủ đề:</strong> ${subject || 'Không có chủ đề'}</p>
        <p><strong>Nội dung:</strong></p>
        <p>${message}</p>
        <hr>
        <p>Đây là email tự động, vui lòng không trả lời email này.</p>
        <p>Trân trọng,<br>Đội ngũ HealthRight</p>
      `
    };

    // Gửi email xác nhận không đồng bộ
    transporter.sendMail(userMailOptions).catch(err => {
      console.error('Lỗi khi gửi email xác nhận:', err);
    });

    res.status(200).json({
      success: true,
      message: 'Đã gửi liên hệ thành công',
      contact
    });
  } catch (error) {
    console.error('Lỗi khi tạo liên hệ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi gửi liên hệ',
      error: error.message
    });
  }
};

// Lấy danh sách liên hệ (cho admin)
export const getContacts = async (req, res) => {
  try {
    const { page = 1, limit = 10, sort = 'newest', search = '', status } = req.query;
    
    // Xây dựng query
    const query = { isDeleted: false };
    
    // Thêm điều kiện tìm kiếm
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { subject: { $regex: search, $options: 'i' } },
        { message: { $regex: search, $options: 'i' } }
      ];
    }
    
    // Lọc theo trạng thái
    if (status && ['new', 'in-progress', 'completed'].includes(status)) {
      query.status = status;
    }
    
    // Xác định cách sắp xếp
    let sortOptions = {};
    switch(sort) {
      case 'newest':
        sortOptions = { createdAt: -1 };
        break;
      case 'oldest':
        sortOptions = { createdAt: 1 };
        break;
      case 'name-asc':
        sortOptions = { name: 1 };
        break;
      case 'name-desc':
        sortOptions = { name: -1 };
        break;
      default:
        sortOptions = { createdAt: -1 };
    }
    
    // Đếm tổng số liên hệ thỏa mãn điều kiện
    const total = await Contact.countDocuments(query);
    
    // Lấy danh sách theo phân trang
    const contacts = await Contact.find(query)
      .sort(sortOptions)
      .skip((page - 1) * limit)
      .limit(Number(limit));
    
    res.status(200).json({
      success: true,
      contacts,
      total,
      page: Number(page),
      limit: Number(limit),
      totalPages: Math.ceil(total / limit)
    });
  } catch (error) {
    console.error('Lỗi khi lấy danh sách liên hệ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lấy danh sách liên hệ',
      error: error.message
    });
  }
};

// Lấy chi tiết liên hệ
export const getContactById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const contact = await Contact.findOne({ _id: id, isDeleted: false });
    
    if (!contact) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy liên hệ'
      });
    }
    
    res.status(200).json({
      success: true,
      contact
    });
  } catch (error) {
    console.error('Lỗi khi lấy chi tiết liên hệ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi lấy chi tiết liên hệ',
      error: error.message
    });
  }
};

// Cập nhật trạng thái liên hệ
export const updateContactStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    if (!['new', 'in-progress', 'completed'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Trạng thái không hợp lệ'
      });
    }
    
    const contact = await Contact.findByIdAndUpdate(
      id, 
      { status }, 
      { new: true }
    );
    
    if (!contact) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy liên hệ'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Cập nhật trạng thái thành công',
      contact
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật trạng thái liên hệ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi cập nhật trạng thái liên hệ',
      error: error.message
    });
  }
};

// Xóa liên hệ (soft delete)
export const deleteContact = async (req, res) => {
  try {
    const { id } = req.params;
    
    const contact = await Contact.findByIdAndUpdate(
      id, 
      { isDeleted: true }, 
      { new: true }
    );
    
    if (!contact) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy liên hệ'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Xóa liên hệ thành công'
    });
  } catch (error) {
    console.error('Lỗi khi xóa liên hệ:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi xóa liên hệ',
      error: error.message
    });
  }
};

// Gửi phản hồi
export const replyToContact = async (req, res) => {
  try {
    const { id } = req.params;
    const { message } = req.body;
    
    if (!message || message.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Nội dung phản hồi không được để trống'
      });
    }
    
    const contact = await Contact.findById(id);
    
    if (!contact) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy liên hệ'
      });
    }
    
    // Thêm phản hồi vào mảng replies
    contact.replies.push({ message });
    
    // Cập nhật trạng thái
    contact.status = 'completed';
    
    await contact.save();
    
    // Gửi email phản hồi
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: contact.email,
      subject: `Phản hồi: ${contact.subject || 'Liên hệ từ website'}`,
      html: `
        <h2>Phản hồi từ HealthRight</h2>
        <p>Chào ${contact.name},</p>
        <p>Cảm ơn bạn đã liên hệ với chúng tôi. Dưới đây là phản hồi cho tin nhắn của bạn:</p>
        <div style="padding: 15px; background-color: #f8f9fa; border-left: 4px solid #007bff; margin: 20px 0;">
          ${message}
        </div>
        <p><strong>Nội dung liên hệ ban đầu:</strong></p>
        <div style="padding: 15px; background-color: #f8f9fa; border-left: 4px solid #6c757d; margin: 20px 0;">
          ${contact.message}
        </div>
        <hr>
        <p>Nếu bạn có bất kỳ câu hỏi nào khác, đừng ngần ngại liên hệ lại với chúng tôi.</p>
        <p>Trân trọng,<br>Đội ngũ HealthRight</p>
      `
    };
    
    // Gửi email không đồng bộ
    transporter.sendMail(mailOptions).catch(err => {
      console.error('Lỗi khi gửi email phản hồi:', err);
    });
    
    res.status(200).json({
      success: true,
      message: 'Gửi phản hồi thành công',
      contact
    });
  } catch (error) {
    console.error('Lỗi khi gửi phản hồi:', error);
    res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi gửi phản hồi',
      error: error.message
    });
  }
}; 