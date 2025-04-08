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
import 'package:newnoteapp/themes/app_theme.dart';

// Khởi tạo các futures ở cấp module để tái sử dụng
Future<void> _initAdMob() async {
  try {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized successfully');
  } catch (e) {
    debugPrint('AdMob initialization failed: $e');
  }
}

// Biến để theo dõi trạng thái Firebase
bool isFirebaseInitialized = false;

Future<void> _initFirebase() async {
  try {
    debugPrint('Starting Firebase initialization...');
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('Firebase initialization failed: $e');
    // Log chi tiết lỗi để dễ dàng debug
    if (e is FirebaseException) {
      debugPrint('Firebase error code: ${e.code}');
      debugPrint('Firebase error message: ${e.message}');
    }
    // Cho phép ứng dụng tiếp tục mà không cần Firebase
  }
}

// Khởi chạy ứng dụng với các thiết lập cần thiết
Future<void> main() async {
  // Đảm bảo framework được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style to have dark status bar icons (light background)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Dark icons on light background
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  // Cấu hình hướng màn hình
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Khởi tạo Firebase trước các dịch vụ khác
  try {
    await _initFirebase();
  } catch (e) {
    debugPrint('Failed to initialize Firebase in main: $e');
  }
  
  // Khởi tạo AdMob sau Firebase
  try {
    await _initAdMob();
  } catch (e) {
    debugPrint('Failed to initialize AdMob in main: $e');
  }
  
  // Chạy ứng dụng
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // If system theme is selected, use light mode instead
        final effectiveThemeMode = themeProvider.themeMode == ThemeMode.system 
            ? ThemeMode.light 
            : themeProvider.themeMode;
            
        return MaterialApp(
          title: 'Note App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: effectiveThemeMode,
          debugShowCheckedModeBanner: false,
          home: const AppContent(),
        );
      },
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
  bool _servicesInitialized = false;

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
    if (_servicesInitialized) return;
    
    try {
      // Khởi tạo theme provider trước
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.initialize();
      
      // Firebase đã được khởi tạo ở main, không cần khởi tạo lại
      // AdMob cũng đã được khởi tạo ở main
      
      // Chỉ khởi tạo AdProvider khi widget đã gắn vào tree
      if (mounted) {
        final adProvider = Provider.of<AdProvider>(context, listen: false);
        await adProvider.initialize();
      }
      
      _servicesInitialized = true;
    } catch (e) {
      debugPrint('Error initializing services in AppContentState: $e');
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
        // If system theme is selected, use light mode instead
        final effectiveThemeMode = themeProvider.themeMode == ThemeMode.system 
            ? ThemeMode.light 
            : themeProvider.themeMode;
            
        return MaterialApp(
          title: 'Note App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: effectiveThemeMode,
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
