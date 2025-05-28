import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/allergy.dart';
import '../providers/allergies_provider.dart';

class AllergyScreen extends ConsumerStatefulWidget {
  const AllergyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllergyScreen> createState() => _AllergyScreenState();
}

class _AllergyScreenState extends ConsumerState<AllergyScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy');
  List<String> symptoms = [];
  String symptomInput = '';

  @override
  Widget build(BuildContext context) {
    final allergiesAsync = ref.watch(allergiesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dị ứng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(allergiesNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: allergiesAsync.when(
        data: (allergies) => allergies.isEmpty
            ? const Center(child: Text('Chưa có thông tin dị ứng nào'))
            : ListView.builder(
                itemCount: allergies.length,
                itemBuilder: (context, index) {
                  final allergy = allergies[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(allergy.allergen),
                      subtitle: Text('Loại: ${allergy.type}\nMức độ: ${allergy.severity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditAllergyDialog(context, allergy),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(allergy),
                          ),
                        ],
                      ),
                      onTap: () => _showAllergyDetails(context, allergy),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAllergyDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAllergyDetails(BuildContext context, Allergy allergy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(allergy.allergen),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Loại: ${allergy.type}'),
              Text('Mức độ: ${allergy.severity}'),
              const SizedBox(height: 8),
              const Text('Triệu chứng:'),
              Wrap(
                spacing: 8,
                children: allergy.symptoms
                    .map((symptom) => Chip(label: Text(symptom)))
                    .toList(),
              ),
              if (allergy.firstOccurrence != null)
                Text('Lần đầu xuất hiện: ${dateFormat.format(allergy.firstOccurrence!)}'),
              if (allergy.lastOccurrence != null)
                Text('Lần cuối xuất hiện: ${dateFormat.format(allergy.lastOccurrence!)}'),
              if (allergy.treatment != null && allergy.treatment!.isNotEmpty)
                Text('Cách điều trị: ${allergy.treatment}'),
              if (allergy.notes != null && allergy.notes!.isNotEmpty)
                Text('Ghi chú: ${allergy.notes}'),
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
  }

  Future<void> _showAddAllergyDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String allergen = '';
    String type = 'Thực phẩm';
    String severity = 'Nhẹ';
    DateTime? firstOccurrence;
    DateTime? lastOccurrence;
    String treatment = '';
    String notes = '';

    setState(() {
      symptoms = [];
    });

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm dị ứng mới'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tác nhân gây dị ứng'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Vui lòng nhập tác nhân gây dị ứng' : null,
                    onSaved: (value) => allergen = value ?? '',
                  ),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Loại'),
                    items: ['Thực phẩm', 'Thuốc', 'Môi trường', 'Khác']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => type = value ?? 'Thực phẩm',
                  ),
                  DropdownButtonFormField<String>(
                    value: severity,
                    decoration: const InputDecoration(labelText: 'Mức độ'),
                    items: ['Nhẹ', 'Trung bình', 'Nặng', 'Nguy hiểm đến tính mạng']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => severity = value ?? 'Nhẹ',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Triệu chứng',
                      helperText: 'Nhập và nhấn Enter để thêm triệu chứng',
                    ),
                    onChanged: (value) => symptomInput = value,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          symptoms.add(value);
                          symptomInput = '';
                        });
                      }
                    },
                  ),
                  if (symptoms.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: symptoms.map((symptom) => Chip(
                        label: Text(symptom),
                        onDeleted: () {
                          setState(() {
                            symptoms.remove(symptom);
                          });
                        },
                      )).toList(),
                    ),
                  ListTile(
                    title: const Text('Lần đầu xuất hiện'),
                    subtitle: Text(
                      firstOccurrence != null
                          ? dateFormat.format(firstOccurrence!)
                          : 'Chưa chọn',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: firstOccurrence ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          firstOccurrence = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Lần cuối xuất hiện'),
                    subtitle: Text(
                      lastOccurrence != null
                          ? dateFormat.format(lastOccurrence!)
                          : 'Chưa chọn',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: lastOccurrence ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          lastOccurrence = date;
                        });
                      }
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Cách điều trị'),
                    onSaved: (value) => treatment = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Ghi chú'),
                    maxLines: 3,
                    onSaved: (value) => notes = value ?? '',
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
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  if (symptoms.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng thêm ít nhất một triệu chứng')),
                    );
                    return;
                  }
                  final newAllergy = Allergy(
                    id: DateTime.now().toIso8601String(), // Tạm thời dùng timestamp làm id
                    allergen: allergen,
                    type: type,
                    severity: severity,
                    symptoms: symptoms,
                    firstOccurrence: firstOccurrence,
                    lastOccurrence: lastOccurrence,
                    treatment: treatment.isEmpty ? null : treatment,
                    notes: notes.isEmpty ? null : notes,
                  );
                  ref.read(allergiesNotifierProvider.notifier).addAllergy(newAllergy);
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditAllergyDialog(BuildContext context, Allergy allergy) async {
    final formKey = GlobalKey<FormState>();
    String allergen = allergy.allergen;
    String type = allergy.type;
    String severity = allergy.severity;
    DateTime? firstOccurrence = allergy.firstOccurrence;
    DateTime? lastOccurrence = allergy.lastOccurrence;
    String treatment = allergy.treatment ?? '';
    String notes = allergy.notes ?? '';

    setState(() {
      symptoms = List.from(allergy.symptoms);
    });

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chỉnh sửa dị ứng'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: allergen,
                    decoration: const InputDecoration(labelText: 'Tác nhân gây dị ứng'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Vui lòng nhập tác nhân gây dị ứng' : null,
                    onSaved: (value) => allergen = value ?? '',
                  ),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Loại'),
                    items: ['Thực phẩm', 'Thuốc', 'Môi trường', 'Khác']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => type = value ?? 'Thực phẩm',
                  ),
                  DropdownButtonFormField<String>(
                    value: severity,
                    decoration: const InputDecoration(labelText: 'Mức độ'),
                    items: ['Nhẹ', 'Trung bình', 'Nặng', 'Nguy hiểm đến tính mạng']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => severity = value ?? 'Nhẹ',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Triệu chứng',
                      helperText: 'Nhập và nhấn Enter để thêm triệu chứng',
                    ),
                    onChanged: (value) => symptomInput = value,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          symptoms.add(value);
                          symptomInput = '';
                        });
                      }
                    },
                  ),
                  if (symptoms.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: symptoms.map((symptom) => Chip(
                        label: Text(symptom),
                        onDeleted: () {
                          setState(() {
                            symptoms.remove(symptom);
                          });
                        },
                      )).toList(),
                    ),
                  ListTile(
                    title: const Text('Lần đầu xuất hiện'),
                    subtitle: Text(
                      firstOccurrence != null
                          ? dateFormat.format(firstOccurrence!)
                          : 'Chưa chọn',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: firstOccurrence ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          firstOccurrence = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Lần cuối xuất hiện'),
                    subtitle: Text(
                      lastOccurrence != null
                          ? dateFormat.format(lastOccurrence!)
                          : 'Chưa chọn',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: lastOccurrence ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          lastOccurrence = date;
                        });
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: treatment,
                    decoration: const InputDecoration(labelText: 'Cách điều trị'),
                    onSaved: (value) => treatment = value ?? '',
                  ),
                  TextFormField(
                    initialValue: notes,
                    decoration: const InputDecoration(labelText: 'Ghi chú'),
                    maxLines: 3,
                    onSaved: (value) => notes = value ?? '',
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
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  if (symptoms.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng thêm ít nhất một triệu chứng')),
                    );
                    return;
                  }
                  final updatedAllergy = Allergy(
                    id: allergy.id,
                    allergen: allergen,
                    type: type,
                    severity: severity,
                    symptoms: symptoms,
                    firstOccurrence: firstOccurrence,
                    lastOccurrence: lastOccurrence,
                    treatment: treatment.isEmpty ? null : treatment,
                    notes: notes.isEmpty ? null : notes,
                    isActive: allergy.isActive,
                  );
                  ref.read(allergiesNotifierProvider.notifier).updateAllergy(updatedAllergy);
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Allergy allergy) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa thông tin dị ứng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              ref.read(allergiesNotifierProvider.notifier).deleteAllergy(allergy.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
} 