import News from '../models/News.js';
import axios from 'axios';
import FormData from 'form-data';

// Thêm API key cho ImageBB
const IMAGEBB_API_KEY = '5faede19ecd35b0c3aabfef35de7d0bd';

export const getAllNews = async (req, res) => {
  try {
    const news = await News.find().sort({ date: -1 });
    res.json(news);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

export const getNewsById = async (req, res) => {
  try {
    const article = await News.findById(req.params.id);
    if (!article) return res.status(404).json({ message: "Bài viết không tồn tại!" });
    // Tăng số lượt xem
    article.viewCount += 1;
    // Cập nhật lịch sử xem
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Đặt thời gian về 00:00:00
    // Tìm bản ghi cho ngày hiện tại
    const todayRecord = article.viewHistory.find(record => {
      const recordDate = new Date(record.date);
      recordDate.setHours(0, 0, 0, 0);
      return recordDate.getTime() === today.getTime();
    });
    
    if (todayRecord) {
      // Nếu đã có bản ghi cho ngày hôm nay, tăng số lượt xem
      todayRecord.count += 1;
    } else {
      // Nếu chưa có, thêm mới bản ghi
      article.viewHistory.push({
        date: today,
        count: 1
      });
    }
    
    // Giới hạn lịch sử xem 30 ngày gần nhất
    if (article.viewHistory.length > 30) {
      article.viewHistory.sort((a, b) => new Date(b.date) - new Date(a.date));
      article.viewHistory = article.viewHistory.slice(0, 30);
    }
    
    // Lưu lại thay đổi
    //const updatedArticle = await article.save();
   // console.log("-----------------------update-------------", updatedArticle);
    res.json(article);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

export const addNews = async (req, res) => {
  try {
    const { title, content, summary, category, coverImage } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (!title || !content || !category) {
      return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin bài viết" });
    }

    // Tạo bài viết mới
    const newArticle = new News({
      title,
      content,
      summary: summary || "",
      category,
      coverImage: coverImage || "",
      author: req.user.userId,
    });

    // Lưu vào database
    const savedArticle = await newArticle.save();
    res.status(201).json({
      message: "Thêm bài viết thành công",
      article: savedArticle,
    });
  } catch (error) {
    console.error("Lỗi khi thêm bài viết:", error);
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
};

// Controller để upload ảnh lên ImageBB
export const uploadImage = async (req, res) => {
  try {
    // Kiểm tra xem có file được upload không
    if (!req.files || Object.keys(req.files).length === 0) {
      return res.status(400).json({ success: false, message: 'Không có file nào được tải lên' });
    }

    const imageFile = req.files.image;
    
    // Kiểm tra kích thước file (giới hạn 5MB)
    if (imageFile.size > 5 * 1024 * 1024) {
      return res.status(400).json({ success: false, message: 'Kích thước file quá lớn. Giới hạn 5MB' });
    }

    // Kiểm tra định dạng file
    const allowedFormats = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedFormats.includes(imageFile.mimetype)) {
      return res.status(400).json({ success: false, message: 'Định dạng file không hỗ trợ. Chỉ chấp nhận JPG, PNG, GIF và WEBP' });
    }

    // Tạo form data để gửi lên ImageBB
    const formData = new FormData();
    formData.append('image', imageFile.data.toString('base64'));

    // Gửi request đến ImageBB API
    const response = await axios.post(`https://api.imgbb.com/1/upload?key=${IMAGEBB_API_KEY}`, formData);

    // Trả về URL của ảnh
    return res.status(200).json({
      success: true,
      imageUrl: response.data.data.url,
      displayUrl: response.data.data.display_url,
      deleteUrl: response.data.data.delete_url
    });

  } catch (error) {
    console.error('Lỗi upload ảnh:', error);
    res.status(500).json({ success: false, message: 'Lỗi khi tải ảnh lên server' });
  }
};

// Thêm hàm để lấy thống kê lượt xem
export const getNewsStats = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Nếu có id bài viết cụ thể, lấy thống kê của bài viết đó
    if (id) {
      const article = await News.findById(id);
      if (!article) {
        return res.status(404).json({ message: "Bài viết không tồn tại!" });
      }
      
      // Sắp xếp lịch sử xem theo ngày (gần nhất đến xa nhất)
      const sortedViewHistory = [...article.viewHistory].sort((a, b) => 
        new Date(b.date) - new Date(a.date)
      );
      
      return res.json({
        articleId: article._id,
        title: article.title,
        totalViews: article.viewCount,
        viewHistory: sortedViewHistory
      });
    }
    
    // Nếu không có id, lấy thống kê của tất cả bài viết
    const allNews = await News.find({}, {
      _id: 1,
      title: 1,
      viewCount: 1,
      category: 1,
      createdAt: 1
    }).sort({ viewCount: -1 });
    
    // Tổng số lượt xem của tất cả bài viết
    const totalViews = allNews.reduce((sum, article) => sum + article.viewCount, 0);
    
    // Thống kê số lượt xem theo danh mục
    const categoryStats = {};
    allNews.forEach(article => {
      if (!categoryStats[article.category]) {
        categoryStats[article.category] = {
          count: 0,
          views: 0
        };
      }
      categoryStats[article.category].count += 1;
      categoryStats[article.category].views += article.viewCount;
    });
    
    res.json({
      totalArticles: allNews.length,
      totalViews,
      categoryStats,
      topArticles: allNews.slice(0, 10) // Top 10 bài viết xem nhiều nhất
    });
  } catch (error) {
    console.error('Lỗi khi lấy thống kê bài viết:', error);
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

// Cập nhật bài viết
export const updateNews = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, summary, category, coverImage, GoogleDocsId } = req.body;
    
    // Kiểm tra dữ liệu đầu vào
    if (!title || !content || !category) {
      return res.status(400).json({ 
        success: false,
        message: "Vui lòng điền đầy đủ thông tin bài viết" 
      });
    }
    
    // Kiểm tra bài viết có tồn tại không
    const article = await News.findById(id);
    if (!article) {
      return res.status(404).json({ 
        success: false,
        message: "Bài viết không tồn tại!" 
      });
    }

    // Kiểm tra quyền sửa bài viết
    // Chỉ tác giả hoặc admin mới được sửa
    if (article.author.toString() !== req.user.userId && req.user.role !== 'admin') {
      return res.status(403).json({ 
        success: false,
        message: "Bạn không có quyền sửa bài viết này!" 
      });
    }
    
    // Cập nhật thông tin bài viết
    const updateData = {
      title,
      content,
      summary: summary || "",
      category,
      GoogleDocsId: GoogleDocsId || article.GoogleDocsId
    };

    // Chỉ cập nhật ảnh bìa nếu có thay đổi
    if (coverImage) {
      updateData.coverImage = coverImage;
    }
    
    // Cập nhật bài viết và trả về thông tin mới
    const updatedArticle = await News.findByIdAndUpdate(
      id,
      updateData,
      { 
        new: true, 
        runValidators: true 
      }
    ).populate('author', 'fullname');
    
    if (!updatedArticle) {
      return res.status(500).json({
        success: false,
        message: "Không thể cập nhật bài viết"
      });
    }

    res.json({
      success: true,
      message: "Cập nhật bài viết thành công",
      data: updatedArticle
    });
  } catch (error) {
    console.error("Lỗi khi cập nhật bài viết:", error);
    
    // Xử lý lỗi validation
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ 
        success: false,
        message: "Dữ liệu không hợp lệ", 
        errors 
      });
    }
    
    // Xử lý lỗi khác
    res.status(500).json({ 
      success: false,
      message: "Lỗi server", 
      error: error.message 
    });
  }
};

// Xóa bài viết
export const deleteNews = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Kiểm tra bài viết có tồn tại không
    const article = await News.findById(id);
    if (!article) {
      return res.status(404).json({ message: "Bài viết không tồn tại!" });
    }
    
    // Xóa bài viết
    await News.findByIdAndDelete(id);
    
    res.json({
      message: "Xóa bài viết thành công"
    });
  } catch (error) {
    console.error("Lỗi khi xóa bài viết:", error);
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
};

export const getLatestNews = async (req, res) => {
  try { 
    const latestNews = await News.find()
      .sort({ createdAt: -1 })
      .limit(3)
      .select('title summary coverImage category createdAt')
      .lean();
    if (!latestNews || latestNews.length === 0) {
      return res.json({
        success: true,
        data: []
      });
    }
    res.json({
      success: true,
      data: latestNews
    });
  } catch (error) {
    console.error('Lỗi khi lấy tin tức mới nhất:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy tin tức mới nhất',
      error: error.message
    });
  }
};
