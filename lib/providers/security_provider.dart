import 'package:flutter/material.dart';
import 'package:newnoteapp/services/security_service.dart';
import 'package:local_auth/local_auth.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService = SecurityService();
  
  bool _isAuthenticated = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  SecurityProvider() {
    _initialize();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricAvailable => _isBiometricAvailable;
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  // Kiểm tra xem có đặt mã khóa bảo vệ chưa
  Future<bool> get hasPasscode => _securityService.hasPasscode();

  // Kiểm tra xem xác thực sinh trắc học có được bật không
  Future<bool> get isBiometricEnabled => _securityService.isBiometricEnabled();

  // Khởi tạo provider
  Future<void> _initialize() async {
    _isBiometricAvailable = await _securityService.isBiometricAvailable();
    if (_isBiometricAvailable) {
      _availableBiometrics = await _securityService.getAvailableBiometrics();
    }
  }

  // Thiết lập mã khóa bảo vệ
  Future<void> setPasscode(String passcode) async {
    await _securityService.setPasscode(passcode);
    notifyListeners();
  }

  // Xóa mã khóa bảo vệ
  Future<void> removePasscode() async {
    await _securityService.removePasscode();
    notifyListeners();
  }

  // Bật/tắt xác thực sinh trắc học
  Future<void> setBiometricEnabled(bool enabled) async {
    await _securityService.setBiometricEnabled(enabled);
    notifyListeners();
  }

  // Xác thực người dùng bằng mã khóa
  Future<bool> authenticateWithPasscode(String passcode) async {
    final isValid = await _securityService.verifyPasscode(passcode);
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return isValid;
  }

  // Xác thực người dùng bằng sinh trắc học
  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Xác thực để truy cập ghi chú bảo mật',
  }) async {
    final isValid = await _securityService.authenticateWithBiometrics(
      localizedReason: localizedReason,
    );
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return isValid;
  }

  // Xác thực người dùng kết hợp
  Future<bool> authenticate({
    String passcode = '',
    bool useBiometric = false,
    String localizedReason = 'Xác thực để truy cập ghi chú bảo mật',
  }) async {
    final isValid = await _securityService.authenticate(
      passcode: passcode,
      useBiometric: useBiometric,
      localizedReason: localizedReason,
    );
    
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    
    return isValid;
  }

  // Đăng xuất
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  // Kiểm tra xem có thể truy cập ghi chú bảo mật không
  Future<bool> canAccessProtectedNote() async {
    if (_isAuthenticated) return true;
    
    if (await isBiometricEnabled) {
      return await authenticateWithBiometrics();
    } else if (await hasPasscode) {
      return false; // Cần nhập mã khóa thủ công từ UI
    }
    
    return true; // Không có bảo vệ
  }
} 