# Quyết định thiết kế

Tài liệu này ghi lại các quyết định thiết kế quan trọng trong dự án. Mỗi quyết định bao gồm ngày, vấn đề, các phương án được xem xét, phương án được chọn và lý do.

## 1. Quản lý Database Trong Dự Án - 2024-05-15

### Vấn đề

Dự án cần một cách thức quản lý database hiệu quả, tránh tình trạng tạo nhiều database trùng lặp hoặc thừa thãi, đồng thời đảm bảo việc theo dõi cấu trúc database được nhất quán.

### Phương án được xem xét

1. **Phương án A: Quản lý riêng lẻ**:

   - Ưu điểm: Linh hoạt, mỗi team có thể tự tạo và quản lý database riêng
   - Nhược điểm: Dễ dẫn đến trùng lặp, khó kiểm soát, thiếu nhất quán

2. **Phương án B: Sử dụng ORM tự động migrations**:

   - Ưu điểm: Tự động hóa cao, dễ theo dõi thay đổi
   - Nhược điểm: Phức tạp khi cần tích hợp với hệ thống hiện có, yêu cầu cài đặt framework

3. **Phương án C: Tập trung tất cả schema vào file db-schema.sql**:
   - Ưu điểm: Dễ theo dõi, kiểm soát tập trung, rõ ràng
   - Nhược điểm: Có thể trở nên lớn theo thời gian, cần quy trình để đảm bảo cập nhật

### Quyết định

**Phương án được chọn**: Phương án C - Tập trung tất cả schema vào file db-schema.sql

### Lý do

Phương án C được chọn vì:

- Tạo ra một nguồn thông tin duy nhất về cấu trúc database trong dự án
- Giúp các thành viên team dễ dàng xem xét và hiểu cấu trúc hiện tại
- Đơn giản, không yêu cầu framework hay công cụ phức tạp
- Dễ dàng tích hợp vào quy trình làm việc hiện tại
- Giúp tránh tình trạng tạo database trùng lặp

### Tác động

- Mọi developer phải tuân thủ quy trình kiểm tra db-schema.sql trước khi tạo database mới
- Cần cập nhật file db-schema.sql sau mỗi thay đổi cấu trúc database
- Giảm thiểu được số lượng database thừa thãi
- Tạo ra tài liệu rõ ràng về cấu trúc database cho toàn dự án

## 2. Áp Dụng Cấu Trúc Tài Liệu "6 Docs" - 2024-05-24

### Vấn đề

Dự án cần một cách tiếp cận có cấu trúc hơn để tạo tài liệu hiệu quả, đặc biệt khi làm việc với AI như Cursor, nhằm giảm thiểu AI hallucination và tăng cường hiệu quả phát triển.

### Phương án được xem xét

1. **Phương án A: Tiếp tục sử dụng cấu trúc tài liệu hiện tại**:

   - Ưu điểm: Quen thuộc, không cần thay đổi quy trình hiện tại
   - Nhược điểm: Tài liệu phân tán, thiếu cấu trúc rõ ràng, không tối ưu cho AI

2. **Phương án B: Sử dụng cấu trúc DDD (Domain-Driven Design) cho tài liệu**:

   - Ưu điểm: Tập trung vào domain, phù hợp với các dự án phức tạp
   - Nhược điểm: Có thể quá phức tạp cho các dự án nhỏ, khó triển khai nhất quán

3. **Phương án C: Áp dụng cấu trúc "6 Docs"**:
   - Ưu điểm: Được thiết kế đặc biệt để làm việc với AI, giảm hallucination, cấu trúc rõ ràng từ tổng quan đến chi tiết
   - Nhược điểm: Yêu cầu thời gian ban đầu để tạo đủ 6 tài liệu, cần đào tạo team về cấu trúc mới

### Quyết định

**Phương án được chọn**: Phương án C - Áp dụng cấu trúc "6 Docs"

### Lý do

Phương án C được chọn vì:

- Cấu trúc "6 Docs" được thiết kế đặc biệt để giảm thiểu AI hallucination
- Cung cấp framework rõ ràng cho việc tạo tài liệu: từ PRD → App Flow → Tech Stack → Frontend/Backend → Implementation
- Phù hợp với quy trình phát triển dự án từ ý tưởng đến triển khai
- Tối ưu cho việc làm việc với Cursor và các AI coding assistants khác
- Dễ dàng theo dõi tiến độ và trạng thái dự án

### Tác động

- Tạo thư mục docs/ để lưu trữ các tài liệu theo cấu trúc mới
- Phát triển templates cho 6 tài liệu chính
- Cập nhật quy trình làm việc để bao gồm việc tạo và duy trì các tài liệu này
- Tạo hướng dẫn chuyển đổi cho các dự án hiện có
- Nâng cấp phiên bản lên 2.0.0 để phản ánh thay đổi quan trọng này

## 3. Áp Dụng Tính Cách Ngẫu Nhiên Cho Dự Án - 2024-05-25

### Vấn đề

Khi làm việc với nhiều dự án, người dùng cần một cách nhanh chóng để phân biệt và nhận diện các dự án khi lướt qua lịch sử hội thoại. Ngoài ra, việc làm việc với AI có thể trở nên đơn điệu theo thời gian.

### Phương án được xem xét

