import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor.dart';
import '../services/consultation_service.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../services/vnpay_service.dart';

class DoctorInfoScreen extends ConsumerWidget {
  final Doctor doctor;

  const DoctorInfoScreen({super.key, required this.doctor});

  // Định dạng ngày tháng từ ISO string
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Chưa cập nhật';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Định dạng không hợp lệ';
    }
  }

  // Kiểm tra xem thời hạn tư vấn đã hết hay chưa
  bool _isConsultationExpired(String? endDateString) {
    if (endDateString == null) return true;
    try {
      final endDate = DateTime.parse(endDateString);
      return DateTime.now().isAfter(endDate);
    } catch (e) {
      return true;
    }
  }

  // Phương thức mới để xóa cache sau khi có thay đổi 
  void _refreshConsultationData(WidgetRef ref) {
    // Làm mới thông tin tư vấn
    ref.read(refreshConsultationControllerProvider.notifier).refreshConsultationList();
    debugPrint('Đã làm mới dữ liệu tư vấn sau khi thực hiện thay đổi');
  }

  // Xử lý chức năng đặt lịch
  Future<void> _showBookingDialog(BuildContext context, WidgetRef ref, int? callRemaining) async {
    final bool hasCallRemaining = callRemaining != null && callRemaining > 0;
    
    // Lấy ngày bắt đầu và kết thúc từ thông tin tư vấn
    DateTime? startDate;
    DateTime? endDate;
    DateTime selectedDate = DateTime.now();
    List<Map<String, String>> availableTimeSlots = [];
    
    // Lưu trữ ScaffoldMessenger để sử dụng sau
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      debugPrint('=== BẮT ĐẦU XỬ LÝ ĐẶT LỊCH ===');
      debugPrint('Thông tin tư vấn: startDate=${doctor.consultationStartDate}, endDate=${doctor.consultationEndDate}, callRemaining=$callRemaining');
      
      // Parse ngày bắt đầu
      if (doctor.consultationStartDate != null) {
        startDate = DateTime.parse(doctor.consultationStartDate!);
        debugPrint('Parse startDate thành công: $startDate');
      } else {
        startDate = DateTime.now();
        debugPrint('Không có startDate, sử dụng ngày hiện tại: $startDate');
      }
      
      // Parse ngày kết thúc
      if (doctor.consultationEndDate != null) {
        endDate = DateTime.parse(doctor.consultationEndDate!);
        debugPrint('Parse endDate thành công: $endDate');
      } else {
        // Nếu không có ngày kết thúc, đặt mặc định là 30 ngày kể từ ngày bắt đầu
        endDate = startDate.add(const Duration(days: 30));
        debugPrint('Không có endDate, tự động đặt là 30 ngày sau startDate: $endDate');
      }
      
      // Nếu ngày bắt đầu trong quá khứ, đặt là ngày hiện tại
      if (startDate.isBefore(DateTime.now())) {
        startDate = DateTime.now();
        debugPrint('startDate trong quá khứ, đặt lại là ngày hiện tại: $startDate');
      }
    } catch (e) {
      debugPrint('Lỗi khi parse ngày: $e');
      startDate = DateTime.now();
      endDate = DateTime.now().add(const Duration(days: 30));
      debugPrint('Đặt giá trị mặc định: startDate=$startDate, endDate=$endDate');
    }
    
    // Chuyển đổi từ thứ trong tuần sang tiếng Việt
    String getDayOfWeekVietnamese(DateTime date) {
      final dayOfWeek = date.weekday;
      switch (dayOfWeek) {
        case DateTime.monday:
          return 'Thứ 2';
        case DateTime.tuesday:
          return 'Thứ 3';
        case DateTime.wednesday:
          return 'Thứ 4';
        case DateTime.thursday:
          return 'Thứ 5';
        case DateTime.friday:
          return 'Thứ 6';
        case DateTime.saturday:
          return 'Thứ 7';
        case DateTime.sunday:
          return 'Chủ Nhật';
        default:
          return 'Không xác định';
      }
    }

    // Controller để hiển thị ngày đã chọn
    final TextEditingController dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(selectedDate),
    );
    
    // Biến để lưu slot đã chọn
    String? selectedTimeSlotId;
    bool isLoadingSlots = false;
    
    // Hàm lấy lịch làm việc dựa trên thứ trong tuần
    Future<List<Map<String, String>>> fetchAvailableTimeSlots(DateTime date) async {
      final dayOfWeekVN = getDayOfWeekVietnamese(date);
      debugPrint('Đang tìm lịch làm việc cho: $dayOfWeekVN');
      
      try {
        // Xử lý schedule là dynamic, lấy từ doctorData
        final consultationService = ref.read(consultationServiceProvider);
        final schedule = consultationService.getDoctorSchedule(doctor.id);
        
        if (schedule == null) {
          debugPrint('Không tìm thấy lịch làm việc cho bác sĩ ${doctor.fullName}');
          return [];
        }
        
        debugPrint('Schedule của bác sĩ: ${schedule.toString()}');
        
        if (schedule.containsKey(dayOfWeekVN)) {
          final slotsForDay = schedule[dayOfWeekVN];
          debugPrint('Tìm thấy slot cho $dayOfWeekVN: ${slotsForDay.toString()}');
          
          // Tạo danh sách tạm thời các slot có sẵn
          List<Map<String, String>> tempSlots = [];
          
          if (slotsForDay is List) {
            for (var slot in slotsForDay) {
              debugPrint('Xử lý slot: $slot');
              if (slot is Map && slot.containsKey('startTime')) {
                final startTime = slot['startTime'] as String;
                final id = slot['_id'] as String;
                tempSlots.add({
                  'startTime': startTime,
                  'id': id,
                });
                debugPrint('Đã thêm slot: $startTime');
              }
            }
            
            // Kiểm tra lịch đã đặt cho ngày này
            if (tempSlots.isNotEmpty) {
              // Tạo đối tượng DateTime cho ngày được chọn
              final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              
              try {
                // Gọi API kiểm tra lịch đã đặt
                final consultationService = ref.read(consultationServiceProvider);
                final bookedTimes = await consultationService.checkDuplicateConsultation(
                  doctor.id ?? '',
                  dateString
                );
                
                debugPrint('Các slot đã được đặt: $bookedTimes');
                
                // Lọc ra các slot chưa được đặt
                tempSlots = tempSlots.where((slot) {
                  // Kiểm tra xem slot này đã có trong danh sách đã đặt chưa
                  return !bookedTimes.contains(slot['startTime']);
                }).toList();
                
                debugPrint('Số slot có sẵn sau khi lọc: ${tempSlots.length}');
              } catch (e) {
                debugPrint('Lỗi khi kiểm tra lịch đã đặt: $e');
                // Nếu có lỗi khi kiểm tra, vẫn hiển thị tất cả các slot
              }
            }
            
            if (tempSlots.isNotEmpty) {
              tempSlots.sort((a, b) => a['startTime']!.compareTo(b['startTime']!));
              debugPrint('Đã sắp xếp ${tempSlots.length} slot');
            } else {
              debugPrint('Không tìm thấy slot nào sau khi xử lý');
            }
            
            return tempSlots;
          } else {
            debugPrint('Dữ liệu slotsForDay không phải là List: ${slotsForDay.runtimeType}');
          }
        } else {
          debugPrint('Không tìm thấy lịch cho $dayOfWeekVN trong schedule');
          if (schedule.isNotEmpty) {
            debugPrint('Các khóa có sẵn trong schedule: ${schedule.keys.toList()}');
          } else {
            debugPrint('Schedule rỗng, không có lịch làm việc nào');
          }
        }
      } catch (e) {
        debugPrint('Lỗi khi lấy lịch làm việc: $e');
      }
      
      return [];
    }
    
    // Khởi tạo lịch làm việc cho ngày hiện tại
    fetchAvailableTimeSlots(selectedDate).then((slots) {
      availableTimeSlots = slots;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đặt lịch với bác sĩ ${doctor.fullName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Thông tin số lần tư vấn còn lại
                  const Text(
                    'Số lần tư vấn còn lại:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${callRemaining ?? 0} lần'),
                      const SizedBox(width: 16),
                      if (!hasCallRemaining)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Bạn cần gia hạn số lần tư vấn',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Chọn ngày
                  const Text(
                    'Chọn ngày tư vấn:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Chọn ngày',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: hasCallRemaining ? () async {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng chọn ngày trong thời hạn tư vấn để xem lịch làm việc'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: startDate ?? DateTime.now(),
                              lastDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue,
                                      onSurface: Colors.black,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            
                            if (pickedDate != null && pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                                dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
                                selectedTimeSlotId = null;
                                isLoadingSlots = true;
                              });
                              
                              try {
                                final slots = await fetchAvailableTimeSlots(selectedDate);
                                setState(() {
                                  availableTimeSlots = slots;
                                  isLoadingSlots = false;
                                });
                              } catch (e) {
                                setState(() {
                                  isLoadingSlots = false;
                                });
                                debugPrint('Lỗi khi tải khung giờ: $e');
                              }
                            }
                          } : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Ngày đã chọn: ${DateFormat('dd/MM/yyyy').format(selectedDate)} (${getDayOfWeekVietnamese(selectedDate)})',
                        style: const TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Hiển thị gợi ý về lịch của bác sĩ
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Vui lòng chọn ngày để xem lịch làm việc của bác sĩ ${doctor.fullName}',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                  
                  // Giờ làm việc
                  const Text(
                    'Chọn thời gian:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  if (availableTimeSlots.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            isLoadingSlots 
                                ? 'Đang tải lịch làm việc...'
                                : 'Không có lịch làm việc cho ${getDayOfWeekVietnamese(selectedDate)}',
                            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          if (!isLoadingSlots) const Text(
                            'Vui lòng chọn ngày khác hoặc liên hệ với bác sĩ để biết thêm thông tin',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Có ${availableTimeSlots.length} khung giờ có sẵn cho ${getDayOfWeekVietnamese(selectedDate)}',
                        style: const TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: availableTimeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = availableTimeSlots[index];
                          final isSelected = selectedTimeSlotId == slot['id'];
                          
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedTimeSlotId = isSelected ? null : slot['id'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  slot['startTime']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Nút xác nhận đặt lịch
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (hasCallRemaining && selectedTimeSlotId != null) 
                        ? () {
                            try {
                              Navigator.pop(context);
                              
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Đang đặt lịch...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              
                              String selectedTime = '';
                              for (var slot in availableTimeSlots) {
                                if (slot['id'] == selectedTimeSlotId) {
                                  selectedTime = slot['startTime']!;
                                  break;
                                }
                              }
                              
                              final List<String> timeParts = selectedTime.split(':');
                              final hour = int.parse(timeParts[0]);
                              final minute = int.parse(timeParts[1]);
                              
                              final consultationDateTime = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                hour,
                                minute,
                              );
                              
                              final consultationService = ref.read(consultationServiceProvider);
                              
                              consultationService.bookConsultation(
                                doctor.id ?? '',
                                consultationDateTime
                              ).then((_) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Đặt lịch tư vấn thành công'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                
                                Navigator.pop(context);
                                _refreshConsultationData(ref);
                              }).catchError((error) {
                                debugPrint('Lỗi khi đặt lịch tư vấn: $error');
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi: ${error.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              });
                            } catch (e) {
                              debugPrint('Lỗi khi đặt lịch: $e');
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } 
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month),
                          SizedBox(width: 8),
                          Text('Xác nhận đặt lịch'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Xử lý chức năng gia hạn
  Future<void> _showRenewDialog(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.refresh, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Gia hạn tư vấn với bác sĩ ${doctor.fullName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Chọn phương thức gia hạn:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Thêm lượt tư vấn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddSessionsDialog(context, ref);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: const Text('Thêm ngày tư vấn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showExtendDaysDialog(context, ref);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại nhập số lượt tư vấn
  Future<void> _showAddSessionsDialog(BuildContext context, WidgetRef ref) async {
    int sessionCount = 1; // Mặc định là 1 lượt
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: Colors.blue),
              SizedBox(width: 8),
              Text('Thêm lượt tư vấn'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nhập số lượt tư vấn:'),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: sessionCount > 1 
                      ? () => setState(() => sessionCount--) 
                      : null,
                  ),
                  Expanded(
                    child: Text(
                      '$sessionCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () => setState(() => sessionCount++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.payment, size: 18, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text('Phí:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${sessionCount * 50.000}đ', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn sẽ được chuyển đến trang thanh toán VNPay',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  
                  // Gọi API tạo URL thanh toán VNPay
                  final paymentUrl = await VnpayService.createPaymentUrl(
                    bankCode: 'NCB',
                    doctorId: doctor.id ?? '',
                    language: 'vn',
                    orderType: 'AddCallVideo',
                    quantity: sessionCount
                  );
                  
                  // Mở URL trong trình duyệt
                  final uri = Uri.parse(paymentUrl);
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalNonBrowserApplication,
                  )) {
                    throw Exception('Không thể mở URL thanh toán');
                  }
                } catch (e) {
                  debugPrint('Lỗi khi xử lý thanh toán: $e');
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payment, size: 16),
                  SizedBox(width: 8),
                  Text('Thanh toán'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại thêm ngày tư vấn
  Future<void> _showExtendDaysDialog(BuildContext context, WidgetRef ref) async {
    int days = 30; // Mặc định là 30 ngày
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.green),
            SizedBox(width: 8),
            Text('Thêm ngày tư vấn'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thêm 30 ngày tư vấn với bác sĩ'),
            const SizedBox(height: 16),
            const Divider(),
            const Row(
              children: [
                Icon(Icons.payment, size: 18, color: Colors.blue),
                SizedBox(width: 4),
                Text('Phí gia hạn:', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text('300.000đ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn sẽ được chuyển đến trang thanh toán VNPay',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                
                // Gọi API tạo URL thanh toán VNPay
                final paymentUrl = await VnpayService.createPaymentUrl(
                  bankCode: 'NCB',
                  doctorId: doctor.id ?? '',
                  language: 'vn',
                  orderType: 'Extend',
                  quantity: 1
                );
                
                // Mở URL trong trình duyệt
                final uri = Uri.parse(paymentUrl);
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalNonBrowserApplication,
                )) {
                  throw Exception('Không thể mở URL thanh toán');
                }
              } catch (e) {
                debugPrint('Lỗi khi xử lý thanh toán: $e');
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment, size: 16),
                SizedBox(width: 8),
                Text('Thanh toán'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy dữ liệu tư vấn
    final String? startDate = doctor.consultationStartDate;
    final String? endDate = doctor.consultationEndDate;
    final int? callRemaining = doctor.consultationCallRemaining;
    
    // Kiểm tra thời hạn tư vấn
    final bool isExpired = _isConsultationExpired(endDate);
    final bool hasCallRemaining = callRemaining != null && callRemaining > 0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.fullName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin cơ bản
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: doctor.avatar != null
                              ? NetworkImage(doctor.avatar!)
                              : null,
                          child: doctor.avatar == null
                              ? Text(
                                  doctor.fullName[0],
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.fullName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (doctor.specialty != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialty!,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                              if (doctor.isVerified) ...[
                                const SizedBox(height: 4),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Đã xác thực',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin tư vấn
            if (startDate != null || endDate != null || callRemaining != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin tư vấn',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Số lượt tư vấn còn lại
                      if (callRemaining != null) ...[
                        _buildInfoRow(
                          context,
                          'Số lượt tư vấn còn lại',
                          '$callRemaining lượt',
                          Icons.phone_callback,
                          color: hasCallRemaining ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Ngày bắt đầu
                      if (startDate != null) ...[
                        _buildInfoRow(
                          context,
                          'Ngày bắt đầu tư vấn',
                          _formatDate(startDate),
                          Icons.play_circle_outline,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Ngày kết thúc
                      if (endDate != null) ...[
                        _buildInfoRow(
                          context,
                          'Ngày kết thúc tư vấn',
                          _formatDate(endDate),
                          Icons.event_busy,
                          color: isExpired ? Colors.red : Colors.green,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Trạng thái
                      _buildInfoRow(
                        context,
                        'Trạng thái gói tư vấn',
                        isExpired ? 'Đã hết hạn' : (hasCallRemaining ? 'Còn hiệu lực' : 'Hết lượt tư vấn'),
                        Icons.info_outline,
                        color: (!isExpired && hasCallRemaining) ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Thông tin chi tiết
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thông tin chi tiết',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    if (doctor.otherSpecialties != null) ...[
                      _buildInfoRow(
                        context,
                        'Chuyên khoa khác',
                        doctor.otherSpecialties!,
                        Icons.medical_services_outlined,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (doctor.education != null) ...[
                      _buildInfoRow(
                        context,
                        'Học vấn',
                        doctor.education!,
                        Icons.school,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (doctor.graduationYear != null) ...[
                      _buildInfoRow(
                        context,
                        'Năm tốt nghiệp',
                        doctor.graduationYear.toString(),
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (doctor.licenseNumber != null) ...[
                      _buildInfoRow(
                        context,
                        'Số giấy phép hành nghề',
                        doctor.licenseNumber!,
                        Icons.badge,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (doctor.experience != null) ...[
                      _buildInfoRow(
                        context,
                        'Số năm kinh nghiệm',
                        '${doctor.experience} năm',
                        Icons.work,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (doctor.currentWorkplace != null) ...[
                      _buildInfoRow(
                        context,
                        'Nơi làm việc hiện tại',
                        doctor.currentWorkplace!,
                        Icons.business,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (doctor.phone != null) ...[
                      _buildInfoRow(
                        context,
                        'Số điện thoại',
                        doctor.phone!,
                        Icons.phone,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (doctor.address != null) ...[
                      _buildInfoRow(
                        context,
                        'Địa chỉ',
                        doctor.address!,
                        Icons.location_on,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nút đặt lịch và gia hạn
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Đặt lịch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (!isExpired && hasCallRemaining) ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: (!isExpired && hasCallRemaining) 
                      ? () => _showBookingDialog(context, ref, callRemaining)
                      : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Gia hạn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showRenewDialog(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color ?? Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 