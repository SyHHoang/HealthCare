import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription.dart';
import '../providers/prescription_provider.dart';
import 'package:intl/intl.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Medicine> _medicines = [];

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final durationController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thuốc'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên thuốc'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên thuốc';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Liều lượng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập liều lượng';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: frequencyController,
                  decoration: const InputDecoration(labelText: 'Tần suất'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tần suất';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Thời gian dùng'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập thời gian dùng';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final medicine = Medicine(
                  name: nameController.text,
                  dosage: dosageController.text,
                  frequency: frequencyController.text,
                  duration: durationController.text,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
                setState(() {
                  _medicines.add(medicine);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    _diagnosisController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();
    _medicines.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm đơn thuốc'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(labelText: 'Chẩn đoán'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập chẩn đoán';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ngày kê đơn: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Danh sách thuốc:'),
                ..._medicines.map((medicine) => Card(
                  child: ListTile(
                    title: Text(medicine.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Liều lượng: ${medicine.dosage}'),
                        Text('Tần suất: ${medicine.frequency}'),
                        Text('Thời gian dùng: ${medicine.duration}'),
                        if (medicine.notes != null)
                          Text('Ghi chú: ${medicine.notes}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _medicines.remove(medicine);
                        });
                      },
                    ),
                  ),
                )).toList(),
                ElevatedButton.icon(
                  onPressed: _showAddMedicineDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thuốc'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && _medicines.isNotEmpty) {
                final prescription = Prescription(
                  diagnosis: _diagnosisController.text,
                  medicines: _medicines,
                  date: _selectedDate,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );

                try {
                  await ref.read(prescriptionNotifierProvider.notifier).addPrescription(prescription);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm đơn thuốc thành công')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              } else if (_medicines.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng thêm ít nhất một loại thuốc')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Prescription prescription) {
    _diagnosisController.text = prescription.diagnosis;
    _notesController.text = prescription.notes ?? '';
    _selectedDate = prescription.date;
    _medicines = List.from(prescription.medicines);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa đơn thuốc'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(labelText: 'Chẩn đoán'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập chẩn đoán';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ngày kê đơn: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Danh sách thuốc:'),
                ..._medicines.map((medicine) => Card(
                  child: ListTile(
                    title: Text(medicine.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Liều lượng: ${medicine.dosage}'),
                        Text('Tần suất: ${medicine.frequency}'),
                        Text('Thời gian dùng: ${medicine.duration}'),
                        if (medicine.notes != null)
                          Text('Ghi chú: ${medicine.notes}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _medicines.remove(medicine);
                        });
                      },
                    ),
                  ),
                )).toList(),
                ElevatedButton.icon(
                  onPressed: _showAddMedicineDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thuốc'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && _medicines.isNotEmpty) {
                final updatedPrescription = prescription.copyWith(
                  diagnosis: _diagnosisController.text,
                  medicines: _medicines,
                  date: _selectedDate,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );

                try {
                  await ref.read(prescriptionNotifierProvider.notifier).updatePrescription(updatedPrescription);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật đơn thuốc thành công')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              } else if (_medicines.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng thêm ít nhất một loại thuốc')),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đơn thuốc'),
        content: const Text('Bạn có chắc chắn muốn xóa đơn thuốc này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(prescriptionNotifierProvider.notifier).deletePrescription(id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa đơn thuốc thành công')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionsAsync = ref.watch(prescriptionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn thuốc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(prescriptionNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: prescriptionsAsync.when(
        data: (prescriptions) {
          if (prescriptions.isEmpty) {
            return const Center(
              child: Text('Chưa có đơn thuốc nào'),
            );
          }

          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text('Chẩn đoán: ${prescription.diagnosis}'),
                  subtitle: Text('Ngày kê đơn: ${DateFormat('dd/MM/yyyy').format(prescription.date)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Danh sách thuốc:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...prescription.medicines.map((medicine) => Card(
                            child: ListTile(
                              title: Text(medicine.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Liều lượng: ${medicine.dosage}'),
                                  Text('Tần suất: ${medicine.frequency}'),
                                  Text('Thời gian dùng: ${medicine.duration}'),
                                  if (medicine.notes != null)
                                    Text('Ghi chú: ${medicine.notes}'),
                                ],
                              ),
                            ),
                          )).toList(),
                          if (prescription.notes != null) ...[
                            const SizedBox(height: 8),
                            Text('Ghi chú: ${prescription.notes}'),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(prescription),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteDialog(prescription.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Lỗi: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 