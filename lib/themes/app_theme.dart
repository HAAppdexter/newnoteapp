import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Các màu chủ đạo của ứng dụng
  static const Color primaryColor = Color(0xFF0D47A1); // Deep Blue
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color accentColor = Color(0xFF1976D2); // Lighter blue
  
  // Danh sách màu cho ghi chú
  static final List<Color> noteColors = [
    Colors.white,
    Colors.red[100]!,
    Colors.orange[100]!,
    Colors.yellow[100]!,
    Colors.green[100]!,
    Colors.blue[100]!,
    Colors.indigo[100]!,
    Colors.purple[100]!,
    Colors.pink[100]!,
    Colors.grey[100]!,
  ];
  
  // Chuyển đổi giữa Color và String hex
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
  
  static Color hexToColor(String hex) {
    if (hex.isEmpty) return Colors.white;
    hex = hex.replaceAll('#', '');
    return Color(int.parse('0xFF$hex'));
  }
  
  // Tạo theme chủ đạo - Không sử dụng Google Fonts
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black54),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Dark icons for status bar
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0.5,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
    fontFamily: 'Roboto', // Sử dụng font hệ thống thay vì Google Fonts
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Still using dark icons for status bar
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    fontFamily: 'Roboto', // Sử dụng font hệ thống thay vì Google Fonts
  );
  
  // Theme getter method
  static ThemeData getTheme({required bool isDark, required Color accentColor}) {
    return isDark ? darkTheme.copyWith(
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
      ),
    ) : lightTheme.copyWith(
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
      ),
    );
  }
} 