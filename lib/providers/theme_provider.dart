import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:newnoteapp/services/settings_service.dart';
import 'package:newnoteapp/themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  late SettingsService _settingsService;
  late ThemeMode _themeMode;
  late Color _accentColor;
  Brightness? _lastSystemBrightness;
  
  // Lưu cache theme data để tránh tạo lại nhiều lần
  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;
  bool _isInitialized = false;

  ThemeProvider() {
    _settingsService = SettingsService();
    _themeMode = ThemeMode.light;
    _accentColor = Colors.blue;
    
    // Lấy brightness hiện tại của hệ thống
    _lastSystemBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  }
  
  // Khởi tạo provider với dữ liệu từ bộ nhớ cục bộ
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadSettings();
    _setupBrightnessListener();
    _isInitialized = true;
  }

  // Thiết lập theo dõi thay đổi brightness của hệ thống
  void _setupBrightnessListener() {
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      // Chỉ cập nhật UI nếu đang sử dụng theme theo hệ thống
      updateSystemBrightness();
    };
  }
  
  // Cập nhật theme khi hệ thống thay đổi độ sáng
  void updateSystemBrightness() {
    final currentBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    if (_lastSystemBrightness != currentBrightness && _themeMode == ThemeMode.system) {
      _lastSystemBrightness = currentBrightness;
      notifyListeners();
    }
  }

  // Getter cho theme mode
  ThemeMode get themeMode => _themeMode;

  // Getter cho light theme với cache
  ThemeData get lightTheme {
    _cachedLightTheme ??= AppTheme.getTheme(isDark: false, accentColor: _accentColor);
    return _cachedLightTheme!;
  }

  // Getter cho dark theme với cache
  ThemeData get darkTheme {
    _cachedDarkTheme ??= AppTheme.getTheme(isDark: true, accentColor: _accentColor);
    return _cachedDarkTheme!;
  }

  // Getter cho accent color
  Color get accentColor => _accentColor;

  // Kiểm tra xem đang sử dụng dark mode hay không
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Thiết lập theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _settingsService.setThemeMode(mode);
    notifyListeners();
  }

  // Thiết lập accent color
  Future<void> setAccentColor(Color color) async {
    if (_accentColor == color) return;
    
    _accentColor = color;
    
    // Xóa cache khi thay đổi màu accent để tạo lại theme data
    _cachedLightTheme = null;
    _cachedDarkTheme = null;
    
    await _settingsService.setAccentColor(color);
    notifyListeners();
  }

  // Thay đổi qua dark mode
  Future<void> toggleDarkMode() async {
    await setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  // Load cài đặt từ local storage
  Future<void> _loadSettings() async {
    await _settingsService.init();
    
    final savedThemeMode = _settingsService.getThemeMode();
    final savedAccentColor = _settingsService.getAccentColor();
    
    // Chỉ cập nhật nếu có thay đổi thực sự
    if (_themeMode != savedThemeMode) {
      _themeMode = savedThemeMode;
    }
    
    if (_accentColor != savedAccentColor) {
      _accentColor = savedAccentColor;
      // Xóa cache khi thay đổi màu accent
      _cachedLightTheme = null;
      _cachedDarkTheme = null;
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    // Hủy listener khi provider bị dispose
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = null;
    super.dispose();
  }

  void updateTheme() {
    try {
      // Create new theme instances for both light and dark modes
      _cachedLightTheme = AppTheme.getTheme(
        isDark: false,
        accentColor: accentColor,
      );
      
      _cachedDarkTheme = AppTheme.getTheme(
        isDark: true,
        accentColor: accentColor,
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating theme: $e');
    }
  }
} 