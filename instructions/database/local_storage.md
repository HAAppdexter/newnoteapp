# Hướng Dẫn Module: Database và Lưu Trữ Cục Bộ

## Tổng Quan
Module này xử lý việc lưu trữ dữ liệu cục bộ cho ứng dụng ghi chú. Mục tiêu là tạo một hệ thống lưu trữ an toàn, hiệu quả và có khả năng mở rộng để quản lý tất cả dữ liệu của ứng dụng.

## Tính Năng Chi Tiết

### 1. Thiết Kế Schema Database ❌
- **Mô tả**: Thiết kế cấu trúc cơ sở dữ liệu để lưu trữ ghi chú, danh mục và các dữ liệu liên quan
- **Yêu cầu**:
  - Sử dụng SQLite thông qua thư viện sqflite
  - Thiết kế các bảng cần thiết (notes, categories, note_categories, etc.)
  - Định nghĩa các ràng buộc và quan hệ
  - Hỗ trợ migration khi cần nâng cấp schema

### 2. Cài Đặt Data Access Layer ❌
- **Mô tả**: Tạo lớp truy cập dữ liệu để thao tác với database
- **Yêu cầu**:
  - Tạo các phương thức CRUD (Create, Read, Update, Delete)
  - Hỗ trợ truy vấn phức tạp (tìm kiếm, lọc, sắp xếp)
  - Xử lý đồng bộ hóa và concurrency
  - Xử lý lỗi và ngoại lệ

### 3. Lưu Trữ Cài Đặt Người Dùng ❌
- **Mô tả**: Lưu trữ tùy chọn và cài đặt của người dùng
- **Yêu cầu**:
  - Sử dụng SharedPreferences/UserDefaults
  - Lưu trữ các tùy chọn như chế độ giao diện, chế độ hiển thị
  - Lưu trữ trạng thái ứng dụng
  - Lưu trữ thông tin người dùng (nếu đăng nhập)

### 4. Quản Lý Cache ❌
- **Mô tả**: Tối ưu hóa hiệu suất bằng cách cache dữ liệu thường xuyên sử dụng
- **Yêu cầu**:
  - Cache ghi chú gần đây
  - Cache danh mục và cài đặt
  - Tự động làm mới cache khi dữ liệu thay đổi
  - Xử lý giới hạn bộ nhớ cache

## Luồng Hoạt Động

### Khởi Tạo Database
1. Kiểm tra database đã tồn tại chưa
2. Nếu chưa, tạo database và các bảng cần thiết
3. Nếu đã tồn tại, kiểm tra phiên bản và thực hiện migration nếu cần
4. Khởi tạo các lớp truy cập dữ liệu

### Lưu Trữ Ghi Chú
1. Khi người dùng tạo/chỉnh sửa ghi chú, tạo đối tượng Note
2. Lưu vào database thông qua data access layer
3. Cập nhật cache nếu cần
4. Thông báo cho UI để cập nhật hiển thị

### Truy Vấn Dữ Liệu
1. UI yêu cầu dữ liệu (danh sách ghi chú, tìm kiếm, etc.)
2. Kiểm tra cache trước
3. Nếu không có trong cache, truy vấn từ database
4. Cập nhật cache và trả về kết quả

### Quản Lý Cài Đặt
1. Người dùng thay đổi cài đặt (chế độ giao diện, etc.)
2. Lưu vào SharedPreferences
3. Áp dụng thay đổi ngay lập tức
4. Đọc từ SharedPreferences khi khởi động ứng dụng

## Chi Tiết Kỹ Thuật

### Schema Database

#### Bảng Notes
```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT,
  content TEXT,
  created_at INTEGER,
  updated_at INTEGER,
  color TEXT,
  is_pinned INTEGER DEFAULT 0,
  is_archived INTEGER DEFAULT 0,
  is_deleted INTEGER DEFAULT 0,
  deleted_at INTEGER,
  is_protected INTEGER DEFAULT 0
);
```

#### Bảng Categories
```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT,
  color TEXT,
  order_index INTEGER,
  created_at INTEGER,
  updated_at INTEGER
);
```

