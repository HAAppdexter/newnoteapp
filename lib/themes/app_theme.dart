import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color _primaryLightColor = Color(0xFF5D9CEC);
  static const Color _primaryDarkColor = Color(0xFF5C93D8);
  
  static const Color _secondaryLightColor = Color(0xFF03A9F4);
  static const Color _secondaryDarkColor = Color(0xFF039BE5);
  
  static const Color _backgroundLightColor = Color(0xFFF5F5F5);
  static const Color _backgroundDarkColor = Color(0xFF121212);
  
  static const Color _cardLightColor = Color(0xFFFFFFFF);
  static const Color _cardDarkColor = Color(0xFF1E1E1E);
  
  static const Color _textPrimaryLightColor = Color(0xFF212121);
  static const Color _textPrimaryDarkColor = Color(0xFFEEEEEE);
  
  static const Color _textSecondaryLightColor = Color(0xFF757575);
  static const Color _textSecondaryDarkColor = Color(0xFFAAAAAA);

  static const Color _errorColor = Color(0xFFE53935);
  static const Color _successColor = Color(0xFF43A047);
  static const Color _warningColor = Color(0xFFFFB300);
  static const Color _infoColor = Color(0xFF039BE5);

  // Note colors
  static const List<Color> noteColors = [
    Color(0xFFFFFFFF), // White
    Color(0xFFFFA1A1), // Light Red
    Color(0xFFFFD8A1), // Light Orange
    Color(0xFFFFF1A1), // Light Yellow
    Color(0xFFD6F0AA), // Light Green
    Color(0xFFA1C5FF), // Light Blue
    Color(0xFFE1A1FF), // Light Purple
    Color(0xFFEEEEEE), // Light Grey
  ];

  // Function to get ThemeData based on isDark flag
  static ThemeData getTheme({bool isDark = false}) {
    return isDark ? _getDarkTheme() : _getLightTheme();
  }

  // Light Theme
  static ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLightColor,
        secondary: _secondaryLightColor,
        background: _backgroundLightColor,
        surface: _cardLightColor,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: _textPrimaryLightColor,
        onSurface: _textPrimaryLightColor,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: _textPrimaryLightColor),
          displayMedium: TextStyle(color: _textPrimaryLightColor),
          displaySmall: TextStyle(color: _textPrimaryLightColor),
          headlineLarge: TextStyle(color: _textPrimaryLightColor),
          headlineMedium: TextStyle(color: _textPrimaryLightColor),
          headlineSmall: TextStyle(color: _textPrimaryLightColor),
          titleLarge: TextStyle(color: _textPrimaryLightColor),
          titleMedium: TextStyle(color: _textPrimaryLightColor),
          titleSmall: TextStyle(color: _textPrimaryLightColor),
          bodyLarge: TextStyle(color: _textPrimaryLightColor),
          bodyMedium: TextStyle(color: _textPrimaryLightColor),
          bodySmall: TextStyle(color: _textSecondaryLightColor),
          labelLarge: TextStyle(color: _textPrimaryLightColor),
          labelMedium: TextStyle(color: _textPrimaryLightColor),
          labelSmall: TextStyle(color: _textSecondaryLightColor),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryLightColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardTheme(
        color: _cardLightColor,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      scaffoldBackgroundColor: _backgroundLightColor,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryLightColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primaryLightColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _primaryLightColor,
        unselectedItemColor: _textSecondaryLightColor,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryLightColor;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: _textSecondaryLightColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryLightColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryLightColor.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: _primaryLightColor,
        unselectedLabelColor: _textSecondaryLightColor,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: _primaryLightColor,
            width: 2,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _cardLightColor,
        contentTextStyle: const TextStyle(color: _textPrimaryLightColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _cardLightColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
    );
  }

  // Dark Theme
  static ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDarkColor,
        secondary: _secondaryDarkColor,
        background: _backgroundDarkColor,
        surface: _cardDarkColor,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: _textPrimaryDarkColor,
        onSurface: _textPrimaryDarkColor,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: _textPrimaryDarkColor),
          displayMedium: TextStyle(color: _textPrimaryDarkColor),
          displaySmall: TextStyle(color: _textPrimaryDarkColor),
          headlineLarge: TextStyle(color: _textPrimaryDarkColor),
          headlineMedium: TextStyle(color: _textPrimaryDarkColor),
          headlineSmall: TextStyle(color: _textPrimaryDarkColor),
          titleLarge: TextStyle(color: _textPrimaryDarkColor),
          titleMedium: TextStyle(color: _textPrimaryDarkColor),
          titleSmall: TextStyle(color: _textPrimaryDarkColor),
          bodyLarge: TextStyle(color: _textPrimaryDarkColor),
          bodyMedium: TextStyle(color: _textPrimaryDarkColor),
          bodySmall: TextStyle(color: _textSecondaryDarkColor),
          labelLarge: TextStyle(color: _textPrimaryDarkColor),
          labelMedium: TextStyle(color: _textPrimaryDarkColor),
          labelSmall: TextStyle(color: _textSecondaryDarkColor),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _cardDarkColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _textPrimaryDarkColor,
      ),
      cardTheme: const CardTheme(
        color: _cardDarkColor,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      scaffoldBackgroundColor: _backgroundDarkColor,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryDarkColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardDarkColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primaryDarkColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _cardDarkColor,
        selectedItemColor: _primaryDarkColor,
        unselectedItemColor: _textSecondaryDarkColor,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryDarkColor;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: _textSecondaryDarkColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryDarkColor;
          }
          return Colors.grey.shade700;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryDarkColor.withOpacity(0.5);
          }
          return Colors.grey.shade800;
        }),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: _primaryDarkColor,
        unselectedLabelColor: _textSecondaryDarkColor,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: _primaryDarkColor,
            width: 2,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _cardDarkColor,
        contentTextStyle: const TextStyle(color: _textPrimaryDarkColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _cardDarkColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
    );
  }

  // Helpers
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'error':
        return _errorColor;
      case 'success':
        return _successColor;
      case 'warning':
        return _warningColor;
      case 'info':
        return _infoColor;
      default:
        return _infoColor;
    }
  }

  // Convert Hex String to Color
  static Color hexToColor(String hexString) {
    if (hexString.isEmpty) return Colors.white;
    
    hexString = hexString.replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }
    
    return Color(int.parse(hexString, radix: 16));
  }

  // Convert Color to Hex String
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
} 