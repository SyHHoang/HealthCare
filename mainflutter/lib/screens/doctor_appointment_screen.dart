import 'package:flutter/material.dart';
import '../models/doctor.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorAppointmentScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorAppointmentScreen> createState() => _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _timeFormat = DateFormat('HH:mm');
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '1',
      'patientName': 'Nguyễn Văn A',
      'date': DateTime.now(),
      'time': '09:00',
      'status': 'pending',
      'type': 'online',
    },
    {
      'id': '2',
      'patientName': 'Trần Thị B',
      'date': DateTime.now(),
      'time': '10:30',
      'status': 'confirmed',
      'type': 'offline',
    },
    {
      'id': '3',
      'patientName': 'Lê Văn C',
      'date': DateTime.now(),
      'time': '14:00',
      'status': 'completed',
      'type': 'online',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lịch hẹn'),
      ),
      body: Column(
        children: [
          // Chọn ngày
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateFormat.format(_selectedDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Danh sách lịch hẹn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(appointment['status']),
                      child: Icon(
                        appointment['type'] == 'online'
                            ? Icons.video_call
                            : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(appointment['patientName']),
                    subtitle: Text(
                      '${_timeFormat.format(appointment['date'])} - ${_getStatusText(appointment['status'])}',
                    ),
                    trailing: _buildStatusButton(appointment),
                    onTap: () {
                      // TODO: Xem chi tiết lịch hẹn
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Thêm lịch hẹn mới
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Đã hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Widget _buildStatusButton(Map<String, dynamic> appointment) {
    switch (appointment['status']) {
      case 'pending':
        return TextButton(
          onPressed: () {
            // TODO: Xác nhận lịch hẹn
          },
          child: const Text('Xác nhận'),
        );
      case 'confirmed':
        return TextButton(
          onPressed: () {
            // TODO: Bắt đầu cuộc hẹn
          },
          child: const Text('Bắt đầu'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
} 