#### Bảng Note-Categories Relationship
```sql
CREATE TABLE note_categories (
  id TEXT PRIMARY KEY,
  note_id TEXT,
  category_id TEXT,
  FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);
```

### Data Access Classes

#### Database Helper
```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    // Initialize database
  }
  
  Future<void> _createDB(Database db, int version) async {
    // Create tables
  }
  
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
  }
}
```

#### Note Repository
```dart
class NoteRepository {
  final DatabaseHelper databaseHelper;
  
  NoteRepository({required this.databaseHelper});
  
  // CRUD operations
  Future<Note> create(Note note);
  Future<Note?> getById(String id);
  Future<List<Note>> getAll({NoteFilter? filter, NoteSort? sort});
  Future<int> update(Note note);
  Future<int> delete(String id);
  Future<int> permanentDelete(String id);
  Future<List<Note>> search(String query);
}
```

#### Category Repository
```dart
class CategoryRepository {
  final DatabaseHelper databaseHelper;
  
  CategoryRepository({required this.databaseHelper});
  
  // CRUD operations
  Future<Category> create(Category category);
  Future<Category?> getById(String id);
  Future<List<Category>> getAll();
  Future<int> update(Category category);
  Future<int> delete(String id);
  Future<List<Note>> getNotesByCategory(String categoryId);
}
```

### Preferences Helper
```dart
class PreferencesHelper {
  static final PreferencesHelper instance = PreferencesHelper._init();
  static SharedPreferences? _prefs;
  
  PreferencesHelper._init();
  
  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  // Theme preferences
  Future<void> setDarkMode(bool value);
  Future<bool> getDarkMode();
  
  // View preferences
  Future<void> setGridView(bool value);
  Future<bool> getGridView();
  
  // Other preferences
  // ...
}
```

### Cache Manager
```dart
class CacheManager {
  static final CacheManager instance = CacheManager._init();
  
  // In-memory cache
  final Map<String, Note> _noteCache = {};
  final Map<String, Category> _categoryCache = {};
  List<Note>? _recentNotesCache;
  
  CacheManager._init();
  
  // Cache operations
  void cacheNote(Note note);
  Note? getCachedNote(String id);
  void cacheNoteList(List<Note> notes);
  List<Note>? getCachedNoteList();
  void invalidateCache();
  void clearCache();
}
```

## Tích Hợp Với Các Module Khác
- **Quản Lý Ghi Chú**: Cung cấp lưu trữ và truy vấn dữ liệu ghi chú
- **Tổ Chức**: Lưu trữ và quản lý danh mục, thông tin tổ chức
- **UI/UX**: Lưu trữ cài đặt giao diện người dùng
- **Đồng Bộ**: Cung cấp dữ liệu cục bộ cho đồng bộ hóa lên đám mây

## Hiệu Suất và Tối Ưu
- Sử dụng chỉ mục (index) cho các trường thường xuyên tìm kiếm
- Tối ưu hóa câu truy vấn
- Sử dụng transactions cho các thao tác phức tạp
- Xử lý bất đồng bộ để không chặn UI thread
- Phân trang kết quả cho danh sách lớn

## Bảo Mật Dữ Liệu
- Dữ liệu nhạy cảm được mã hóa trước khi lưu
- Sử dụng thư viện flutter_secure_storage cho thông tin nhạy cảm
- Xác thực truy cập vào dữ liệu được bảo vệ
- Backup dữ liệu được mã hóa

## Tiêu Chí Hoàn Thành
- Database được tạo thành công và truy vấn hoạt động đúng
- Tất cả các thao tác CRUD hoạt động đúng
- Hiệu suất tốt với bộ dữ liệu lớn (>1000 ghi chú)
- Cài đặt người dùng được lưu trữ và khôi phục đúng
- Migration hoạt động đúng khi nâng cấp schema

## Kiểm Thử
- Kiểm thử unit cho các repository
- Kiểm thử hiệu suất với bộ dữ liệu lớn
- Kiểm thử migration giữa các phiên bản schema
- Kiểm thử khả năng phục hồi từ lỗi 