# Công Cụ Quản Lý Backup

Bộ công cụ này giúp quản lý việc backup file thay vì xóa trực tiếp, đề phòng phát sinh vấn đề xóa nhầm hoặc cần phục hồi sau này.

## 💡 Nguyên Tắc Chung

- Thay vì xóa file trực tiếp, hãy di chuyển file vào thư mục `_backups`
- Duy trì cấu trúc thư mục khi backup để dễ dàng phục hồi
- Ghi log mỗi khi backup hoặc phục hồi file
- Nén các backup cũ để tiết kiệm không gian
- Backup là biện pháp bổ sung, không thay thế Git

## 🛠️ Các Công Cụ Có Sẵn

### 📥 backup_file.sh

Script thực hiện backup file thay vì xóa trực tiếp.

```bash
./scripts/backup_file.sh path/to/file_or_directory "Lý do xóa" "Người thực hiện"
```

**Ví dụ:**

```bash
./scripts/backup_file.sh src/components/OldButton.js "Thay thế bằng NewButton" "TrungKien"
```

### 📤 restore_file.sh

Script phục hồi file từ backup.

```bash
# Tìm kiếm file trong backup
./scripts/restore_file.sh find "tên file cần tìm"

# Phục hồi file từ backup
./scripts/restore_file.sh path/to/backup_file path/to/destination_file
```

**Ví dụ:**

```bash
# Tìm tất cả file button trong backup
./scripts/restore_file.sh find "Button"

# Phục hồi file
./scripts/restore_file.sh _backups/2024-05-10/src/components/Button.js src/components/Button.js
```

### 🧹 cleanup_backups.sh

Script dọn dẹp các backup cũ.

```bash
# Hiển thị thống kê backup
./scripts/cleanup_backups.sh --stats

# Nén backup cũ hơn 7 ngày và xóa backup cũ hơn 90 ngày
./scripts/cleanup_backups.sh --zip-older-than 7 --delete-older-than 90
```

## 📂 Cấu Trúc Thư Mục Backup

```
_backups/
  ├── backup_log.md           # File log ghi lại tất cả hoạt động backup và restore
  ├── 2024-05-10/             # Backup theo ngày
  │   └── src/components/     # Giữ nguyên cấu trúc thư mục
  │       └── Button.js
  ├── 2024-05-09/
  │   └── ...
  └── 2024-05-01.zip          # Backup cũ đã được nén lại
```

## 📝 File Log Backup

File log (`_backups/backup_log.md`) ghi lại tất cả hoạt động backup với định dạng:

```markdown
## 2024-05-10 - 15:30:45

- File: `src/components/Button.js`
- Backup: `_backups/2024-05-10/src/components/Button.js`
- Lý do: Thay thế bằng component mới
- Người thực hiện: TrungKien
```

## 💻 Tích Hợp Vào Quy Trình Làm Việc

1. **Trước khi xóa file:** Sử dụng script backup_file.sh
2. **Khi cần khôi phục file:** Sử dụng script restore_file.sh
3. **Định kỳ dọn dẹp backup:** Sử dụng script cleanup_backups.sh

## ⚠️ Lưu Ý Quan Trọng

- Thư mục `_backups` đã được thêm vào `.gitignore` để không theo dõi trong Git
- Để đánh dấu backup quan trọng, thêm từ khóa "IMPORTANT" vào log
- Backup duy trì trong 90 ngày trước khi bị xóa tự động
- Nếu file quá lớn, xem xét sử dụng Git LFS thay vì backup thông thường
