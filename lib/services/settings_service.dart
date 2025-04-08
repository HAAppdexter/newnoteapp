import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const String _themeKey = 'app_theme';
  static const String _fontSizeKey = 'font_size';
  static const String _accentColorKey = 'accent_color';
  static const String _defaultViewKey = 'default_view'; // grid hoặc list
  static const String _showDateKey = 'show_date';
  static const String _enableBiometricKey = 'enable_biometric';
  static const String _defaultCategoryKey = 'default_category';
  static const String _autoBackupKey = 'auto_backup';
  static const String _lastBackupTimeKey = 'last_backup_time';
  static const String _lastViewedFilters = 'last_viewed_filters';
  static const String _lastSortOrder = 'last_sort_order';
  static const String _recentSearchesKey = 'recent_searches';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // Theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.toString());
  }

  ThemeMode getThemeMode() {
    final String? themeStr = _prefs.getString(_themeKey);
    if (themeStr == null) return ThemeMode.light;

    switch (themeStr) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  // Font size
  Future<void> setFontSize(double size) async {
    await _prefs.setDouble(_fontSizeKey, size);
  }

  double getFontSize() {
    return _prefs.getDouble(_fontSizeKey) ?? 16.0;
  }

  // Accent color
  Future<void> setAccentColor(Color color) async {
    await _prefs.setInt(_accentColorKey, color.value);
  }

  Color getAccentColor() {
    return Color(_prefs.getInt(_accentColorKey) ?? Colors.blue.value);
  }

  // Default view (grid/list)
  Future<void> setDefaultView(String view) async {
    await _prefs.setString(_defaultViewKey, view);
  }

  String getDefaultView() {
    return _prefs.getString(_defaultViewKey) ?? 'grid';
  }

  // Show date on notes
  Future<void> setShowDate(bool show) async {
    await _prefs.setBool(_showDateKey, show);
  }

  bool getShowDate() {
    return _prefs.getBool(_showDateKey) ?? true;
  }

  // Biometric authentication
  Future<void> setEnableBiometric(bool enable) async {
    await _prefs.setBool(_enableBiometricKey, enable);
  }

  bool getEnableBiometric() {
    return _prefs.getBool(_enableBiometricKey) ?? false;
  }

  // Default category
  Future<void> setDefaultCategory(String? categoryId) async {
    if (categoryId == null) {
      await _prefs.remove(_defaultCategoryKey);
    } else {
      await _prefs.setString(_defaultCategoryKey, categoryId);
    }
  }

  String? getDefaultCategory() {
    return _prefs.getString(_defaultCategoryKey);
  }

  // Auto backup
  Future<void> setAutoBackup(bool enable) async {
    await _prefs.setBool(_autoBackupKey, enable);
  }

  bool getAutoBackup() {
    return _prefs.getBool(_autoBackupKey) ?? false;
  }

  // Last backup time
  Future<void> setLastBackupTime(DateTime time) async {
    await _prefs.setInt(_lastBackupTimeKey, time.millisecondsSinceEpoch);
  }

  DateTime? getLastBackupTime() {
    final timestamp = _prefs.getInt(_lastBackupTimeKey);
    if (timestamp == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Last viewed filters
  Future<void> setLastViewedFilters(Map<String, dynamic> filters) async {
    await _prefs.setString(_lastViewedFilters, jsonEncode(filters));
  }

  Map<String, dynamic> getLastViewedFilters() {
    final String? filtersStr = _prefs.getString(_lastViewedFilters);
    if (filtersStr == null) {
      return {};
    }
    return jsonDecode(filtersStr) as Map<String, dynamic>;
  }

  // Last sort order
  Future<void> setLastSortOrder(String sortOrder) async {
    await _prefs.setString(_lastSortOrder, sortOrder);
  }

  String getLastSortOrder() {
    return _prefs.getString(_lastSortOrder) ?? 'updatedDesc';
  }

  // Recent searches
  Future<void> addRecentSearch(String query) async {
    final List<String> searches = getRecentSearches();
    
    // Xóa nếu đã tồn tại để thêm vào đầu danh sách
    searches.remove(query);
    
    // Thêm vào đầu danh sách
    searches.insert(0, query);
    
    // Giới hạn chỉ giữ 10 từ khóa gần nhất
    if (searches.length > 10) {
      searches.removeLast();
    }
    
    await _prefs.setStringList(_recentSearchesKey, searches);
  }

  Future<void> clearRecentSearches() async {
    await _prefs.setStringList(_recentSearchesKey, []);
  }

  List<String> getRecentSearches() {
    return _prefs.getStringList(_recentSearchesKey) ?? [];
  }

  // Xóa tất cả cài đặt
  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 