# Hướng Dẫn Module: UI/UX

## Tổng Quan
Module này xác định giao diện người dùng và trải nghiệm tương tác của ứng dụng. Mục tiêu là tạo ra giao diện tối giản, dễ sử dụng nhưng hiệu quả để người dùng có thể quản lý ghi chú một cách trực quan.

## Tính Năng Chi Tiết

### 1. Giao Diện Tối Giản ❌
- **Mô tả**: Thiết kế giao diện sạch sẽ, tập trung vào nội dung
- **Yêu cầu**:
  - Sử dụng Material Design 3 (Material You)
  - Bố cục rõ ràng, không quá nhiều phần tử trên một màn hình
  - Tối đa hóa không gian cho nội dung ghi chú
  - Thanh công cụ và menu trực quan, dễ tiếp cận

### 2. Chế Độ Sáng/Tối ❌
- **Mô tả**: Cho phép người dùng chọn giữa chế độ sáng và tối
- **Yêu cầu**:
  - Chế độ sáng và tối được thiết kế đồng bộ
  - Tự động theo cài đặt hệ thống hoặc cho phép chọn thủ công
  - Chuyển đổi mượt mà giữa các chế độ
  - Lưu trữ tùy chọn người dùng

### 3. Xem Dạng Danh Sách/Lưới ❌
- **Mô tả**: Cho phép người dùng chọn cách hiển thị ghi chú
- **Yêu cầu**:
  - Xem dạng danh sách: hiển thị tiêu đề, trích đoạn nội dung và thời gian
  - Xem dạng lưới: hiển thị các ghi chú dạng thẻ với màu sắc
  - Lưu trữ tùy chọn hiển thị của người dùng
  - Chuyển đổi dễ dàng giữa các chế độ xem

### 4. Thao Tác Vuốt Nhanh ❌
- **Mô tả**: Sử dụng cử chỉ vuốt để thực hiện các hành động nhanh
- **Yêu cầu**:
  - Vuốt sang trái: hiển thị tùy chọn xóa
  - Vuốt sang phải: hiển thị tùy chọn ghim/lưu trữ
  - Hỗ trợ thao tác vuốt đa hướng
  - Hiệu ứng phản hồi trực quan khi vuốt

## Màn Hình Chính

### 1. Màn Hình Danh Sách Ghi Chú ❌
- **Mô tả**: Màn hình chính hiển thị tất cả ghi chú
- **Yêu cầu**:
  - Thanh tìm kiếm ở trên cùng
  - Danh sách/lưới ghi chú
  - Nút tạo ghi chú (+) ở góc dưới phải
  - Menu điều hướng (drawer) hoặc bottom navigation
  - Hiển thị ghi chú đã ghim ở đầu

### 2. Màn Hình Chi Tiết Ghi Chú ❌
- **Mô tả**: Màn hình xem và chỉnh sửa ghi chú
- **Yêu cầu**:
  - Trường tiêu đề và nội dung
  - Thanh công cụ định dạng
  - Tùy chọn màu sắc, danh mục
  - Hiển thị thời gian tạo/chỉnh sửa
  - Nút lưu/quay lại

### 3. Màn Hình Cài Đặt ❌
- **Mô tả**: Màn hình quản lý các tùy chọn ứng dụng
- **Yêu cầu**:
  - Cài đặt giao diện (chế độ sáng/tối, kiểu hiển thị)
  - Cài đặt đồng bộ
  - Tùy chọn sao lưu/khôi phục
  - Giới thiệu và trợ giúp

## Design System

### 1. Bảng Màu
- **Màu chính (Primary)**: #2196F3 (Blue 500)
- **Màu phụ (Secondary)**: #FFC107 (Amber 500)
- **Màu nền sáng**: #FFFFFF
- **Màu nền tối**: #121212
- **Màu văn bản sáng**: #212121 (Gray 900)
- **Màu văn bản tối**: #FFFFFF

### 2. Typography
- **Tiêu đề lớn**: Roboto, 24sp, Bold
- **Tiêu đề**: Roboto, 20sp, Medium
- **Tiêu đề nhỏ**: Roboto, 16sp, Medium
- **Nội dung**: Roboto, 14sp, Regular
- **Chú thích**: Roboto, 12sp, Regular

### 3. Thành Phần UI
- **Button**: Rounded corners (8dp), with touch ripple
- **Card**: Rounded corners (12dp), subtle elevation
- **Input field**: Underline style with floating label
- **Dialog**: Centered, rounded corners (16dp)

## Luồng Điều Hướng
1. **Splash Screen** → **Màn hình chính**
2. **Màn hình chính** → **Tạo ghi chú** → **Màn hình chính**
3. **Màn hình chính** → **Chi tiết ghi chú** → **Màn hình chính**
4. **Màn hình chính** → **Menu** → **Cài đặt/Lưu trữ/Danh mục**

## Hiệu Ứng Và Animation
- Chuyển cảnh mượt mà giữa các màn hình (shared element transitions)
- Hiệu ứng ripple khi nhấn các phần tử
- Animation khi thêm/xóa ghi chú
- Animation khi chuyển đổi giữa dạng danh sách và lưới

## Tương Thích
- Hỗ trợ các kích thước màn hình khác nhau (điện thoại, máy tính bảng)
- Hỗ trợ chế độ ngang/dọc
- Tuân thủ các nguyên tắc Material Design
- Hỗ trợ các tính năng hỗ trợ tiếp cận (accessibility)

## Tích Hợp Với Các Module Khác
- **Quản Lý Ghi Chú**: Hiển thị và tương tác với dữ liệu ghi chú
- **Tổ Chức**: Hiển thị trạng thái tổ chức (danh mục, màu sắc, ghim)
- **Quảng Cáo**: Tích hợp UI cho quảng cáo một cách tinh tế

## Tiêu Chí Hoàn Thành
- Giao diện đồng nhất và thân thiện với người dùng
- Hiệu suất mượt mà, không lag khi chuyển cảnh
- Hỗ trợ đầy đủ các tương tác người dùng (vuốt, nhấn giữ, kéo thả)
- Tương thích với các kích thước màn hình khác nhau
- Chế độ sáng/tối hoạt động chính xác

## Kiểm Thử
- Kiểm thử trên các thiết bị khác nhau
- Kiểm thử hiệu suất UI khi có nhiều ghi chú
- Kiểm thử khả năng tiếp cận
- Kiểm thử người dùng thực tế để thu thập phản hồi 