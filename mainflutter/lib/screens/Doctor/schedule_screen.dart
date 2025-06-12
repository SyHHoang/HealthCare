import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/doctor_service.dart';

class ScheduleScreen extends StatefulWidget {
  final Doctor doctor;

  const ScheduleScreen({super.key, required this.doctor});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _doctorService = DoctorService();
  bool _isLoading = false;
  Map<String, List<Map<String, String>>> _workingTimes = {};
  final _weekDays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật'
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('=== LOADING SCHEDULE ===');
      debugPrint('Doctor ID: ${widget.doctor.id}');
      final schedule = await _doctorService.getSchedule(widget.doctor.id);
      debugPrint('Schedule loaded: $schedule');
      setState(() {
        _workingTimes = schedule;
      });
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải lịch làm việc: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, String>> getWorkingTime(String day) {
    return _workingTimes[day] ?? [];
  }

  Future<void> _addWorkingTime() async {
    String? selectedDay;
    TimeOfDay? selectedTime;

    // Hiển thị dialog chọn thứ
    selectedDay = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn thứ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _weekDays.map((day) => ListTile(
            title: Text(day),
            onTap: () => Navigator.pop(context, day),
          )).toList(),
        ),
      ),
    );

    if (selectedDay == null) return;

    // Hiển thị dialog chọn thời gian
    if (!mounted) return;
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

      debugPrint('=== ADDING WORKING TIME ===');
      debugPrint('Doctor ID: ${widget.doctor.id}');
      debugPrint('Selected Day: $selectedDay');
      debugPrint('Time String: $timeString');

      // Kiểm tra xung đột thời gian
      final existingSlots = getWorkingTime(selectedDay);
      debugPrint('Existing slots: $existingSlots');

      final hasConflict = existingSlots.any((slot) {
        final [existingHour, existingMinute] = slot['startTime']!.split(':').map(int.parse).toList();
        final [newHour, newMinute] = timeString.split(':').map(int.parse).toList();

        final existingTotalMinutes = existingHour * 60 + existingMinute;
        final newTotalMinutes = newHour * 60 + newMinute;

        return (newTotalMinutes - existingTotalMinutes).abs() < 35;
      });

      if (hasConflict) {
        debugPrint('Conflict detected!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thời gian này phải cách các thời gian khác ít nhất 35 phút')),
          );
        }
        return;
      }

      debugPrint('No conflict, calling API...');
      await _doctorService.addWorkingTime(
        widget.doctor.id,
        selectedDay,
        timeString,
      );
      debugPrint('API call successful, reloading schedule...');
      await _loadSchedule();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm thời gian làm việc thành công')),
        );
      }
    } catch (e) {
      debugPrint('Error adding working time: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm lịch làm việc: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTimeSlot(String day, int index) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _doctorService.deleteWorkingTime(
        widget.doctor.id,
        day,
        index.toString(),
      );
      await _loadSchedule();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa thời gian làm việc thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa lịch làm việc: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch làm việc'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Lịch làm việc',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: _addWorkingTime,
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Thêm thời gian',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _weekDays.length,
                    itemBuilder: (context, index) {
                      final day = _weekDays[index];
                      final timeSlots = getWorkingTime(day);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (timeSlots.isEmpty)
                                const Text(
                                  'Chưa có thời gian làm việc',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: timeSlots.asMap().entries.map((entry) {
                                    final slotIndex = entry.key;
                                    final slot = entry.value;
                                    return Chip(
                                      label: Text(slot['startTime']!),
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () => _deleteTimeSlot(day, slotIndex),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
} 