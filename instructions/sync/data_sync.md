# Hướng Dẫn Module: Đồng Bộ & Bảo Mật

## Tổng Quan
Module này cung cấp các tính năng đồng bộ hóa ghi chú giữa các thiết bị và bảo mật dữ liệu người dùng. Mục tiêu là đảm bảo người dùng có thể truy cập ghi chú của họ trên nhiều thiết bị và bảo vệ thông tin nhạy cảm.

## Tính Năng Chi Tiết

### 1. Đồng Bộ Cơ Bản Giữa Thiết Bị ❌
- **Mô tả**: Đồng bộ hóa ghi chú giữa các thiết bị
- **Yêu cầu**:
  - Sử dụng Firebase Firestore cho lưu trữ đám mây
  - Đồng bộ tự động khi có kết nối mạng
  - Phát hiện và giải quyết xung đột
  - Chỉ báo trạng thái đồng bộ
  - Tùy chọn bật/tắt đồng bộ tự động

### 2. Bảo Vệ Ghi Chú Bằng Mật Khẩu ❌
- **Mô tả**: Cho phép người dùng bảo vệ ghi chú nhạy cảm bằng mật khẩu
- **Yêu cầu**:
  - Khóa/mở khóa ghi chú cá nhân
  - Mã hóa nội dung ghi chú được bảo vệ
  - Tùy chọn sử dụng sinh trắc học (vân tay, Face ID) để mở khóa
  - Tự động khóa sau một khoảng thời gian

### 3. Sao Lưu/Khôi Phục ❌
- **Mô tả**: Cho phép người dùng sao lưu và khôi phục dữ liệu ghi chú
- **Yêu cầu**:
  - Sao lưu thủ công và tự động định kỳ
  - Xuất sao lưu dưới dạng file (JSON/ZIP)
  - Nhập sao lưu từ file
  - Hiển thị lịch sử sao lưu

## Luồng Hoạt Động

### Đồng Bộ Hóa
1. Người dùng đăng nhập vào tài khoản
2. Hệ thống tự động đồng bộ dữ liệu từ đám mây
3. Khi người dùng thực hiện thay đổi, dữ liệu được đồng bộ lên đám mây
4. Nếu phát hiện xung đột, hiển thị tùy chọn giải quyết
5. Đồng bộ trong nền khi có kết nối

### Bảo Vệ Ghi Chú
1. Người dùng chọn tùy chọn "Bảo vệ" cho ghi chú
2. Hệ thống yêu cầu tạo/nhập mật khẩu hoặc sử dụng sinh trắc học
3. Ghi chú được mã hóa và đánh dấu là được bảo vệ
4. Khi mở ghi chú được bảo vệ, hệ thống yêu cầu xác thực

### Sao Lưu/Khôi Phục
1. Người dùng truy cập màn hình cài đặt
2. Chọn tùy chọn sao lưu/khôi phục
3. Đối với sao lưu: tạo file sao lưu và lưu vào bộ nhớ/đám mây
4. Đối với khôi phục: chọn file sao lưu để nhập

## Chi Tiết Kỹ Thuật

### Đồng Bộ Hóa
```dart
class SyncService {
  // Khởi tạo Firebase
  Future<void> initialize();
  
  // Đồng bộ lên đám mây
  Future<bool> syncToCloud(List<Note> notes);
  
  // Lấy dữ liệu từ đám mây
  Future<List<Note>> syncFromCloud();
  
  // Giải quyết xung đột
  Future<Note> resolveConflict(Note localNote, Note remoteNote);
}
```

### Mã Hóa
```dart
class EncryptionService {
  // Mã hóa dữ liệu
  Future<String> encrypt(String data, String password);
  
  // Giải mã dữ liệu
  Future<String> decrypt(String encryptedData, String password);
  
  // Xác thực bằng sinh trắc học
  Future<bool> authenticateBiometric();
}
```

### Sao Lưu/Khôi Phục
```dart
class BackupService {
  // Tạo file sao lưu
  Future<File> createBackup(List<Note> notes, List<Category> categories);
  
  // Khôi phục từ file
  Future<bool> restoreFromBackup(File backupFile);
  
  // Lập lịch sao lưu tự động
  Future<void> scheduleAutoBackup(Duration interval);
}
```

### Cấu Trúc Dữ Liệu Đồng Bộ
- Collection `users/{userId}/notes`: Lưu trữ ghi chú
- Collection `users/{userId}/categories`: Lưu trữ danh mục
- Document `users/{userId}/syncInfo`: Thông tin đồng bộ

### Bảo Mật
- Sử dụng thuật toán AES-256 cho mã hóa
- Lưu trữ khóa mã hóa an toàn sử dụng EncryptedSharedPreferences
- Không lưu mật khẩu thô, chỉ lưu hash

## Tích Hợp Với Các Module Khác
- **Quản Lý Ghi Chú**: Đồng bộ dữ liệu ghi chú
- **Tổ Chức**: Đồng bộ danh mục và thông tin tổ chức
- **UI/UX**: Hiển thị trạng thái đồng bộ và giao diện bảo mật

## Tiêu Chí Hoàn Thành
- Đồng bộ hóa hoạt động chính xác giữa các thiết bị
- Ghi chú được bảo vệ không thể truy cập khi chưa xác thực
- Sao lưu/khôi phục dữ liệu hoạt động đúng
- Đồng bộ hoạt động kể cả khi offline (đồng bộ lại khi có kết nối)
- Hiệu suất đồng bộ tốt, không ảnh hưởng đến trải nghiệm người dùng

## Kiểm Thử
- Kiểm thử đồng bộ giữa nhiều thiết bị
- Kiểm thử xung đột dữ liệu
- Kiểm thử bảo mật và mã hóa
- Kiểm thử sao lưu/khôi phục
- Kiểm thử trong điều kiện mạng không ổn định 