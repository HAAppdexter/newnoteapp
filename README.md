# Base AI Project for Cursor

Đây là base project để sử dụng với Cursor - trợ lý AI IDE mạnh mẽ. Dự án này cung cấp cấu trúc chuẩn và các rule AI được tối ưu hóa để làm việc hiệu quả với mọi loại dự án.

Version 2.0.0

## Cấu Trúc Tài Liệu "6 Docs"

Dự án này sử dụng cấu trúc tài liệu "6 Docs" được thiết kế đặc biệt để giảm thiểu AI hallucination và tối ưu hóa quá trình phát triển phần mềm:

```
docs/
├── 1-PRD.md               # Project Requirements Doc
├── 2-AppFlow.md           # App Flow Doc
├── 3-TechStack.md         # Tech Stack Doc
├── 4-FrontendGuidelines.md # Frontend Guidelines
├── 5-BackendStructure.md  # Backend Structure Doc
└── 6-ImplementationPlan.md # Implementation Plan
```

Xem thêm chi tiết tại [docs/README.md](docs/README.md)

## Hệ Thống Lưu Trữ Kinh Nghiệm

Dự án này tích hợp hệ thống lưu trữ kinh nghiệm để ghi lại và học hỏi từ quá trình phát triển:

```
experiences/
├── frontend/            # Kinh nghiệm về frontend
├── backend/             # Kinh nghiệm về backend
├── mobile/              # Kinh nghiệm mobile development
├── devops/              # DevOps, CI/CD, infrastructure
├── testing/             # QA, testing strategies
├── ai/                  # AI-related experiences
├── common/              # Vấn đề chung (workflow, tools)
└── index.md             # Tổng hợp tất cả kinh nghiệm
```

Hệ thống này giúp:

- Lưu trữ cách giải quyết vấn đề một cách có cấu trúc
- Giảm thời gian giải quyết vấn đề tương tự trong tương lai
- Học hỏi từ cả thành công và thất bại
- Tích hợp với quy trình phát triển hiện có

Xem thêm chi tiết tại [experiences/README.md](experiences/README.md) và [experience-system-workflow.mdc](.cursor/rules/experience-system-workflow.mdc)

## Tính Cách AI

Mỗi dự án được gán một "tính cách AI" ngẫu nhiên, giúp tăng tính thú vị khi làm việc và dễ dàng nhận diện các dự án khi lướt qua lịch sử hội thoại:

- **11 tính cách khác nhau**: Tuổi Teen, Hài Hước, Nghiêm Túc, Nhiệt Tình, Trầm Tĩnh, Điên Rồ, Triết Gia, Võ Sĩ, Nhà Thơ, Người Già, Siêu Nhân
- **Trọng số ưu tiên**: Tính cách Tuổi Teen được ưu tiên cao nhất
- **Chỉ ảnh hưởng đến giao tiếp**: Tính cách chỉ ảnh hưởng đến giọng điệu trong hội thoại, không ảnh hưởng đến chất lượng code

Xem thêm chi tiết tại [project-personality-generator.mdc](project-personality-generator.mdc)

## Tùy chỉnh workspace

1. Chỉnh sửa file `Base-AI-Project.code-workspace`:

   - Đổi tên "Base-AI-Project" thành tên dự án của bạn
   - Tùy chỉnh màu sắc theme để phân biệt giữa các dự án

2. Đổi tên file workspace:

```bash
mv Base-AI-Project.code-workspace MyProject.code-workspace
```

## Quy trình làm việc

### Quy Trình Tạo Dự Án Mới

Dự án này cung cấp quy trình đầy đủ để tạo một dự án mới từ đầu:

1. **Brainstorming** - Thảo luận ý tưởng và yêu cầu dự án
2. **Thiết lập tài liệu "6 Docs"** - Tạo các tài liệu theo template
3. **Xây dựng dự án** - Theo Implementation Plan đã định nghĩa
4. **Kiểm thử và triển khai** - Đảm bảo chất lượng và triển khai

Xem đầy đủ quy trình tại: [project-creation-workflow.mdc](project-creation-workflow.mdc)

### Quy Trình Nâng Cấp Dự Án

Nếu bạn muốn áp dụng cấu trúc "6 Docs" cho dự án hiện tại:

1. **Phân tích dự án hiện tại** - Rà soát codebase và tài liệu
2. **Backup tài liệu** - Đảm bảo an toàn dữ liệu
3. **Chuyển đổi tài liệu** - Chuyển sang cấu trúc "6 Docs"
4. **Tiếp tục phát triển** - Theo quy trình mới

Xem đầy đủ quy trình tại: [project-upgrade-workflow.mdc](project-upgrade-workflow.mdc)

## Templates & Hướng Dẫn

Dự án cung cấp templates đầy đủ cho cấu trúc "6 Docs":

- [1-PRD-template.md](docs/templates/1-PRD-template.md)
- [2-AppFlow-template.md](docs/templates/2-AppFlow-template.md)
- [3-TechStack-template.md](docs/templates/3-TechStack-template.md)
- [4-FrontendGuidelines-template.md](docs/templates/4-FrontendGuidelines-template.md)
- [5-BackendStructure-template.md](docs/templates/5-BackendStructure-template.md)
- [6-ImplementationPlan-template.md](docs/templates/6-ImplementationPlan-template.md)

## Tài Liệu Tham Khảo

- [Decisions.md](Decisions.md): Các quyết định thiết kế quan trọng
- [Changelog.md](Changelog.md): Lịch sử thay đổi
- [Codebase.md](Codebase.md): Tổng quan về cấu trúc code
