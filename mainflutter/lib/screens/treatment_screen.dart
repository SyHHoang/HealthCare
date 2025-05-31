import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/treatment.dart';
import '../providers/treatment_provider.dart';
import 'package:intl/intl.dart';

class TreatmentScreen extends ConsumerStatefulWidget {
  const TreatmentScreen({super.key});

  @override
  ConsumerState<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends ConsumerState<TreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _selectedStatus = 'Đang điều trị';
  List<Medication> _medications = [];
  List<Procedure> _procedures = [];
  FollowUp? _followUp;

  final List<String> _statusOptions = ['Đang điều trị', 'Đã hoàn thành', 'Đã hủy'];

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentPlanController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final durationController = TextEditingController();

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
                final medication = Medication(
                  name: nameController.text,
                  dosage: dosageController.text,
                  frequency: frequencyController.text,
                  duration: durationController.text,
                );
                setState(() {
                  _medications.add(medication);
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

  void _showAddProcedureDialog() {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thủ thuật'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên thủ thuật'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên thủ thuật';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ngày thực hiện: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                      ),
                    ),
                  ],
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
                final procedure = Procedure(
                  name: nameController.text,
                  date: selectedDate,
                  notes: notesController.text,
                );
                setState(() {
                  _procedures.add(procedure);
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

  void _showAddFollowUpDialog() {
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm lịch tái khám'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Ngày tái khám: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                      ),
                    ),
                  ],
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
              final followUp = FollowUp(
                date: selectedDate,
                notes: notesController.text,
              );
              setState(() {
                _followUp = followUp;
              });
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treatments = ref.watch(treatmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý điều trị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Thêm điều trị mới'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _diagnosisController,
                            decoration: const InputDecoration(labelText: 'Chẩn đoán'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập chẩn đoán';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _treatmentPlanController,
                            decoration: const InputDecoration(labelText: 'Kế hoạch điều trị'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập kế hoạch điều trị';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Ngày bắt đầu: '),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _startDate = picked;
                                    });
                                  }
                                },
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_startDate),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Ngày kết thúc: '),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _endDate = picked;
                                    });
                                  }
                                },
                                child: Text(
                                  _endDate == null
                                      ? 'Chọn ngày'
                                      : DateFormat('dd/MM/yyyy').format(_endDate!),
                                ),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            items: _statusOptions
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              }
                            },
                            decoration: const InputDecoration(labelText: 'Trạng thái'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Thuốc:'),
                              TextButton(
                                onPressed: _showAddMedicationDialog,
                                child: const Text('Thêm thuốc'),
                              ),
                            ],
                          ),
                          if (_medications.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _medications.length,
                              itemBuilder: (context, index) {
                                final medication = _medications[index];
                                return ListTile(
                                  title: Text(medication.name),
                                  subtitle: Text(
                                      '${medication.dosage} - ${medication.frequency}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _medications.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Thủ thuật:'),
                              TextButton(
                                onPressed: _showAddProcedureDialog,
                                child: const Text('Thêm thủ thuật'),
                              ),
                            ],
                          ),
                          if (_procedures.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _procedures.length,
                              itemBuilder: (context, index) {
                                final procedure = _procedures[index];
                                return ListTile(
                                  title: Text(procedure.name),
                                  subtitle: Text(
                                      DateFormat('dd/MM/yyyy').format(procedure.date)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _procedures.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Lịch tái khám:'),
                              TextButton(
                                onPressed: _followUp == null
                                    ? _showAddFollowUpDialog
                                    : null,
                                child: const Text('Thêm lịch tái khám'),
                              ),
                            ],
                          ),
                          if (_followUp != null)
                            ListTile(
                              title: Text(
                                  DateFormat('dd/MM/yyyy').format(_followUp!.date)),
                              subtitle:
                                  _followUp!.notes != null ? Text(_followUp!.notes!) : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _followUp = null;
                                  });
                                },
                              ),
                            ),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(labelText: 'Ghi chú'),
                            maxLines: 3,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final treatment = Treatment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            diagnosis: _diagnosisController.text,
                            treatmentPlan: _treatmentPlanController.text,
                            startDate: _startDate,
                            endDate: _endDate,
                            status: _selectedStatus,
                            medications: _medications,
                            procedures: _procedures,
                            followUp: _followUp,
                            notes:  _notesController.text,
                          );
                          ref
                              .read(treatmentNotifierProvider.notifier)
                              .addTreatment(treatment);
                          Navigator.pop(context);
                          _resetForm();
                        }
                      },
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: treatments.when(
        data: (treatmentList) {
          if (treatmentList.isEmpty) {
            return const Center(
              child: Text('Chưa có điều trị nào được thêm'),
            );
          }
          return ListView.builder(
            itemCount: treatmentList.length,
            itemBuilder: (context, index) {
              final treatment = treatmentList[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(treatment.diagnosis),
                  subtitle: Text(
                    'Trạng thái: ${treatment.status}\nNgày bắt đầu: ${DateFormat('dd/MM/yyyy').format(treatment.startDate)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kế hoạch điều trị: ${treatment.treatmentPlan}'),
                          if (treatment.endDate != null)
                            Text(
                              'Ngày kết thúc: ${DateFormat('dd/MM/yyyy').format(treatment.endDate!)}',
                            ),
                          if (treatment.medications.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Text('Thuốc:'),
                            ...treatment.medications.map(
                              (med) => ListTile(
                                title: Text(med.name),
                                subtitle: Text('${med.dosage} - ${med.frequency}\n${med.duration}'),
                              ),
                            ),
                          ],
                          if (treatment.procedures.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Text('Thủ thuật:'),
                            ...treatment.procedures.map(
                              (proc) => ListTile(
                                title: Text(proc.name),
                                subtitle: Text(DateFormat('dd/MM/yyyy').format(proc.date)),
                              ),
                            ),
                          ],
                          if (treatment.followUp != null) ...[
                            const SizedBox(height: 10),
                            const Text('Lịch tái khám:'),
                            ListTile(
                              title: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(treatment.followUp!.date),
                              ),
                              subtitle: treatment.followUp!.notes != null
                                  ? Text(treatment.followUp!.notes!)
                                  : null,
                            ),
                          ],
                          if (treatment.notes != null) ...[
                            const SizedBox(height: 10),
                            Text('Ghi chú: ${treatment.notes}'),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _editTreatment(treatment);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: const Text(
                                          'Bạn có chắc chắn muốn xóa điều trị này?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(treatmentNotifierProvider.notifier)
                                                .deleteTreatment(treatment.id);
                                            Navigator.pop(context);
                                                                                    },
                                          child: const Text('Xóa'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
          child: Text('Đã xảy ra lỗi: $error'),
        ),
      ),
    );
  }

  void _resetForm() {
    _diagnosisController.clear();
    _treatmentPlanController.clear();
    _notesController.clear();
    setState(() {
      _startDate = DateTime.now();
      _endDate = null;
      _selectedStatus = 'Đang điều trị';
      _medications.clear();
      _procedures.clear();
      _followUp = null;
    });
  }

  void _editTreatment(Treatment treatment) {
    _diagnosisController.text = treatment.diagnosis;
    _treatmentPlanController.text = treatment.treatmentPlan;
    _notesController.text = treatment.notes ?? '';
    setState(() {
      _startDate = treatment.startDate;
      _endDate = treatment.endDate;
      _selectedStatus = treatment.status;
      _medications = List.from(treatment.medications);
      _procedures = List.from(treatment.procedures);
      _followUp = treatment.followUp;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa điều trị'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(labelText: 'Chẩn đoán'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập chẩn đoán';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _treatmentPlanController,
                  decoration: const InputDecoration(labelText: 'Kế hoạch điều trị'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập kế hoạch điều trị';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ngày bắt đầu: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_startDate),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Ngày kết thúc: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Text(
                        _endDate == null
                            ? 'Chọn ngày'
                            : DateFormat('dd/MM/yyyy').format(_endDate!),
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: _statusOptions
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thuốc:'),
                    TextButton(
                      onPressed: _showAddMedicationDialog,
                      child: const Text('Thêm thuốc'),
                    ),
                  ],
                ),
                if (_medications.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final medication = _medications[index];
                      return ListTile(
                        title: Text(medication.name),
                        subtitle:
                            Text('${medication.dosage} - ${medication.frequency}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _medications.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thủ thuật:'),
                    TextButton(
                      onPressed: _showAddProcedureDialog,
                      child: const Text('Thêm thủ thuật'),
                    ),
                  ],
                ),
                if (_procedures.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _procedures.length,
                    itemBuilder: (context, index) {
                      final procedure = _procedures[index];
                      return ListTile(
                        title: Text(procedure.name),
                        subtitle:
                            Text(DateFormat('dd/MM/yyyy').format(procedure.date)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _procedures.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lịch tái khám:'),
                    TextButton(
                      onPressed:
                          _followUp == null ? _showAddFollowUpDialog : null,
                      child: const Text('Thêm lịch tái khám'),
                    ),
                  ],
                ),
                if (_followUp != null)
                  ListTile(
                    title:
                        Text(DateFormat('dd/MM/yyyy').format(_followUp!.date)),
                    subtitle:
                        _followUp!.notes != null ? Text(_followUp!.notes!) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _followUp = null;
                        });
                      },
                    ),
                  ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                  maxLines: 3,
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final updatedTreatment = Treatment(
                  id: treatment.id,
                  diagnosis: _diagnosisController.text,
                  treatmentPlan: _treatmentPlanController.text,
                  startDate: _startDate,
                  endDate: _endDate,
                  status: _selectedStatus,
                  medications: _medications,
                  procedures: _procedures,
                  followUp: _followUp,
                  notes: _notesController.text,
                );
                ref
                    .read(treatmentNotifierProvider.notifier)
                    .updateTreatment(updatedTreatment);
                Navigator.pop(context);
                _resetForm();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
} 