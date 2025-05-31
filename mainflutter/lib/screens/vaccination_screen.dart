import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vaccination.dart';
import '../providers/vaccination_provider.dart';
import 'package:intl/intl.dart';

class VaccinationScreen extends ConsumerWidget {
  const VaccinationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinationsAsync = ref.watch(vaccinationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử tiêm chủng'),
      ),
      body: vaccinationsAsync.when(
        data: (vaccinations) {
          if (vaccinations.isEmpty) {
            return const Center(child: Text('Chưa có thông tin tiêm chủng'));
          }
          return ListView.builder(
            itemCount: vaccinations.length,
            itemBuilder: (context, index) {
              final v = vaccinations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.vaccines),
                  title: Text(v.vaccineName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại: ${v.vaccineType}'),
                      if (v.dateAdministered != null)
                        Text('Ngày tiêm: ${DateFormat('dd/MM/yyyy').format(v.dateAdministered!)}'),
                      if (v.nextDoseDate != null)
                        Text('Ngày nhắc lại: ${DateFormat('dd/MM/yyyy').format(v.nextDoseDate!)}'),
                      if (v.status != null)
                        Text('Trạng thái: ${v.status}'),
                      if (v.notes != null && v.notes!.isNotEmpty)
                        Text('Ghi chú: ${v.notes}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVaccinationDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddVaccinationDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final vaccineNameController = TextEditingController();
    final vaccineTypeController = TextEditingController();
    DateTime? dateAdministered;
    DateTime? nextDoseDate;
    final notesController = TextEditingController();
    final statusOptions = ['Đã tiêm', 'Đã hoãn', 'Đã hủy'];
    String status = 'Đã tiêm';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm lịch sử tiêm chủng'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: vaccineNameController,
                    decoration: const InputDecoration(labelText: 'Tên vắc xin'),
                    validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
                  ),
                  TextFormField(
                    controller: vaccineTypeController,
                    decoration: const InputDecoration(labelText: 'Loại vắc xin'),
                    validator: (value) => value == null || value.isEmpty ? 'Bắt buộc' : null,
                  ),
                  Row(
                    children: [
                      const Text('Ngày tiêm: '),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dateAdministered ?? DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              dateAdministered = picked;
                            });
                          }
                        },
                        child: Text(dateAdministered == null
                            ? 'Chọn ngày'
                            : DateFormat('dd/MM/yyyy').format(dateAdministered!)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Ngày nhắc lại: '),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: nextDoseDate ?? DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              nextDoseDate = picked;
                            });
                          }
                        },
                        child: Text(nextDoseDate == null
                            ? 'Chọn ngày'
                            : DateFormat('dd/MM/yyyy').format(nextDoseDate!)),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: statusOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => status = value);
                    },
                    decoration: const InputDecoration(labelText: 'Trạng thái'),
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Ghi chú'),
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
                if (formKey.currentState!.validate()) {
                  final vaccination = Vaccination(
                    id: '', // id sẽ được backend sinh ra
                    vaccineName: vaccineNameController.text,
                    vaccineType: vaccineTypeController.text,
                    dateAdministered: dateAdministered,
                    nextDoseDate: nextDoseDate,
                    notes: notesController.text,
                    status: status,
                  );
                  try {
                    await ref.read(vaccinationNotifierProvider.notifier).addVaccination(vaccination);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thêm lịch sử tiêm chủng thành công')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
} 