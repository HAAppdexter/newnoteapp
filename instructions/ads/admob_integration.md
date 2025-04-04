# Hướng Dẫn Module: Quảng Cáo AdMob

## Tổng Quan
Module này xử lý việc tích hợp và hiển thị quảng cáo AdMob trong ứng dụng. Mục tiêu là tối đa hóa doanh thu từ quảng cáo trong khi vẫn duy trì trải nghiệm người dùng tốt.

## Tính Năng Chi Tiết

### 1. Banner Ads ❌
- **Mô tả**: Hiển thị quảng cáo banner ở vị trí cố định
- **Yêu cầu**:
  - Banner ở cuối màn hình chính
  - Banner ở cuối màn hình cài đặt
  - Sử dụng Adaptive Banner cho kích thước tối ưu
  - Không hiển thị khi đang soạn thảo ghi chú
  - Hiển thị liên tục

### 2. Interstitial Ads ❌
- **Mô tả**: Hiển thị quảng cáo toàn màn hình khi thoát ghi chú
- **Yêu cầu**:
  - Hiển thị với tần suất 1/5 lần thoát ghi chú
  - Chỉ hiển thị khi người dùng đã sử dụng ứng dụng > 3 phút
  - Giới hạn tối đa 3 lần/ngày/người dùng
  - Tải trước để hiển thị mượt mà

### 3. Native Ads (Tùy Chọn) ❌
- **Mô tả**: Hiển thị quảng cáo dưới dạng ghi chú gợi ý
- **Yêu cầu**:
  - Thiết kế giống ghi chú thông thường
  - Hiển thị 1 quảng cáo sau mỗi 10 ghi chú
  - Đánh dấu rõ ràng là quảng cáo
  - Hỗ trợ ẩn quảng cáo này

### 4. Reward Ads ❌
- **Mô tả**: Hiển thị quảng cáo có thưởng để mở khóa tính năng
- **Yêu cầu**:
  - Cho phép người dùng xem quảng cáo để sử dụng tính năng cao cấp trong 24 giờ
  - Hiển thị nút xem quảng cáo tại các điểm phù hợp
  - Theo dõi thời gian hết hạn của phần thưởng
  - Hiển thị thông báo khi phần thưởng sắp hết hạn

## Lộ Trình Triển Khai

### Giai Đoạn 1: Cơ Bản ❌
- **Mô tả**: Tích hợp banner ads cơ bản
- **Yêu cầu**:
  - Tích hợp SDK AdMob
  - Hiển thị banner ads ở màn hình chính
  - Thiết lập test ads cho giai đoạn phát triển
  - Cài đặt analytics cơ bản để theo dõi

### Giai Đoạn 2: Mở Rộng ❌
- **Mô tả**: Thêm interstitial ads và tối ưu banner
- **Yêu cầu**:
  - Tích hợp interstitial ads với tần suất thấp (1/10)
  - Theo dõi tỉ lệ người dùng bỏ đi
  - Điều chỉnh vị trí banner ads
  - A/B test hiệu suất

### Giai Đoạn 3: Tối Ưu ❌
- **Mô tả**: Tối ưu hóa quảng cáo và thêm các loại mới
- **Yêu cầu**:
  - Tăng tần suất interstitial ads (1/5)
  - Thêm native ads (nếu phù hợp)
  - Triển khai reward ads
  - A/B test để tìm cấu hình tối ưu

## Luồng Hoạt Động

### Hiển Thị Banner Ads
1. Khởi tạo AdMob SDK khi ứng dụng khởi động
2. Tải và hiển thị banner ở màn hình chính
3. Ẩn banner khi người dùng vào màn hình soạn thảo
4. Hiển thị lại khi người dùng quay lại màn hình chính

### Hiển Thị Interstitial Ads
1. Tải trước interstitial ads khi ứng dụng khởi động
2. Khi người dùng thoát khỏi ghi chú, kiểm tra điều kiện:
   - Đã sử dụng ứng dụng > 3 phút
   - Không vượt quá giới hạn 3 lần/ngày
   - Random 1/5 lần
3. Nếu thỏa mãn điều kiện, hiển thị interstitial
4. Sau khi hiển thị, tải trước quảng cáo mới

### Hiển Thị Reward Ads
1. Hiển thị nút "Mở khóa tính năng" tại các tính năng cao cấp
2. Khi người dùng nhấn, hiển thị dialog giải thích
3. Khi người dùng xác nhận, hiển thị reward ad
4. Sau khi hoàn thành, cấp quyền sử dụng tính năng trong 24 giờ

