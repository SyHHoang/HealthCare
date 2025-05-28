import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import 'package:flutter/foundation.dart';

class AuthState {
  final String? userId;
  final bool isLoading;
  final String? error;

  AuthState({
    this.userId,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? userId,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      state = state.copyWith(isLoading: true);
      final userId = await TokenService.getUserId();
      debugPrint('Lấy userId từ TokenService: $userId');
      state = state.copyWith(userId: userId, isLoading: false);
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo AuthNotifier: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.loginUser(email, password);
      final userId = await TokenService.getUserId();
      debugPrint('Đăng nhập thành công, userId: $userId');
      state = state.copyWith(userId: userId, isLoading: false);
    } catch (e) {
      debugPrint('Lỗi khi đăng nhập: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.logout();
      state = state.copyWith(userId: null, isLoading: false);
    } catch (e) {
      debugPrint('Lỗi khi đăng xuất: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
}); 