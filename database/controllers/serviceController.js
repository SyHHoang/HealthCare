import Service from '../models/Service.js';

export const getFeaturedServices = async (req, res) => {
  try {
    console.log('Đang lấy danh sách dịch vụ nổi bật...');
    
    const featuredServices = await Service.find({
      isFeatured: true,
      status: 'active'
    })
    .select('name description image category price duration')
    .limit(3)
    .lean();

    console.log('Dịch vụ nổi bật:', featuredServices);

    res.json({
      success: true,
      data: featuredServices
    });
  } catch (error) {
    console.error('Lỗi khi lấy dịch vụ nổi bật:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy dịch vụ nổi bật',
      error: error.message
    });
  }
}; 