1. **Phương án A: Sử dụng màu sắc hoặc icon khác nhau**:

   - Ưu điểm: Nhận diện trực quan, dễ triển khai
   - Nhược điểm: Chỉ tác động đến giao diện, không tạo trải nghiệm tương tác khác biệt

2. **Phương án B: Tạo theme riêng cho mỗi dự án**:

   - Ưu điểm: Nhận diện mạnh mẽ thông qua giao diện
   - Nhược điểm: Phức tạp để triển khai, tập trung vào thay đổi giao diện không phải trải nghiệm

3. **Phương án C: Gán tính cách ngẫu nhiên cho AI trong mỗi dự án**:
   - Ưu điểm: Tạo trải nghiệm thú vị, giúp nhận diện dự án qua giọng điệu, không ảnh hưởng đến chất lượng code
   - Nhược điểm: Có thể gây phân tâm nếu tính cách quá mạnh, cần cân bằng giữa tính chuyên nghiệp và thú vị

### Quyết định

**Phương án được chọn**: Phương án C - Gán tính cách ngẫu nhiên cho AI trong mỗi dự án

### Lý do

Phương án C được chọn vì:

- Tạo trải nghiệm làm việc thú vị và giảm sự đơn điệu khi tương tác với AI
- Giúp dễ dàng nhận diện dự án khi lướt qua các cuộc hội thoại
- Không ảnh hưởng đến chất lượng code hoặc tài liệu, chỉ ảnh hưởng đến giọng điệu trong hội thoại
- Cho phép người dùng thay đổi tính cách nếu không phù hợp
- Trọng số cao cho tính cách "Tuổi Teen" đáp ứng yêu cầu của người dùng

### Tác động

- Tạo file project-personality-generator.mdc để quản lý các tính cách
- Cập nhật quy trình tạo dự án và nâng cấp dự án để bao gồm bước chọn tính cách
- Lưu trữ tính cách được chọn trong file `.project-personality` để duy trì nhất quán
- Điều chỉnh cách AI tương tác trong các cuộc hội thoại dựa trên tính cách được chọn
- Người dùng có thể yêu cầu thay đổi tính cách nếu muốn

## 4. Tích Hợp DALL-E Để Tạo Ảnh Vector - 2024-05-30

### Vấn đề

Dự án cần một cách tiếp cận thống nhất để tạo ra và quản lý tài nguyên hình ảnh, đặc biệt là icon và vector art, nhằm đảm bảo tính nhất quán và hiệu quả trong quy trình thiết kế.

### Phương án được xem xét

1. **Phương án A: Sử dụng thư viện icon có sẵn**:

   - Ưu điểm: Nhanh chóng, không cần phát triển, nhiều lựa chọn có sẵn
   - Nhược điểm: Thiếu tính cá nhân hóa, chi phí licenses, phụ thuộc vào nhà cung cấp

2. **Phương án B: Thuê designer tạo từng icon/illustration**:

   - Ưu điểm: Chất lượng cao, kiểm soát hoàn toàn về phong cách
   - Nhược điểm: Chi phí cao, thời gian chờ đợi lâu, khó điều chỉnh nhanh

3. **Phương án C: Tích hợp DALL-E để tạo ảnh và chuyển đổi sang vector**:
   - Ưu điểm: Tạo nhanh chóng, chi phí hợp lý, linh hoạt trong điều chỉnh, tính nhất quán cao
   - Nhược điểm: Cần tinh chỉnh prompt, kết quả có thể không hoàn hảo, cần xử lý sau khi tạo

### Quyết định

**Phương án được chọn**: Phương án C - Tích hợp DALL-E để tạo ảnh và chuyển đổi sang vector

### Lý do

Phương án C được chọn vì:

- Cho phép tạo nhanh chóng các tài nguyên hình ảnh mà không cần chờ đợi designer
- Chi phí hợp lý hơn so với thuê designer cho từng asset
- Quy trình có thể tự động hóa bằng scripts, giúp quản lý tập trung
- Dễ dàng tạo biến thể và điều chỉnh dựa trên feedback
- Đảm bảo tính nhất quán về phong cách giữa các tài nguyên
- Tận dụng công nghệ AI hiện đại để tăng hiệu quả làm việc

### Tác động

- Phát triển bộ scripts để tạo và xử lý ảnh với DALL-E API
- Thiết lập cấu trúc thư mục chuẩn để lưu trữ và quản lý tài nguyên
- Tạo quy định và hướng dẫn sử dụng DALL-E trong dự án
- Bổ sung quy trình "Tạo ảnh" và "Sửa ảnh" vào các workflow
- Tạo thư viện icon và illustration nhất quán cho dự án
- Tiết kiệm thời gian và chi phí trong quá trình phát triển UI

---

## 2. [Tên quyết định] - [Ngày]

### Vấn đề

[Mô tả vấn đề cần giải quyết]

### Phương án được xem xét

1. **Phương án A**:

   - Ưu điểm: [Liệt kê ưu điểm]
   - Nhược điểm: [Liệt kê nhược điểm]

2. **Phương án B**:
   - Ưu điểm: [Liệt kê ưu điểm]
   - Nhược điểm: [Liệt kê nhược điểm]

### Quyết định

**Phương án được chọn**: [Tên phương án]

### Lý do

[Giải thích lý do chọn phương án này so với các phương án khác]

### Tác động

[Mô tả tác động của quyết định này đến dự án]
