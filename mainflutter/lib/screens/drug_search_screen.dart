import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drug_provider.dart';

class DrugSearchScreen extends ConsumerStatefulWidget {
  const DrugSearchScreen({super.key});

  @override
  ConsumerState<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends ConsumerState<DrugSearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedType;

  final List<String> _categories = [
    'Thuốc kê đơn',
    'Thuốc không kê đơn',
    'Thực phẩm chức năng',
    'Dược mỹ phẩm'
  ];

  final List<String> _types = [
    'Viên nén',
    'Viên nang',
    'Dung dịch',
    'Thuốc tiêm',
    'Thuốc bôi',
    'Thuốc xịt'
  ];

  @override
  void initState() {
    super.initState();
    // Đánh dấu drugLoaded để biết đã từng mở màn hình này
    Future.microtask(() {
      final isLoaded = ref.read(drugLoadedProvider);
      if (!isLoaded) {
        ref.read(drugLoadedProvider.notifier).setLoaded(true);
      }
    });
  }

  // Phương thức để thực hiện tìm kiếm thuốc
  void _searchDrugs() {
    ref.read(drugSearchProvider.notifier).searchDrugs(
          query: _searchController.text,
          category: _selectedCategory,
          type: _selectedType,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drugs = ref.watch(drugSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu thuốc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _searchDrugs,
            tooltip: 'Tải lại dữ liệu',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên thuốc, hoạt chất hoặc công dụng...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchDrugs();
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchDrugs,
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _searchDrugs(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ..._categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          _searchDrugs();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Dạng bào chế',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ..._types.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                          _searchDrugs();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: drugs.when(
              data: (drugList) {
                if (drugList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Không tìm thấy thuốc nào'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _searchDrugs,
                          child: const Text('Tải lại dữ liệu'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: drugList.length,
                  itemBuilder: (context, index) {
                    final drug = drugList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(drug.name),
                        subtitle: Text(
                          '${drug.activeIngredient ?? 'Không có thông tin'}\n${drug.category ?? 'Chưa phân loại'} - ${drug.type ?? 'Không xác định'}',
                        ),
                        isThreeLine: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(drug.name),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildInfoRow('Hoạt chất', drug.activeIngredient ?? 'Không có thông tin'),
                                    _buildInfoRow('Nhà sản xuất', drug.manufacturer ?? 'Không có thông tin'),
                                    _buildInfoRow('Công dụng', drug.uses ?? 'Không có thông tin'),
                                    _buildInfoRow('Liều dùng', drug.dosage ?? 'Không có thông tin'),
                                    _buildInfoRow('Chống chỉ định', drug.contraindications ?? 'Không có thông tin'),
                                    _buildInfoRow('Tác dụng phụ', drug.sideEffects ?? 'Không có thông tin'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Đóng'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải dữ liệu thuốc...'),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Đã xảy ra lỗi khi tải dữ liệu:\n${error.toString()}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _searchDrugs,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
} 