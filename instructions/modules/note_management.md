# Hướng Dẫn Module: Quản Lý Ghi Chú

## Tổng Quan
Module này xử lý tất cả các chức năng liên quan đến việc tạo, chỉnh sửa, xóa và quản lý ghi chú. Đây là module cốt lõi của ứng dụng.

## Tính Năng Chi Tiết

### 1. Tạo Ghi Chú Mới ❌
- **Mô tả**: Cho phép người dùng tạo ghi chú mới với tiêu đề và nội dung
- **Yêu cầu**:
  - Giao diện tạo ghi chú đơn giản, trực quan
  - Tiêu đề tối đa 100 ký tự
  - Nội dung không giới hạn độ dài
  - Tự động lưu khi người dùng thoát
  - Hỗ trợ Markdown cơ bản

### 2. Chỉnh Sửa Ghi Chú ❌
- **Mô tả**: Cho phép người dùng chỉnh sửa ghi chú đã tạo
- **Yêu cầu**:
  - Tự động lưu khi người dùng thoát
  - Hiển thị thời gian chỉnh sửa gần nhất
  - Hỗ trợ hoàn tác (undo) và làm lại (redo)

### 3. Xóa Ghi Chú ❌
- **Mô tả**: Cho phép người dùng xóa ghi chú
- **Yêu cầu**:
  - Xác nhận trước khi xóa
  - Hỗ trợ khôi phục ghi chú đã xóa trong 30 ngày
  - Xóa vĩnh viễn sau 30 ngày

### 4. Định Dạng Văn Bản ❌
- **Mô tả**: Hỗ trợ định dạng văn bản cơ bản
- **Yêu cầu**:
  - Hỗ trợ văn bản đậm, nghiêng, gạch chân
  - Hỗ trợ danh sách có thứ tự và không thứ tự
  - Hỗ trợ tiêu đề (H1, H2, H3)
  - Hỗ trợ định dạng code (code block)

### 5. Tìm Kiếm Ghi Chú ❌
- **Mô tả**: Cho phép người dùng tìm kiếm ghi chú
- **Yêu cầu**:
  - Tìm kiếm theo tiêu đề và nội dung
  - Hiển thị kết quả tìm kiếm khi gõ (real-time)
  - Hỗ trợ lọc kết quả tìm kiếm theo danh mục
  - Lưu lịch sử tìm kiếm

### 6. Sắp Xếp Ghi Chú ❌
- **Mô tả**: Cho phép người dùng sắp xếp ghi chú
- **Yêu cầu**:
  - Sắp xếp theo thời gian tạo (mới nhất/cũ nhất)
  - Sắp xếp theo thời gian chỉnh sửa (mới nhất/cũ nhất)
  - Sắp xếp theo tiêu đề (A-Z/Z-A)
  - Sắp xếp theo danh mục

## Luồng Hoạt Động

### Tạo Ghi Chú Mới
1. Người dùng nhấn nút "+" để tạo ghi chú mới
2. Hiển thị màn hình tạo ghi chú với trường tiêu đề và nội dung
3. Người dùng nhập tiêu đề và nội dung
4. Người dùng nhấn nút "Lưu" hoặc thoát màn hình
5. Hệ thống lưu ghi chú và cập nhật danh sách ghi chú

### Chỉnh Sửa Ghi Chú
1. Người dùng nhấn vào ghi chú cần chỉnh sửa
2. Hiển thị màn hình chỉnh sửa ghi chú
3. Người dùng chỉnh sửa tiêu đề và nội dung
4. Người dùng nhấn nút "Lưu" hoặc thoát màn hình
5. Hệ thống cập nhật ghi chú và danh sách ghi chú

### Xóa Ghi Chú
1. Người dùng vuốt sang trái trên ghi chú hoặc nhấn nút "Xóa"
2. Hiển thị hộp thoại xác nhận xóa
3. Người dùng xác nhận xóa
4. Hệ thống đánh dấu ghi chú đã xóa (không hiển thị trong danh sách chính)
5. Ghi chú sẽ bị xóa vĩnh viễn sau 30 ngày

## Chi Tiết Kỹ Thuật

### Cấu Trúc Model
```dart
class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  String categoryId;
  String color;
  bool isPinned;
  bool isArchived;
  bool isDeleted;
  DateTime deletedAt;
}
```

### Lưu Trữ
- Sử dụng SQLite (thông qua `sqflite` package) để lưu trữ cục bộ
- Cấu trúc bảng `notes` trong cơ sở dữ liệu

### Xử Lý Định Dạng
- Sử dụng Markdown cho định dạng văn bản
- Sử dụng `flutter_markdown` package để hiển thị nội dung Markdown
- Tạo thanh công cụ định dạng đơn giản

## Tích Hợp Với Các Module Khác
- **Tổ Chức**: Tích hợp với module Danh Mục để phân loại ghi chú
- **UI/UX**: Tuân thủ design system của ứng dụng
- **Đồng Bộ**: Chuẩn bị dữ liệu cho việc đồng bộ hóa

## Tiêu Chí Hoàn Thành
- Người dùng có thể tạo, chỉnh sửa, xóa ghi chú
- Ghi chú hỗ trợ định dạng văn bản cơ bản
- Tìm kiếm ghi chú hoạt động chính xác
- Sắp xếp ghi chú theo nhiều tiêu chí khác nhau
- Dữ liệu ghi chú được lưu trữ cục bộ an toàn

## Kiểm Thử
- Kiểm thử tạo, chỉnh sửa, xóa ghi chú
- Kiểm thử tìm kiếm và sắp xếp
- Kiểm thử định dạng văn bản
- Kiểm thử lưu trữ cục bộ 