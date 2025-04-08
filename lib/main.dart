import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:newnoteapp/providers/theme_provider.dart';
import 'package:newnoteapp/providers/note_provider.dart';
import 'package:newnoteapp/providers/settings_provider.dart';
import 'package:newnoteapp/providers/security_provider.dart';
import 'package:newnoteapp/providers/ad_provider.dart';
import 'package:newnoteapp/screens/home_screen.dart';

// Khởi tạo các futures ở cấp module để tái sử dụng
Future<void> _initAdMob() async {
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob initialization failed: $e');
  }
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Cho phép ứng dụng tiếp tục mà không cần Firebase
  }
}

// Khởi chạy ứng dụng với các thiết lập cần thiết
Future<void> main() async {
  // Đảm bảo framework được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cấu hình hướng màn hình
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Chạy ứng dụng ngay lập tức, không chờ các services khởi tạo xong
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Lazy loading các providers để tránh khởi tạo tất cả cùng lúc
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          lazy: false, // ThemeProvider cần được khởi tạo ngay để hiển thị đúng theme
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => SecurityProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => AdProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => NoteProvider(),
          lazy: true,
        ),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  AppContentState createState() => AppContentState();
}

class AppContentState extends State<AppContent> with WidgetsBindingObserver {
  // Sử dụng FutureBuilder để tối ưu quá trình khởi động
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    
    // Đăng ký observer để lắng nghe các thay đổi về độ sáng hệ thống
    WidgetsBinding.instance.addObserver(this);
    
    // Khởi tạo các services theo thứ tự ưu tiên
    _initFuture = _initializeServices();
  }
  
  // Khởi tạo các services tuần tự theo thứ tự ưu tiên
  Future<void> _initializeServices() async {
    try {
      // Khởi tạo theme provider trước
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.initialize();
      
      // Đợi AdMob khởi tạo xong - ưu tiên thấp, có thể tải sau
      await _initAdMob();
      
      // Chỉ khởi tạo AdProvider khi widget đã gắn vào tree
      if (mounted) {
        final adProvider = Provider.of<AdProvider>(context, listen: false);
        await adProvider.initialize();
      }
      
      // Đợi Firebase khởi tạo xong - ưu tiên thấp nhất
      await _initFirebase();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }
  
  @override
  void dispose() {
    // Hủy đăng ký observer khi widget bị dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    // Cập nhật theme khi hệ thống thay đổi độ sáng
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemBrightness();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Note App',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
          // Sử dụng các kỹ thuật tối ưu khởi động
          builder: (context, child) {
            // Áp dụng tối ưu typography và scale
            return MediaQuery(
              // Tránh rebuild khi keyboard hiện/ẩn
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
