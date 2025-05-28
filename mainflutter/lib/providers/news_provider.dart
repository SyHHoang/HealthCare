import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/news.dart';
import '../services/news_service.dart';

// Phần này sẽ được tạo tự động bởi build_runner
part 'news_provider.g.dart';

// Provider trạng thái để xác định liệu dữ liệu đã được tải hay chưa
@riverpod
class NewsLoaded extends _$NewsLoaded {
  @override
  bool build() => false;
  
  void setLoaded(bool value) {
    state = value;
  }
}

// Provider cho dịch vụ tin tức
@Riverpod(keepAlive: true)
NewsService newsService(NewsServiceRef ref) => NewsService();

// Provider cho danh sách tin tức
@Riverpod(keepAlive: true)
class NewsNotifier extends _$NewsNotifier {
  @override
  FutureOr<List<News>> build() {
    // Trả về danh sách trống ban đầu
    return [];
  }
  
  // Phương thức để tải tin tức khi cần
  Future<void> loadNews() async {
    try {
      // Bắt đầu tải dữ liệu
      state = const AsyncLoading();
      
      // Gọi API để lấy dữ liệu
      final newsService = ref.read(newsServiceProvider);
      final news = await newsService.getAllNews();
      
      // Cập nhật state với dữ liệu mới
      state = AsyncData(news);
      ref.read(newsLoadedProvider.notifier).setLoaded(true);
    } catch (e) {
      // Xử lý lỗi
      state = AsyncError(e, StackTrace.current);
    }
  }
  
  // Reset dữ liệu về trạng thái ban đầu
  void reset() {
    state = const AsyncData([]);
  }
}

// Provider đơn giản để truy cập tin tức đã được tải
@Riverpod(keepAlive: true)
List<News> news(NewsRef ref) {
  final newsState = ref.watch(newsNotifierProvider);
  return newsState.when(
    data: (news) => news,
    loading: () => [],
    error: (_, __) => [],
  );
} 