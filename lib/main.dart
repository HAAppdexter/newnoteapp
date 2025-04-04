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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo AdMob
  await MobileAds.instance.initialize();
  
  // Khởi tạo Firebase (tùy chọn, có thể bỏ nếu không dùng)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Tiếp tục chạy ứng dụng mà không có Firebase
  }
  
  // Cấu hình hướng màn hình
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
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
  @override
  void initState() {
    super.initState();
    
    // Đăng ký observer để lắng nghe các thay đổi về độ sáng hệ thống
    WidgetsBinding.instance.addObserver(this);
    
    // Khởi tạo AdProvider
    Future.delayed(Duration.zero, () {
      context.read<AdProvider>().initialize();
    });
  }
  
  @override
  void dispose() {
    // Hủy đăng ký observer khi widget bị dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    // Có thể cập nhật UI khi hệ thống thay đổi độ sáng
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Note App',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
