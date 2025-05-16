import Drug from '../models/Drug.js';

export const searchDrugs = async (req, res) => {
  try {
    const { query, category, type } = req.query;
    let searchConditions = {};

    // Nếu có từ khóa tìm kiếm
    if (query) {
      searchConditions.$or = [
        { name: { $regex: query, $options: 'i' } },
        { activeIngredient: { $regex: query, $options: 'i' } },
        { uses: { $regex: query, $options: 'i' } }
      ];
    }

    // Nếu có lọc theo danh mục
    if (category) {
      searchConditions.category = category;
    }

    // Nếu có lọc theo dạng bào chế
    if (type) {
      searchConditions.type = type;
    }

    console.log('Search conditions:', searchConditions);

    const drugs = await Drug.find(searchConditions)
      .sort({ name: 1 })
      .limit(50);

    console.log('Found drugs:', drugs.length);

    res.json(drugs);
  } catch (error) {
    console.error('Error searching drugs:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

export const getDrugById = async (req, res) => {
  try {
    const { id } = req.params;
    const drug = await Drug.findById(id);

    if (!drug) {
      return res.status(404).json({ message: 'Không tìm thấy thuốc' });
    }

    res.json(drug);
  } catch (error) {
    console.error('Error getting drug:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

export const createDrug = async (req, res) => {
  try {
    const drug = new Drug(req.body);
    await drug.save();
    res.status(201).json(drug);
  } catch (error) {
    console.error('Error creating drug:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

export const updateDrug = async (req, res) => {
  try {
    const { id } = req.params;
    const drug = await Drug.findByIdAndUpdate(id, req.body, { new: true });

    if (!drug) {
      return res.status(404).json({ message: 'Không tìm thấy thuốc' });
    }

    res.json(drug);
  } catch (error) {
    console.error('Error updating drug:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

export const deleteDrug = async (req, res) => {
  try {
    const { id } = req.params;
    const drug = await Drug.findByIdAndDelete(id);

    if (!drug) {
      return res.status(404).json({ message: 'Không tìm thấy thuốc' });
    }

    res.json({ message: 'Xóa thuốc thành công' });
  } catch (error) {
    console.error('Error deleting drug:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
}; 