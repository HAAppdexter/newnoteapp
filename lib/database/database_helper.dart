import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Bảng Notes
    await db.execute('''
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
      )
    ''');

    // Bảng Categories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        color TEXT,
        order_index INTEGER,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // Bảng Note-Categories Relationship
    await db.execute('''
      CREATE TABLE note_categories (
        id TEXT PRIMARY KEY,
        note_id TEXT,
        category_id TEXT,
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Tạo danh mục mặc định
    await db.insert('categories', {
      'id': 'default',
      'name': 'Chưa phân loại',
      'color': '#5D9CEC',
      'order_index': 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
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