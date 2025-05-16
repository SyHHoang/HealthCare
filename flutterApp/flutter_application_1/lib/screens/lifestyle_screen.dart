import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lifestyle.dart';
import '../providers/lifestyle_provider.dart';
import 'package:intl/intl.dart';

class LifestyleScreen extends ConsumerStatefulWidget {
  const LifestyleScreen({super.key});

  @override
  ConsumerState<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends ConsumerState<LifestyleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _startDate;

  final List<String> _activityTypes = ['Tập thể dục', 'Ăn uống', 'Giấc ngủ', 'Hút thuốc', 'Uống rượu', 'Khác'];
  final List<String> _frequencies = ['Hàng ngày', 'Hàng tuần', 'Hàng tháng', 'Thỉnh thoảng'];

  @override
  void dispose() {
    _activityTypeController.dispose();
    _descriptionController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddLifestyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm lối sống mới'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _activityTypeController.text.isEmpty ? null : _activityTypeController.text,
                  items: _activityTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _activityTypeController.text = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Loại hoạt động'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại hoạt động';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _frequencyController.text.isEmpty ? null : _frequencyController.text,
                  items: _frequencies.map((freq) => DropdownMenuItem(
                    value: freq,
                    child: Text(freq),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _frequencyController.text = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Tần suất'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn tần suất';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Thời gian'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ngày bắt đầu: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Text(
                        _startDate == null
                            ? 'Chọn ngày'
                            : DateFormat('dd/MM/yyyy').format(_startDate!),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final lifestyle = Lifestyle(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  activityType: _activityTypeController.text,
                  description: _descriptionController.text,
                  frequency: _frequencyController.text,
                  duration: _durationController.text.isEmpty ? null : _durationController.text,
                  startDate: _startDate,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );
                await ref.read(lifestyleNotifierProvider.notifier).addLifestyle(lifestyle);
                if (mounted) {
                  Navigator.pop(context);
                  _resetForm();
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _activityTypeController.clear();
    _descriptionController.clear();
    _frequencyController.clear();
    _durationController.clear();
    _notesController.clear();
    setState(() {
      _startDate = null;
    });
  }

  void _editLifestyle(Lifestyle lifestyle) {
    _activityTypeController.text = lifestyle.activityType;
    _descriptionController.text = lifestyle.description;
    _frequencyController.text = lifestyle.frequency;
    _durationController.text = lifestyle.duration ?? '';
    _notesController.text = lifestyle.notes ?? '';
    setState(() {
      _startDate = lifestyle.startDate;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa lối sống'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _activityTypeController.text,
                  items: _activityTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _activityTypeController.text = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Loại hoạt động'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại hoạt động';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _frequencyController.text,
                  items: _frequencies.map((freq) => DropdownMenuItem(
                    value: freq,
                    child: Text(freq),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _frequencyController.text = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Tần suất'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn tần suất';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Thời gian'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ngày bắt đầu: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Text(
                        _startDate == null
                            ? 'Chọn ngày'
                            : DateFormat('dd/MM/yyyy').format(_startDate!),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updatedLifestyle = Lifestyle(
                  id: lifestyle.id,
                  activityType: _activityTypeController.text,
                  description: _descriptionController.text,
                  frequency: _frequencyController.text,
                  duration: _durationController.text.isEmpty ? null : _durationController.text,
                  startDate: _startDate,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );
                await ref.read(lifestyleNotifierProvider.notifier).updateLifestyle(updatedLifestyle);
                if (mounted) {
                  Navigator.pop(context);
                  _resetForm();
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lifestyles = ref.watch(lifestyleNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lối sống'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddLifestyleDialog,
          ),
        ],
      ),
      body: lifestyles.when(
        data: (lifestyleList) {
          if (lifestyleList.isEmpty) {
            return const Center(
              child: Text('Chưa có thông tin lối sống nào được thêm'),
            );
          }
          return ListView.builder(
            itemCount: lifestyleList.length,
            itemBuilder: (context, index) {
              final lifestyle = lifestyleList[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(lifestyle.activityType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mô tả: ${lifestyle.description}'),
                      Text('Tần suất: ${lifestyle.frequency}'),
                      if (lifestyle.duration != null) Text('Thời gian: ${lifestyle.duration}'),
                      if (lifestyle.startDate != null)
                        Text('Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(lifestyle.startDate!)}'),
                      if (lifestyle.notes != null) Text('Ghi chú: ${lifestyle.notes}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editLifestyle(lifestyle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: const Text('Bạn có chắc chắn muốn xóa thông tin lối sống này?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && mounted) {
                            await ref.read(lifestyleNotifierProvider.notifier).deleteLifestyle(lifestyle.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Đã xảy ra lỗi: $error'),
        ),
      ),
    );
  }
} 