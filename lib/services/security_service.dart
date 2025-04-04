import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  static const String _passcodeKey = 'note_app_passcode';
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Singleton pattern
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Kiểm tra xem đã thiết lập mã khóa chưa
  Future<bool> hasPasscode() async {
    final passcode = await _secureStorage.read(key: _passcodeKey);
    return passcode != null && passcode.isNotEmpty;
  }

  // Thiết lập mã khóa
  Future<void> setPasscode(String passcode) async {
    await _secureStorage.write(key: _passcodeKey, value: passcode);
  }

  // Xác thực mã khóa
  Future<bool> verifyPasscode(String passcode) async {
    final storedPasscode = await _secureStorage.read(key: _passcodeKey);
    return storedPasscode == passcode;
  }

  // Xóa mã khóa
  Future<void> removePasscode() async {
    await _secureStorage.delete(key: _passcodeKey);
  }

  // Kiểm tra xem thiết bị có hỗ trợ xác thực sinh trắc học không
  Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics && 
           await _localAuth.isDeviceSupported();
  }

  // Lấy danh sách các loại xác thực sinh trắc học có sẵn
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!await isBiometricAvailable()) {
      return [];
    }
    
    return await _localAuth.getAvailableBiometrics();
  }

  // Bật/tắt xác thực sinh trắc học
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  // Kiểm tra xem xác thực sinh trắc học có được bật không
  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  // Thực hiện xác thực sinh trắc học
  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Xác thực để truy cập ghi chú bảo mật',
  }) async {
    if (!await isBiometricAvailable() || !await isBiometricEnabled()) {
      return false;
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Thực hiện xác thực bằng mã khóa hoặc sinh trắc học
  Future<bool> authenticate({
    String passcode = '',
    bool useBiometric = false,
    String localizedReason = 'Xác thực để truy cập ghi chú bảo mật',
  }) async {
    // Xác thực bằng passcode nếu được cung cấp
    if (passcode.isNotEmpty) {
      return await verifyPasscode(passcode);
    }
    
    // Xác thực bằng sinh trắc học nếu được yêu cầu
    if (useBiometric) {
      return await authenticateWithBiometrics(
        localizedReason: localizedReason,
      );
    }
    
    return false;
  }

  // Lưu trữ an toàn một giá trị
  Future<void> secureWrite(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  // Đọc giá trị đã lưu trữ an toàn
  Future<String?> secureRead(String key) async {
    return await _secureStorage.read(key: key);
  }

  // Xóa giá trị đã lưu trữ an toàn
  Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Xóa tất cả dữ liệu an toàn
  Future<void> secureDeleteAll() async {
    await _secureStorage.deleteAll();
  }
} 