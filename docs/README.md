# Documentation Structure Guide

Dự án này sử dụng cấu trúc tài liệu "6 Docs" để tối ưu quá trình phát triển phần mềm và giảm thiểu AI hallucination. Mỗi tài liệu có mục đích cụ thể và kết hợp với nhau tạo nên một framework toàn diện.

## Cấu Trúc 6 Tài Liệu

Cấu trúc tài liệu bao gồm 6 file chính, được sắp xếp theo thứ tự từ tổng quan đến chi tiết:

```
docs/
├── 1-PRD.md               # Project Requirements Doc
├── 2-AppFlow.md           # App Flow Doc
├── 3-TechStack.md         # Tech Stack Doc
├── 4-FrontendGuidelines.md # Frontend Guidelines
├── 5-BackendStructure.md  # Backend Structure Doc
└── 6-ImplementationPlan.md # Implementation Plan
```

## 1. Project Requirements Document (PRD)

**Mục đích**: Thiết lập nền tảng cho dự án, định nghĩa rõ ràng các yêu cầu và phạm vi.

**Nội dung chính**:

- Tổng quan ứng dụng
- User flows chính
- Tech stack & APIs dự kiến
- Tính năng cốt lõi
- Phạm vi trong/ngoài dự án

**Tại sao cần PRD**: Giúp AI hiểu rõ mục tiêu và yêu cầu của dự án, tránh tạo ra các tính năng không cần thiết hoặc không phù hợp.

## 2. App Flow Document

**Mục đích**: Mô tả chi tiết luồng ứng dụng và cách người dùng tương tác với hệ thống.

**Nội dung chính**:

- Mô tả chi tiết từng trang
- Luồng điều hướng giữa các trang
- User journey maps
- State management
- Chuyển đổi và hiệu ứng

**Tại sao cần App Flow**: Giúp AI hiểu cách ứng dụng hoạt động từ góc độ người dùng, đảm bảo trải nghiệm nhất quán.

## 3. Tech Stack Document

**Mục đích**: Xác định rõ ràng công nghệ sử dụng, ngăn chặn AI "tưởng tượng" về các công nghệ không có trong dự án.

**Nội dung chính**:

- Frontend technologies
- Backend technologies
- DevOps & infrastructure
- Third-party services & APIs
- Development environment
- Dependencies management

**Tại sao cần Tech Stack**: Giúp AI biết chính xác công nghệ cần sử dụng, tránh sử dụng thư viện hoặc framework không tồn tại trong dự án.

## 4. Frontend Guidelines

**Mục đích**: Định nghĩa hệ thống thiết kế và quy tắc frontend.

**Nội dung chính**:

- Design system (màu sắc, typography, spacing)
- Thư viện icon
- Components
- Layout & grid system
- Animation & transitions
- Responsive design
- Code conventions
- Accessibility & performance guidelines

**Tại sao cần Frontend Guidelines**: Giúp AI tạo ra giao diện nhất quán với thiết kế của dự án.

## 5. Backend Structure Document

**Mục đích**: Mô tả cấu trúc backend và data schema.

**Nội dung chính**:

- Kiến trúc tổng quan
- Database schema
- API endpoints
- Authentication & authorization
- Middleware stack
- Error handling
- Caching, background jobs, file storage
- Deployment & environments

**Tại sao cần Backend Structure**: Giúp AI hiểu cấu trúc backend để tạo code phù hợp và tương thích với hệ thống hiện có.

## 6. Implementation Plan

**Mục đích**: Cung cấp kế hoạch triển khai chi tiết, giảm thiểu sự "đoán mò" của AI.

**Nội dung chính**:

- Liệt kê 50+ bước cụ thể để xây dựng ứng dụng
- Các giai đoạn phát triển rõ ràng
- Danh sách kiểm tra (checklist) cho từng công việc
- Thứ tự thực hiện hợp lý

**Tại sao cần Implementation Plan**: Giúp AI thực thi từng bước cụ thể thay vì phải đoán các bước triển khai.

## Quy Trình Sử Dụng

1. **Tạo Dự Án Mới**: Xem [project-creation-workflow.mdc](../project-creation-workflow.mdc)
2. **Nâng Cấp Dự Án**: Xem [project-upgrade-workflow.mdc](../project-upgrade-workflow.mdc)

## Templates

Các templates cho 6 tài liệu được cung cấp trong thư mục `templates/`:

- [1-PRD-template.md](templates/1-PRD-template.md)
- [2-AppFlow-template.md](templates/2-AppFlow-template.md)
- [3-TechStack-template.md](templates/3-TechStack-template.md)
- [4-FrontendGuidelines-template.md](templates/4-FrontendGuidelines-template.md)
- [5-BackendStructure-template.md](templates/5-BackendStructure-template.md)
- [6-ImplementationPlan-template.md](templates/6-ImplementationPlan-template.md)
