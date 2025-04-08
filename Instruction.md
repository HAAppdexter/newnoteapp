# Hướng Dẫn Ứng Dụng Ghi Chú

## Tổng Quan
Ứng dụng ghi chú đơn giản, cho phép người dùng tạo và quản lý ghi chú với giao diện thân thiện. Tích hợp quảng cáo AdMob để tạo doanh thu. Ứng dụng được xây dựng bằng Flutter.

## Hướng dẫn phát triển
Để phát triển ứng dụng này, hãy thực hiện từng phần theo thứ tự các modules được liệt kê dưới đây. Mỗi module có một file instruction riêng với chi tiết cụ thể.

##API 
api key và endpoint sẽ được lưu trũ trong 1 file cấu hình trong assets để dễ thay đổi

##Các thư viện tham khảo
- sử dụng tối đa các thư viện bên thứ 3 để tránh phát sinh các resource
Ví dụ: 
flutter_launcher_icons: ^0.14.3

## Cấu Trúc Ứng Dụng
- **MainActivity**: Màn hình chính hiển thị danh sách ghi chú ✅ - [Chi tiết](instructions/ui/user_interface.md#màn-hình-chính)
- **NoteActivity**: Màn hình tạo/chỉnh sửa ghi chú ✅ - [Chi tiết](instructions/ui/user_interface.md#màn-hình-chi-tiết-ghi-chú)
- **SettingsActivity**: Cài đặt ứng dụng ❌ - [Chi tiết](instructions/ui/user_interface.md#màn-hình-cài-đặt)
- **Database**: Lưu trữ ghi chú cục bộ ✅ - [Chi tiết](instructions/database/local_storage.md)

## Tính Năng Cốt Lõi
1. **Quản Lý Ghi Chú** ✅ - [Chi tiết](instructions/modules/note_management.md)
   - Tạo/Chỉnh sửa/Xóa ghi chú văn bản ✅
   - Định dạng đơn giản (đậm, nghiêng, danh sách) ❌
   - Tìm kiếm nhanh ✅
   - Sắp xếp theo thời gian ✅

2. **Tổ Chức** ✅ - [Chi tiết](instructions/modules/organization.md)
   - Danh mục ghi chú ✅
   - Gắn màu sắc ✅
   - Ghim ghi chú quan trọng ✅
   - Lưu trữ/bỏ lưu trữ ✅

3. **UI/UX** ✅ - [Chi tiết](instructions/ui/user_interface.md)
   - Giao diện tối giản ✅
   - Chế độ sáng/tối ✅
   - Xem dạng danh sách/lưới ✅
   - Thao tác vuốt nhanh ❌

4. **Đồng Bộ & Bảo Mật** ✅ - [Chi tiết](instructions/sync/data_sync.md)
   - Đồng bộ cơ bản giữa thiết bị ❌
   - Bảo vệ ghi chú bằng mật khẩu ✅
   - Sao lưu/khôi phục ❌

## Quảng Cáo AdMob - [Chi tiết](instructions/ads/admob_integration.md)

### Vị Trí Quảng Cáo ✅
- Banner ở cuối màn hình chính ✅
- Banner ở cuối màn hình cài đặt ❌
- Interstitial khi thoát ghi chú (1/5 lần) ✅
- Native ads dạng ghi chú gợi ý (tùy chọn) ❌
- Reward ads để mở khóa tính năng ✅

### Lộ Trình Quảng Cáo
1. **Giai Đoạn 1**: Banner ads ở màn hình chính ✅
2. **Giai Đoạn 2**: Thêm interstitial tần suất thấp ✅
3. **Giai Đoạn 3**: Tối ưu vị trí, thêm các loại quảng cáo khác ❌

## Trải Nghiệm Người Dùng ✅
- Hiển thị quảng cáo banner khi đang soạn thảo ✅
- Hiển thị interstitial trong 15 giây đầu tiên khi người dùng click vào button. Sau đó, cứ 60 giây khi người dùng click vào button sẽ kích hoạt quảng cáo. Nếu đang trong quá trình soạn thảo sẽ không hiện quảng cáo interstitial. ✅
- Giảm tần suất cho người dùng thường xuyên ✅

## Kiếm Tiền ❌
- Phiên bản miễn phí có quảng cáo ✅
- Phiên bản trả phí loại bỏ quảng cáo (20,000đ - 50,000đ) ❌
- Gói nâng cấp ngắn hạn qua reward ads ✅

## Lộ Trình Phát Triển
1. **MVP**: Chức năng ghi chú cơ bản, lưu trữ cục bộ ✅
   - Thiết lập cấu trúc dự án ✅
   - Cài đặt database - [Chi tiết](instructions/database/local_storage.md) ✅
   - Tạo màn hình chính và màn hình ghi chú ✅
   - Triển khai quản lý ghi chú cơ bản - [Chi tiết](instructions/modules/note_management.md) ✅

2. **v1.0**: Nâng cao tính năng cơ bản và UI ✅
   - Thêm danh mục, màu sắc - [Chi tiết](instructions/modules/organization.md) ✅
   - Tìm kiếm cơ bản - [Chi tiết](instructions/modules/note_management.md#5-tìm-kiếm-ghi-chú-) ✅
   - Cải thiện UI/UX - [Chi tiết](instructions/ui/user_interface.md) ✅
   - Thêm chế độ sáng/tối - [Chi tiết](instructions/ui/user_interface.md#2-chế-độ-sángtối-) ✅

3. **v2.0**: Tính năng nâng cao và kiếm tiền ⏳
   - Đồng bộ hóa - [Chi tiết](instructions/sync/data_sync.md) ❌
   - Ghim ghi chú, bảo mật - [Chi tiết](instructions/sync/data_sync.md#2-bảo-vệ-ghi-chú-bằng-mật-khẩu-) ✅
   - Tích hợp quảng cáo - [Chi tiết](instructions/ads/admob_integration.md) ✅
   - Thêm phiên bản trả phí ❌

## Yêu Cầu Kỹ Thuật
- Flutter SDK ✅
- Firebase (Authentication, Firestore) ✅
- SQLite (thông qua sqflite) ✅
- Google AdMob SDK ✅
- Provider/Bloc cho state management ✅

## Quy trình làm việc

1. Chọn một tính năng chưa được triển khai (đánh dấu ❌)
2. Đánh dấu tính năng đang triển khai (⏳)
3. Triển khai theo các yêu cầu chức năng trong file instruction chi tiết
4. Kiểm tra theo tiêu chí hoàn thành được định nghĩa trong mỗi module
5. Đánh dấu tính năng đã hoàn thành (✅)
6. Cập nhật Changelog.md với các thay đổi
7. Cập nhật Codebase.md với mô tả về các thành phần mới

## Thứ Tự Triển Khai Khuyến Nghị
1. Cài đặt database (instructions/database/local_storage.md) ✅
2. Quản lý ghi chú cơ bản (instructions/modules/note_management.md) ✅
3. UI/UX màn hình chính (instructions/ui/user_interface.md) ✅
4. Tổ chức ghi chú (instructions/modules/organization.md) ✅
5. Đồng bộ và bảo mật (instructions/sync/data_sync.md) ⏳
6. Tích hợp quảng cáo (instructions/ads/admob_integration.md) ✅

## Legend

- ✅ Completed
- ⏳ In Progress
- ❌ Not Started
