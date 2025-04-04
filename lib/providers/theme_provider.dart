import 'package:flutter/material.dart';
import 'package:newnoteapp/services/settings_service.dart';
import 'package:newnoteapp/themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  late SettingsService _settingsService;
  late ThemeMode _themeMode;
  late Color _accentColor;
  Brightness? _lastBrightness;

  ThemeProvider() {
    _settingsService = SettingsService();
    _themeMode = ThemeMode.system;
    _accentColor = Colors.blue;
    _loadSettings();
    _setupBrightnessListener();
  }

  // Thiết lập theo dõi thay đổi brightness của hệ thống
  void _setupBrightnessListener() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      if (_lastBrightness != brightness && _themeMode == ThemeMode.system) {
        _lastBrightness = brightness;
        notifyListeners(); // Thông báo UI cập nhật khi brightness thay đổi
      }
    };
    _lastBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  // Getter cho theme mode
  ThemeMode get themeMode => _themeMode;

  // Getter cho light theme
  ThemeData get lightTheme => AppTheme.getTheme(isDark: false);

  // Getter cho dark theme
  ThemeData get darkTheme => AppTheme.getTheme(isDark: true);

  // Getter cho accent color
  Color get accentColor => _accentColor;

  // Kiểm tra xem đang sử dụng dark mode hay không
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
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
    
    _themeMode = _settingsService.getThemeMode();
    _accentColor = _settingsService.getAccentColor();
    
    notifyListeners();
  }

  @override
  void dispose() {
    // Hủy listener khi provider bị dispose
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = null;
    super.dispose();
  }
} 