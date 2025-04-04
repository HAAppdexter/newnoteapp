import 'package:newnoteapp/database/database_helper.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:uuid/uuid.dart';

enum NoteFilter {
  all,
  active,
  archived,
  deleted,
  pinned,
}

enum NoteSort {
  createdNewest,
  createdOldest,
  updatedNewest,
  updatedOldest,
  titleAZ,
  titleZA,
  updatedDesc,
  updatedAsc,
  titleAsc,
  titleDesc,
}

extension NoteSortExtension on NoteSort {
  static NoteSort fromString(String value) {
    switch (value) {
      case 'updatedDesc':
        return NoteSort.updatedNewest;
      case 'updatedAsc':
        return NoteSort.updatedOldest;
      case 'titleAsc':
        return NoteSort.titleAZ;
      case 'titleDesc':
        return NoteSort.titleZA;
      default:
        return NoteSort.updatedNewest;
    }
  }
}

class NoteRepository {
  final DatabaseHelper _databaseHelper;
  final _uuid = Uuid();

  NoteRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // Tạo note mới
  Future<Note> create(Note note) async {
    final db = await _databaseHelper.database;
    
    // Tạo ID nếu chưa có
    final noteWithId = note.id.isEmpty
        ? Note.create(
            id: _uuid.v4(),
            title: note.title,
            content: note.content,
            color: note.color,
          )
        : note;
    
    await db.insert('notes', noteWithId.toMap());
    return noteWithId;
  }

  // Lấy note theo ID
  Future<Note?> getById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Lấy tất cả notes theo filter và sort
  Future<List<Note>> getAll({
    NoteFilter filter = NoteFilter.active,
    NoteSort sort = NoteSort.updatedNewest,
  }) async {
    final db = await _databaseHelper.database;

    String whereClause;
    switch (filter) {
      case NoteFilter.all:
        whereClause = 'is_deleted = 0';
        break;
      case NoteFilter.active:
        whereClause = 'is_deleted = 0 AND is_archived = 0';
        break;
      case NoteFilter.archived:
        whereClause = 'is_deleted = 0 AND is_archived = 1';
        break;
      case NoteFilter.deleted:
        whereClause = 'is_deleted = 1';
        break;
      case NoteFilter.pinned:
        whereClause = 'is_deleted = 0 AND is_pinned = 1';
        break;
    }

    String orderBy;
    switch (sort) {
      case NoteSort.createdNewest:
        orderBy = 'created_at DESC';
        break;
      case NoteSort.createdOldest:
        orderBy = 'created_at ASC';
        break;
      case NoteSort.updatedNewest:
        orderBy = 'updated_at DESC';
        break;
      case NoteSort.updatedOldest:
        orderBy = 'updated_at ASC';
        break;
      case NoteSort.titleAZ:
        orderBy = 'title ASC';
        break;
      case NoteSort.titleZA:
        orderBy = 'title DESC';
        break;
      case NoteSort.updatedDesc:
        orderBy = 'updated_at DESC';
        break;
      case NoteSort.updatedAsc:
        orderBy = 'updated_at ASC';
        break;
      case NoteSort.titleAsc:
        orderBy = 'title ASC';
        break;
      case NoteSort.titleDesc:
        orderBy = 'title DESC';
        break;
    }

    // Ghim notes luôn hiển thị đầu tiên
    orderBy = 'is_pinned DESC, $orderBy';

    final maps = await db.query(
      'notes',
      where: whereClause,
      orderBy: orderBy,
    );

    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Cập nhật note
  Future<int> update(Note note) async {
    final db = await _databaseHelper.database;
    
    // Cập nhật thời gian cập nhật
    final updatedNote = note.copyWith();
    
    return await db.update(
      'notes',
      updatedNote.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Đánh dấu note là đã xóa (soft delete)
  Future<int> delete(String id) async {
    final db = await _databaseHelper.database;
    
    return await db.update(
      'notes',
      {
        'is_deleted': 1,
        'deleted_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Xóa note vĩnh viễn
  Future<int> permanentDelete(String id) async {
    final db = await _databaseHelper.database;
    
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Khôi phục note đã xóa
  Future<int> restore(String id) async {
    final db = await _databaseHelper.database;
    
    return await db.update(
      'notes',
      {
        'is_deleted': 0,
        'deleted_at': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tìm kiếm notes
  Future<List<Note>> search(String query) async {
    final db = await _databaseHelper.database;
    
    // Tìm kiếm trong tiêu đề và nội dung, loại trừ notes đã xóa
    final maps = await db.query(
      'notes',
      where: 'is_deleted = 0 AND (title LIKE ? OR content LIKE ?)',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'is_pinned DESC, updated_at DESC',
    );

    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Ghim/bỏ ghim note
  Future<int> togglePin(String id, bool isPinned) async {
    final db = await _databaseHelper.database;
    
    return await db.update(
      'notes',
      {
        'is_pinned': isPinned ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Lưu trữ/bỏ lưu trữ note
  Future<int> toggleArchive(String id, bool isArchived) async {
    final db = await _databaseHelper.database;
    
    return await db.update(
      'notes',
      {
        'is_archived': isArchived ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Bảo vệ/bỏ bảo vệ note
  Future<int> toggleProtect(String id, bool isProtected) async {
    final db = await _databaseHelper.database;
    
    return await db.update(
      'notes',
      {
        'is_protected': isProtected ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 