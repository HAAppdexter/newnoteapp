import 'package:newnoteapp/database/database_helper.dart';
import 'package:newnoteapp/models/category.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:newnoteapp/models/note_category.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper;
  final _uuid = Uuid();

  CategoryRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // Tạo danh mục mới
  Future<Category> create(Category category) async {
    final db = await _databaseHelper.database;
    
    // Tạo ID nếu chưa có
    final categoryWithId = category.id.isEmpty
        ? Category.create(
            id: _uuid.v4(),
            name: category.name,
            color: category.color,
          )
        : category;
    
    await db.insert('categories', categoryWithId.toMap());
    return categoryWithId;
  }

  // Lấy danh mục theo ID
  Future<Category?> getById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  // Lấy tất cả danh mục
  Future<List<Category>> getAll() async {
    try {
      final db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'categories',
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  // Cập nhật danh mục
  Future<int> update(Category category) async {
    final db = await _databaseHelper.database;
    
    // Cập nhật thời gian cập nhật
    final updatedCategory = category.copyWith();
    
    return await db.update(
      'categories',
      updatedCategory.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Xóa danh mục
  Future<int> delete(String id) async {
    final db = await _databaseHelper.database;
    
    // Xóa các liên kết note_categories trước
    await db.delete(
      'note_categories',
      where: 'category_id = ?',
      whereArgs: [id],
    );
    
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Lấy tất cả notes thuộc danh mục
  Future<List<Note>> getNotesByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    
    final noteIds = await db.query(
      'note_categories',
      columns: ['note_id'],
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    
    if (noteIds.isEmpty) {
      return [];
    }
    
    final idList = noteIds.map((map) => map['note_id']).toList();
    final placeholders = List.filled(idList.length, '?').join(',');
    
    final noteMaps = await db.query(
      'notes',
      where: 'id IN ($placeholders) AND is_deleted = 0',
      whereArgs: idList,
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    
    return noteMaps.map((map) => Note.fromMap(map)).toList();
  }

  // Gán note vào danh mục
  Future<void> assignNoteToCategory(String noteId, String categoryId) async {
    final db = await _databaseHelper.database;
    
    // Kiểm tra xem liên kết đã tồn tại chưa
    final existing = await db.query(
      'note_categories',
      where: 'note_id = ? AND category_id = ?',
      whereArgs: [noteId, categoryId],
    );
    
    if (existing.isEmpty) {
      final noteCategory = NoteCategory(
        id: _uuid.v4(),
        noteId: noteId,
        categoryId: categoryId,
      );
      
      await db.insert('note_categories', noteCategory.toMap());
    }
  }

  // Xóa note khỏi danh mục
  Future<void> removeNoteFromCategory(String noteId, String categoryId) async {
    final db = await _databaseHelper.database;
    
    await db.delete(
      'note_categories',
      where: 'note_id = ? AND category_id = ?',
      whereArgs: [noteId, categoryId],
    );
  }

  // Lấy các danh mục của note
  Future<List<Category>> getCategoriesForNote(String noteId) async {
    final db = await _databaseHelper.database;
    
    final query = '''
      SELECT c.*
      FROM categories c
      JOIN note_categories nc ON c.id = nc.category_id
      WHERE nc.note_id = ?
      ORDER BY c.name ASC
    ''';
    
    final maps = await db.rawQuery(query, [noteId]);
    
    return maps.map((map) => Category.fromMap(map)).toList();
  }
  
  Future<List<Category>> getAllCategories() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'categories',
        orderBy: 'order_index ASC',
      );
      return result.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }
  
  Future<bool> reorderCategories(List<Category> categories) async {
    try {
      final db = await _databaseHelper.database;
      await db.transaction((txn) async {
        for (int i = 0; i < categories.length; i++) {
          final category = categories[i].copyWith(orderIndex: i);
          await txn.update(
            'categories',
            category.toMap(),
            where: 'id = ?',
            whereArgs: [category.id],
          );
        }
      });
      return true;
    } catch (e) {
      print('Error reordering categories: $e');
      return false;
    }
  }
} 