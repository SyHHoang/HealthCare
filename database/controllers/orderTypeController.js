import OrderType from '../models/orderType.js';

// Gửi tin nhắn
export const GetConsolutionID = async (req, res) => {
  try {
    const orderType = {
      orderID: '68139bb772afd4a706ed21ff',
    };
    res.status(201).json(orderType);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
};
export const GetQuantityAndExtendID = async (req, res) => {
  try {
    const orderTypeQuantity = {
      orderID: '68139bb772afd4a706ed2201',
    };
    const orderTypeExtend = {
      orderID: '68139bb772afd4a706ed2200',
    };
    res.status(201).json(orderTypeQuantity, orderTypeExtend );
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
};

export const AdminGetID = async (req, res) => {
    try {
      const resuilt = await OrderType.find();
      res.status(201).json(resuilt);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
  };
// Lấy lịch sử chat giữa user và doctor
export const AdminChangePrice = async (req, res) => {
    try {
        const { id } = req.params; // Lấy ID từ params
        const updated = await OrderType.findByIdAndUpdate(
          id,
          {
            price: newPrice,
            updateAt: new Date()
          },
        );
    
        if (!updated) {
          console.log('Không tìm thấy OrderType với ID:', id);
          return null;
        }
    
        console.log('Đã cập nhật:', updated);
        return updated;
      } catch (err) {
        console.error('Lỗi khi cập nhật price:', err);
        throw err;
      }
};

// Lấy tất cả loại đơn hàng
export const getAllOrderTypes = async (req, res) => {
  try {
    const orderTypes = await OrderType.find();
    res.status(200).json(orderTypes);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
};

// Lấy thông tin một loại đơn hàng theo ID
export const getOrderTypeById = async (req, res) => {
  try {
    const orderType = await OrderType.findById(req.params.id);
    if (!orderType) {
      return res.status(404).json({ message: 'Không tìm thấy loại đơn hàng' });
    }
    res.status(200).json(orderType);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
};

// Cập nhật thông tin loại đơn hàng
export const updateOrderType = async (req, res) => {
  try {
    const { name, price } = req.body;
    const orderType = await OrderType.findById(req.params.id);

    if (!orderType) {
      return res.status(404).json({ message: 'Không tìm thấy loại đơn hàng' });
    }

    if (name) orderType.name = name;
    if (price) orderType.price = price;
    orderType.updateAt = new Date();

    const updatedOrderType = await orderType.save();
    res.status(200).json(updatedOrderType);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
};