## Chi Tiết Kỹ Thuật

### Khởi Tạo AdMob
```dart
class AdmobService {
  // Khởi tạo AdMob
  Future<void> initialize() {
    // Khởi tạo Mobile Ads SDK
    return MobileAds.instance.initialize();
  }
  
  // Tải banner ad
  BannerAd loadBannerAd();
  
  // Tải interstitial ad
  Future<InterstitialAd?> loadInterstitialAd();
  
  // Tải reward ad
  Future<RewardedAd?> loadRewardedAd();
}
```

### Cấu Hình AdMob
```xml
<!-- AndroidManifest.xml -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
```

```xml
<!-- Info.plist -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

### Quản Lý Tần Suất
```dart
class AdFrequencyManager {
  // Kiểm tra có nên hiển thị interstitial không
  bool shouldShowInterstitial();
  
  // Ghi nhận hiển thị quảng cáo
  void recordAdImpression(AdType type);
  
  // Kiểm tra giới hạn hàng ngày
  bool hasReachedDailyLimit(AdType type);
}
```

### Quản Lý Phần Thưởng
```dart
class RewardManager {
  // Kiểm tra tính năng đã được mở khóa chưa
  bool isFeatureUnlocked(String featureId);
  
  // Mở khóa tính năng trong thời gian xác định
  void unlockFeature(String featureId, Duration duration);
  
  // Kiểm tra thời gian còn lại
  Duration getRemainingTime(String featureId);
}
```

## Trải Nghiệm Người Dùng & Cân Bằng

### Nguyên Tắc Cân Bằng
- **Ưu tiên trải nghiệm**: Quảng cáo không được cản trở chức năng chính
- **Tôn trọng hoạt động**: Không hiển thị quảng cáo khi đang soạn thảo
- **Mức độ phù hợp**: Điều chỉnh quảng cáo theo thời gian sử dụng
- **Lựa chọn thay thế**: Cung cấp phiên bản trả phí để loại bỏ quảng cáo

### Cơ Chế Thân Thiện
- Không hiển thị interstitial ads trong 5 phút đầu khi mới cài đặt
- Không hiển thị interstitial ads khi mở lại ứng dụng sau <1 phút
- Giảm tần suất quảng cáo cho người dùng thường xuyên (>20 phút/ngày)
- Cho phép "tắt quảng cáo trong 1 giờ" sau khi xem 3 quảng cáo reward

## Chiến Lược Kiếm Tiền Kết Hợp

### Mô Hình Freemium
- **Phiên bản miễn phí**: Có quảng cáo như đã mô tả, đầy đủ tính năng cơ bản
- **Phiên bản trả phí**: Loại bỏ tất cả quảng cáo, mở khóa tính năng cao cấp
- **Giá phù hợp**: 20,000đ - 50,000đ (tùy thị trường)
- **Gói nâng cấp ngắn hạn**: Xem quảng cáo reward để loại bỏ quảng cáo 24h

## Tuân Thủ Chính Sách

### GDPR/CCPA Compliance
- Hiển thị form đồng ý trước khi hiển thị quảng cáo
- Cho phép người dùng chọn quảng cáo được cá nhân hóa/không được cá nhân hóa
- Cung cấp cài đặt quyền riêng tư
- Tuân thủ các quy định địa phương

### Chính Sách Quảng Cáo của Google
- Không hiển thị quảng cáo cho trẻ em dưới 13 tuổi
- Không đặt quảng cáo gần nút thoát/nút hành động
- Tuân thủ hướng dẫn về nội dung
- Tránh nhấp vô tình vào quảng cáo

## Tích Hợp Với Các Module Khác
- **UI/UX**: Tích hợp quảng cáo một cách tinh tế vào giao diện
- **Quản Lý Ghi Chú**: Hiển thị interstitial sau khi thoát ghi chú
- **Cài Đặt**: Tùy chọn mua phiên bản không quảng cáo

## Tiêu Chí Hoàn Thành
- Quảng cáo hiển thị đúng vị trí và tần suất
- Các quy tắc tần suất hoạt động chính xác
- Phiên bản không quảng cáo hoạt động đúng
- Reward ads cung cấp phần thưởng chính xác
- Tuân thủ các quy định về quyền riêng tư

## Kiểm Thử
- Kiểm thử hiển thị quảng cáo trên các thiết bị khác nhau
- Kiểm thử tần suất hiển thị
- Kiểm thử phần thưởng từ reward ads
- Kiểm thử loại bỏ quảng cáo khi nâng cấp
- A/B test vị trí và tần suất để tối ưu hiệu suất 