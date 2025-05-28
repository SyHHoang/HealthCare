import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_data.dart';
import '../providers/health_data_provider.dart';
import 'package:intl/intl.dart';

class HealthDataScreen extends ConsumerStatefulWidget {
  const HealthDataScreen({super.key});

  @override
  ConsumerState<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends ConsumerState<HealthDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataTypeController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _measurementTime = DateTime.now();

  final List<String> _dataTypes = [
    'Huyết áp',
    'Đường huyết',
    'Nhịp tim',
    'Cân nặng',
    'Chiều cao',
    'Nhiệt độ',
    'Khác'
  ];

  @override
  void dispose() {
    _dataTypeController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddHealthDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm dữ liệu sức khỏe mới'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _dataTypeController.text.isEmpty ? null : _dataTypeController.text,
                  items: _dataTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _dataTypeController.text = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Loại dữ liệu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại dữ liệu';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Giá trị'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Vui lòng nhập số hợp lệ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(labelText: 'Đơn vị'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập đơn vị';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Nơi đo'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Thời gian đo: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _measurementTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _measurementTime = picked;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_measurementTime),
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
                final healthData = HealthData(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  dataType: _dataTypeController.text,
                  value: double.parse(_valueController.text),
                  unit: _unitController.text,
                  measurementTime: _measurementTime,
                  measurementLocation: _locationController.text.isEmpty ? null : _locationController.text,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );
                await ref.read(healthDataNotifierProvider.notifier).addHealthData(healthData);
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
    _dataTypeController.clear();
    _valueController.clear();
    _unitController.clear();
    _locationController.clear();
    _notesController.clear();
    setState(() {
      _measurementTime = DateTime.now();
    });
  }

  void _editHealthData(HealthData healthData) {
    _dataTypeController.text = healthData.dataType;
    _valueController.text = healthData.value.toString();
    _unitController.text = healthData.unit;
    _locationController.text = healthData.measurementLocation ?? '';
    _notesController.text = healthData.notes ?? '';
    setState(() {
      _measurementTime = healthData.measurementTime;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa dữ liệu sức khỏe'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _dataTypeController.text,
                  items: _dataTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _dataTypeController.text = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Loại dữ liệu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại dữ liệu';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Giá trị'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Vui lòng nhập số hợp lệ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(labelText: 'Đơn vị'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập đơn vị';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Nơi đo'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Thời gian đo: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _measurementTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _measurementTime = picked;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_measurementTime),
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
                final updatedHealthData = HealthData(
                  id: healthData.id,
                  dataType: _dataTypeController.text,
                  value: double.parse(_valueController.text),
                  unit: _unitController.text,
                  measurementTime: _measurementTime,
                  measurementLocation: _locationController.text.isEmpty ? null : _locationController.text,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );
                await ref.read(healthDataNotifierProvider.notifier).updateHealthData(updatedHealthData);
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
    final healthData = ref.watch(healthDataNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý dữ liệu sức khỏe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddHealthDataDialog,
          ),
        ],
      ),
      body: healthData.when(
        data: (healthDataList) {
          if (healthDataList.isEmpty) {
            return const Center(
              child: Text('Chưa có dữ liệu sức khỏe nào được thêm'),
            );
          }
          return ListView.builder(
            itemCount: healthDataList.length,
            itemBuilder: (context, index) {
              final data = healthDataList[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data.dataType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giá trị: ${data.value} ${data.unit}'),
                      Text('Thời gian đo: ${DateFormat('dd/MM/yyyy').format(data.measurementTime)}'),
                      if (data.measurementLocation != null) Text('Nơi đo: ${data.measurementLocation}'),
                      if (data.notes != null) Text('Ghi chú: ${data.notes}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editHealthData(data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: const Text('Bạn có chắc chắn muốn xóa dữ liệu sức khỏe này?'),
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
                            await ref.read(healthDataNotifierProvider.notifier).deleteHealthData(data.id);
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