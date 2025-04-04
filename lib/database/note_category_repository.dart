import 'package:newnoteapp/database/database_helper.dart';
import 'package:newnoteapp/models/note_category.dart';
import 'package:uuid/uuid.dart';

class NoteCategoryRepository {
  final DatabaseHelper _databaseHelper;
  final _uuid = Uuid();

  NoteCategoryRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // Tạo liên kết giữa note và category
  Future<NoteCategory> create(String noteId, String categoryId) async {
    final db = await _databaseHelper.database;
    
    // Kiểm tra xem liên kết đã tồn tại chưa
    final existing = await db.query(
      'note_categories',
      where: 'note_id = ? AND category_id = ?',
      whereArgs: [noteId, categoryId],
    );
    
    if (existing.isNotEmpty) {
      return NoteCategory.fromMap(existing.first);
    }
    
    final noteCategory = NoteCategory(
      id: _uuid.v4(),
      noteId: noteId,
      categoryId: categoryId,
    );
    
    await db.insert('note_categories', noteCategory.toMap());
    return noteCategory;
  }

  // Xóa liên kết giữa note và category
  Future<int> delete(String noteId, String categoryId) async {
    final db = await _databaseHelper.database;
    
    return await db.delete(
      'note_categories',
      where: 'note_id = ? AND category_id = ?',
      whereArgs: [noteId, categoryId],
    );
  }

  // Xóa tất cả liên kết của một note
  Future<int> deleteAllForNote(String noteId) async {
    final db = await _databaseHelper.database;
    
    return await db.delete(
      'note_categories',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  // Xóa tất cả liên kết của một category
  Future<int> deleteAllForCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    
    return await db.delete(
      'note_categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  // Lấy tất cả liên kết của một note
  Future<List<NoteCategory>> getAllForNote(String noteId) async {
    final db = await _databaseHelper.database;
    
    final maps = await db.query(
      'note_categories',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
    
    return maps.map((map) => NoteCategory.fromMap(map)).toList();
  }

  // Lấy tất cả liên kết của một category
  Future<List<NoteCategory>> getAllForCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    
    final maps = await db.query(
      'note_categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    
    return maps.map((map) => NoteCategory.fromMap(map)).toList();
  }

  // Đếm số lượng note trong một category
  Future<int> countNotesInCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM note_categories nc
      JOIN notes n ON nc.note_id = n.id
      WHERE nc.category_id = ? AND n.is_deleted = 0
    ''', [categoryId]);
    
    return result.first['count'] as int;
  }

  // Kiểm tra xem note có thuộc category hay không
  Future<bool> isNoteInCategory(String noteId, String categoryId) async {
    final db = await _databaseHelper.database;
    
    final maps = await db.query(
      'note_categories',
      where: 'note_id = ? AND category_id = ?',
      whereArgs: [noteId, categoryId],
    );
    
    return maps.isNotEmpty;
  }

  // Cập nhật tất cả category của note
  Future<void> updateNoteCategories(String noteId, List<String> categoryIds) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Xóa tất cả liên kết hiện tại
      await txn.delete(
        'note_categories',
        where: 'note_id = ?',
        whereArgs: [noteId],
      );
      
      // Thêm lại các liên kết mới
      for (final categoryId in categoryIds) {
        final noteCategory = NoteCategory(
          id: _uuid.v4(),
          noteId: noteId,
          categoryId: categoryId,
        );
        
        await txn.insert('note_categories', noteCategory.toMap());
      }
    });
  }
} 