import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static const _databaseName = "notes_app.db";
  static const _databaseVersion = 1;
  
  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Khởi tạo database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }
  
  // Cấu hình FOREIGN KEY
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
  
  // Tạo các bảng
  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng note
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        deleted_at INTEGER,
        is_protected INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Tạo bảng category
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    // Tạo bảng quan hệ note-category
    await db.execute('''
      CREATE TABLE note_categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
    
    // Thêm dữ liệu mẫu
    await _insertSampleData(db);
  }
  
  // Thêm dữ liệu mẫu khi tạo database lần đầu
  Future<void> _insertSampleData(Database db) async {
    final uuid = Uuid();
    final now = DateTime.now();
    final today = now.millisecondsSinceEpoch;
    final yesterday = now.subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    final lastWeek = now.subtract(const Duration(days: 6)).millisecondsSinceEpoch;
    
    // Tạo một số danh mục mẫu
    final personalCategoryId = uuid.v4();
    final workCategoryId = uuid.v4();
    final studyCategoryId = uuid.v4();
    
    await db.insert('categories', {
      'id': personalCategoryId,
      'name': 'Cá nhân',
      'color': '#FF9E80',
      'created_at': today,
      'updated_at': today
    });
    
    await db.insert('categories', {
      'id': workCategoryId,
      'name': 'Công việc',
      'color': '#80D8FF',
      'created_at': today,
      'updated_at': today
    });
    
    await db.insert('categories', {
      'id': studyCategoryId,
      'name': 'Học tập',
      'color': '#B388FF',
      'created_at': today,
      'updated_at': today
    });
    
    // Tạo các ghi chú mẫu đa dạng loại
    
    // Ghi chú văn bản thông thường
    final textNoteId = uuid.v4();
    await db.insert('notes', {
      'id': textNoteId,
      'title': 'Ý tưởng dự án mới',
      'content': 'Xây dựng ứng dụng ghi chú với các tính năng:\n- Hỗ trợ nhiều loại nội dung\n- Phân loại và tìm kiếm\n- Đồng bộ hóa đám mây\n- Giao diện thân thiện\n- Tùy chỉnh theme',
      'color': '#FFECB3',
      'created_at': today,
      'updated_at': today,
      'is_pinned': 1,
      'is_archived': 0,
      'is_deleted': 0,
      'deleted_at': null,
      'is_protected': 0
    });
    
    await db.insert('note_categories', {
      'note_id': textNoteId,
      'category_id': workCategoryId
    });
    
    // Ghi chú danh sách công việc
    final checklistNoteId = uuid.v4();
    await db.insert('notes', {
      'id': checklistNoteId,
      'title': 'Danh sách mua sắm',
      'content': '- [x] Sữa tươi\n- [x] Trứng\n- [ ] Bánh mì\n- [ ] Rau xanh\n- [ ] Thịt gà\n- [ ] Gia vị nấu ăn',
      'color': '#E1BEE7',
      'created_at': yesterday,
      'updated_at': yesterday,
      'is_pinned': 0,
      'is_archived': 0,
      'is_deleted': 0,
      'deleted_at': null,
      'is_protected': 0
    });
    
    await db.insert('note_categories', {
      'note_id': checklistNoteId,
      'category_id': personalCategoryId
    });
    
    // Ghi chú với URL hình ảnh
    final imageNoteId = uuid.v4();
    await db.insert('notes', {
      'id': imageNoteId,
      'title': 'Địa điểm du lịch tiếp theo',
      'content': 'Đà Lạt - Thành phố sương mù\n\nNhững địa điểm cần đến:\n- Quảng trường Lâm Viên\n- Hồ Xuân Hương\n- Thung lũng Tình Yêu\n- Vườn hoa thành phố\n\nhttps://example.com/dalat.jpg',
      'color': '#B2DFDB',
      'created_at': lastWeek,
      'updated_at': yesterday,
      'is_pinned': 1,
      'is_archived': 0,
      'is_deleted': 0,
      'deleted_at': null,
      'is_protected': 0
    });
    
    // Ghi chú công việc
    final workNoteId = uuid.v4();
    await db.insert('notes', {
      'id': workNoteId,
      'title': 'Nhiệm vụ tuần tới',
      'content': '- [ ] Hoàn thành báo cáo dự án A\n- [ ] Gặp nhóm phát triển\n- [ ] Chuẩn bị slides cho buổi thuyết trình\n- [ ] Review code PR #123\n- [ ] Tham gia cuộc họp với khách hàng',
      'color': '#BBDEFB',
      'created_at': yesterday,
      'updated_at': today,
      'is_pinned': 0,
      'is_archived': 0,
      'is_deleted': 0,
      'deleted_at': null,
      'is_protected': 0
    });
    
    await db.insert('note_categories', {
      'note_id': workNoteId,
      'category_id': workCategoryId
    });
    
    // Ghi chú bài giảng
    final lectureNoteId = uuid.v4();
    await db.insert('notes', {
      'id': lectureNoteId,
      'title': 'Bài giảng: Cấu trúc dữ liệu',
      'content': 'Các cấu trúc dữ liệu cơ bản:\n1. Array (Mảng)\n2. Linked List (Danh sách liên kết)\n3. Stack (Ngăn xếp)\n4. Queue (Hàng đợi)\n5. Tree (Cây)\n6. Graph (Đồ thị)\n7. Hash Table (Bảng băm)\n\nCần tìm hiểu thêm về độ phức tạp của thuật toán và cách triển khai trong các ngôn ngữ lập trình.\n\nhttps://example.com/data-structures.jpg',
      'color': '#C5CAE9',
      'created_at': lastWeek,
      'updated_at': lastWeek,
      'is_pinned': 0,
      'is_archived': 0,
      'is_deleted': 0,
      'deleted_at': null,
      'is_protected': 0
    });
    
    await db.insert('note_categories', {
      'note_id': lectureNoteId,
      'category_id': studyCategoryId
    });
    
    debugPrint('Inserted sample data successfully');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Phương thức giúp nâng cấp database khi cần thiết
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thực hiện upgrade lên version 2 khi cần
    }
  }
} 