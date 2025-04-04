import 'package:flutter/material.dart';
import 'package:newnoteapp/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  double _fontSize = 16.0;
  String _defaultView = 'grid';
  bool _showDate = true;
  bool _enableBiometric = false;
  String? _defaultCategory;
  bool _autoBackup = false;
  DateTime? _lastBackupTime;
  List<String> _recentSearches = [];
  Map<String, dynamic> _lastViewedFilters = {};
  String _lastSortOrder = 'updatedDesc';

  bool _isInitialized = false;

  SettingsProvider() {
    _initialize();
  }

  // Getters
  double get fontSize => _fontSize;
  String get defaultView => _defaultView;
  bool get showDate => _showDate;
  bool get enableBiometric => _enableBiometric;
  String? get defaultCategory => _defaultCategory;
  bool get autoBackup => _autoBackup;
  DateTime? get lastBackupTime => _lastBackupTime;
  List<String> get recentSearches => _recentSearches;
  Map<String, dynamic> get lastViewedFilters => _lastViewedFilters;
  String get lastSortOrder => _lastSortOrder;

  // Khởi tạo provider
  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    await _settingsService.init();
    
    _fontSize = _settingsService.getFontSize();
    _defaultView = _settingsService.getDefaultView();
    _showDate = _settingsService.getShowDate();
    _enableBiometric = _settingsService.getEnableBiometric();
    _defaultCategory = _settingsService.getDefaultCategory();
    _autoBackup = _settingsService.getAutoBackup();
    _lastBackupTime = _settingsService.getLastBackupTime();
    _recentSearches = _settingsService.getRecentSearches();
    _lastViewedFilters = _settingsService.getLastViewedFilters();
    _lastSortOrder = _settingsService.getLastSortOrder();
    
    _isInitialized = true;
    notifyListeners();
  }

  // Cập nhật font size
  Future<void> setFontSize(double size) async {
    if (_fontSize == size) return;
    
    _fontSize = size;
    await _settingsService.setFontSize(size);
    notifyListeners();
  }

  // Cập nhật default view
  Future<void> setDefaultView(String view) async {
    if (_defaultView == view) return;
    
    _defaultView = view;
    await _settingsService.setDefaultView(view);
    notifyListeners();
  }

  // Cập nhật hiển thị ngày
  Future<void> setShowDate(bool show) async {
    if (_showDate == show) return;
    
    _showDate = show;
    await _settingsService.setShowDate(show);
    notifyListeners();
  }

  // Cập nhật bật/tắt sinh trắc học
  Future<void> setEnableBiometric(bool enable) async {
    if (_enableBiometric == enable) return;
    
    _enableBiometric = enable;
    await _settingsService.setEnableBiometric(enable);
    notifyListeners();
  }

  // Cập nhật danh mục mặc định
  Future<void> setDefaultCategory(String? categoryId) async {
    if (_defaultCategory == categoryId) return;
    
    _defaultCategory = categoryId;
    await _settingsService.setDefaultCategory(categoryId);
    notifyListeners();
  }

  // Cập nhật tự động sao lưu
  Future<void> setAutoBackup(bool enable) async {
    if (_autoBackup == enable) return;
    
    _autoBackup = enable;
    await _settingsService.setAutoBackup(enable);
    notifyListeners();
  }

  // Cập nhật thời gian sao lưu gần nhất
  Future<void> setLastBackupTime(DateTime time) async {
    _lastBackupTime = time;
    await _settingsService.setLastBackupTime(time);
    notifyListeners();
  }

  // Thêm từ khóa tìm kiếm gần đây
  Future<void> addRecentSearch(String query) async {
    await _settingsService.addRecentSearch(query);
    _recentSearches = _settingsService.getRecentSearches();
    notifyListeners();
  }

  // Xóa tất cả từ khóa tìm kiếm gần đây
  Future<void> clearRecentSearches() async {
    await _settingsService.clearRecentSearches();
    _recentSearches = [];
    notifyListeners();
  }

  // Cập nhật bộ lọc đã xem gần đây
  Future<void> setLastViewedFilters(Map<String, dynamic> filters) async {
    _lastViewedFilters = filters;
    await _settingsService.setLastViewedFilters(filters);
    notifyListeners();
  }

  // Cập nhật sắp xếp gần đây
  Future<void> setLastSortOrder(String sortOrder) async {
    _lastSortOrder = sortOrder;
    await _settingsService.setLastSortOrder(sortOrder);
    notifyListeners();
  }

  // Đặt lại tất cả cài đặt
  Future<void> resetAllSettings() async {
    await _settingsService.clearAllSettings();
    await _initialize();
  }
} 