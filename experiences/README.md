# Hệ Thống Lưu Trữ Kinh Nghiệm

Thư mục này chứa các kinh nghiệm được ghi lại từ quá trình phát triển dự án. Mỗi kinh nghiệm là một bài học quý giá giúp team giải quyết các vấn đề tương tự trong tương lai nhanh chóng và hiệu quả hơn.

## Mục Đích

- Lưu trữ kinh nghiệm giải quyết vấn đề một cách có cấu trúc
- Giúp thành viên mới học hỏi từ kinh nghiệm của team
- Giảm thời gian giải quyết vấn đề tương tự
- Tránh lặp lại các sai lầm đã từng mắc phải

## Cách Sử Dụng

### Tìm Kiếm Kinh Nghiệm

1. Truy cập file `index.md` để xem tổng quan các kinh nghiệm
2. Tìm kiếm theo các category đã được phân loại
3. Sử dụng tính năng tìm kiếm với tags (format: #tag)
4. Tham khảo kinh nghiệm phù hợp trước khi bắt đầu giải quyết vấn đề mới

### Thêm Kinh Nghiệm Mới

1. Xác định vấn đề đáng để lưu trữ (đặc biệt là vấn đề khó, tốn thời gian giải quyết)
2. Tạo file mới trong thư mục phù hợp theo định dạng: `EXP-XXX-YYYYMMDD-short-description.md`
3. Sử dụng template sẵn có trong file [experience-system-workflow.mdc](../.cursor/rules/experience-system-workflow.mdc)
4. Điền đầy đủ thông tin theo template
5. Cập nhật file `index.md` để thêm kinh nghiệm mới vào danh sách

## Cấu Trúc Thư Mục

```
experiences/
├── frontend/            # Kinh nghiệm về frontend
│   ├── react/           # React specific
│   ├── vue/             # Vue specific
│   └── general/         # General frontend
├── backend/             # Kinh nghiệm về backend
│   ├── node/            # Node.js specific
│   ├── python/          # Python specific
│   └── databases/       # Database related
├── mobile/              # Kinh nghiệm mobile development
├── devops/              # CI/CD, deployment, infrastructure
├── testing/             # QA, testing strategies
├── ai/                  # AI-related experiences
├── common/              # Vấn đề chung (workflow, tools, etc)
├── resources/           # Tài nguyên liên quan đến kinh nghiệm
├── index.md             # File index tổng hợp tất cả kinh nghiệm
└── README.md            # File này
```

## Nguyên Tắc Viết Kinh Nghiệm

1. **Rõ ràng**: Mô tả vấn đề và giải pháp một cách rõ ràng, dễ hiểu
2. **Đầy đủ**: Ghi lại cả giải pháp thành công và thất bại
3. **Ngắn gọn**: Giữ nội dung súc tích, tránh quá dài dòng
4. **Tối ưu cho AI**: Tuân thủ quy tắc markdown tối ưu cho Cursor AI:
   - File dưới 250 dòng
   - Code snippets ngắn gọn
   - Cấu trúc rõ ràng với headings

## Quy Trình Review

- Mỗi 3 tháng, team sẽ review lại hệ thống kinh nghiệm
- Cập nhật các kinh nghiệm lỗi thời
- Xem xét cải thiện cấu trúc và cách phân loại
- Đánh giá hiệu quả của việc áp dụng kinh nghiệm trong dự án

## Quy Tắc Bảo Vệ

- **KHÔNG** xóa kinh nghiệm đã lưu trữ
- Chỉ cập nhật hoặc đánh dấu kinh nghiệm là lỗi thời nếu cần
- Backup toàn bộ thư mục `experiences/` trước khi thực hiện thay đổi lớn
- Tuân thủ quy tắc trong [file-protection-rules.mdc](../.cursor/rules/file-protection-rules.mdc)
