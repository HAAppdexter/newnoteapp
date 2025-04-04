# Hướng Dẫn Module: Tổ Chức Ghi Chú

## Tổng Quan
Module này cung cấp các tính năng để tổ chức ghi chú, bao gồm danh mục, màu sắc, ghim ghi chú quan trọng và lưu trữ. Module này giúp người dùng quản lý lượng ghi chú lớn một cách hiệu quả.

## Tính Năng Chi Tiết

### 1. Danh Mục Ghi Chú ❌
- **Mô tả**: Cho phép người dùng tạo và quản lý danh mục để phân loại ghi chú
- **Yêu cầu**:
  - Tạo, chỉnh sửa, xóa danh mục
  - Gán ghi chú vào danh mục
  - Hỗ trợ nhiều danh mục cho một ghi chú
  - Lọc ghi chú theo danh mục
  - Danh mục mặc định: Tất cả, Chưa phân loại

### 2. Màu Sắc Ghi Chú ❌
- **Mô tả**: Cho phép người dùng gán màu sắc cho ghi chú để phân biệt trực quan
- **Yêu cầu**:
  - Cung cấp bảng màu đa dạng (ít nhất 8 màu)
  - Hiển thị màu sắc trong danh sách ghi chú
  - Lọc ghi chú theo màu sắc
  - Màu mặc định cho ghi chú mới

### 3. Ghim Ghi Chú Quan Trọng ❌
- **Mô tả**: Cho phép người dùng ghim ghi chú quan trọng lên đầu danh sách
- **Yêu cầu**:
  - Ghim/bỏ ghim ghi chú bằng một thao tác đơn giản
  - Hiển thị ghi chú đã ghim ở đầu danh sách
  - Hiển thị biểu tượng ghim trên ghi chú đã ghim
  - Giới hạn số lượng ghi chú được ghim (tối đa 5)

### 4. Lưu Trữ/Bỏ Lưu Trữ ❌
- **Mô tả**: Cho phép người dùng lưu trữ ghi chú không còn cần thiết nhưng chưa muốn xóa
- **Yêu cầu**:
  - Lưu trữ/bỏ lưu trữ ghi chú bằng thao tác đơn giản
  - Hiển thị danh sách ghi chú đã lưu trữ riêng biệt
  - Không hiển thị ghi chú đã lưu trữ trong danh sách chính
  - Cho phép khôi phục ghi chú đã lưu trữ

## Luồng Hoạt Động

### Quản Lý Danh Mục
1. Người dùng truy cập màn hình quản lý danh mục từ menu
2. Hiển thị danh sách danh mục hiện có
3. Người dùng có thể tạo, chỉnh sửa, xóa danh mục
4. Hệ thống cập nhật danh sách danh mục và ghi chú liên quan

### Gán Màu Sắc
1. Người dùng mở ghi chú hoặc chọn ghi chú từ danh sách
2. Người dùng chọn tùy chọn "Màu sắc"
3. Hiển thị bảng màu để lựa chọn
4. Người dùng chọn màu mong muốn
5. Hệ thống cập nhật màu cho ghi chú

### Ghim Ghi Chú
1. Người dùng vuốt sang phải trên ghi chú hoặc nhấn biểu tượng "Ghim"
2. Hệ thống ghim ghi chú và đưa lên đầu danh sách
3. Nếu đã đạt giới hạn ghim, hiển thị thông báo

### Lưu Trữ Ghi Chú
1. Người dùng vuốt sang phải trên ghi chú hoặc chọn tùy chọn "Lưu trữ"
2. Hệ thống di chuyển ghi chú vào danh sách lưu trữ
3. Người dùng có thể xem danh sách lưu trữ qua menu

## Chi Tiết Kỹ Thuật

### Cấu Trúc Model Danh Mục
```dart
class Category {
  String id;
  String name;
  String color;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Quan Hệ Giữa Ghi Chú và Danh Mục
```dart
class NoteCategory {
  String id;
  String noteId;
  String categoryId;
}
```

### Lưu Trữ
- Sử dụng SQLite để lưu trữ thông tin danh mục
- Cấu trúc bảng `categories` và `note_categories` trong cơ sở dữ liệu

### Màu Sắc
- Sử dụng mã màu HEX để lưu trữ
- Bảng màu mặc định: trắng, đỏ, cam, vàng, xanh lá, xanh dương, tím, hồng

## Tích Hợp Với Các Module Khác
- **Quản Lý Ghi Chú**: Hiển thị và lọc ghi chú theo danh mục, màu sắc
- **UI/UX**: Áp dụng màu sắc nhất quán cho giao diện người dùng
- **Đồng Bộ**: Đồng bộ thông tin danh mục và thuộc tính tổ chức

## Tiêu Chí Hoàn Thành
- Người dùng có thể tạo, chỉnh sửa, xóa danh mục
- Người dùng có thể gán màu sắc cho ghi chú
- Người dùng có thể ghim và bỏ ghim ghi chú
- Người dùng có thể lưu trữ và khôi phục ghi chú
- Giao diện hiển thị rõ ràng trạng thái tổ chức của ghi chú

## Kiểm Thử
- Kiểm thử tạo, chỉnh sửa, xóa danh mục
- Kiểm thử gán và lọc theo màu sắc
- Kiểm thử chức năng ghim/bỏ ghim
- Kiểm thử lưu trữ/khôi phục ghi chú 