import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Khởi tạo Firebase Analytics
final firebaseAnalytics = FirebaseAnalytics.instance;

// Đăng ký background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo FirebasePP
  await Firebase.initializeApp();
  
  // Đăng ký background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Khởi tạo FCM Service
  final container = ProviderContainer();
  await container.read(fcmServiceProvider).initialize();
  
  // Khởi tạo Firebase Messaging
  final messaging = FirebaseMessaging.instance;
  
  // Yêu cầu quyền thông báo
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  
  print('User granted permission: ${settings.authorizationStatus}');

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ Loaded .env file successfully");
    debugPrint("BASE_URL: ${dotenv.env['BASE_URL']}");
  } catch (e) {
    debugPrint("❌ Không thể load file .env: $e");
    debugPrint("Sử dụng default values");
    // Set default values nếu không load được .env
    dotenv.env['BASE_URL'] = 'http://192.168.2.101:5000/api';
  }
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
      ],
    );
  }
}
