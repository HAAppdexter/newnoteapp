import 'package:newnoteapp/database/note_repository.dart';
import 'package:newnoteapp/database/category_repository.dart';
import 'package:newnoteapp/database/note_category_repository.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:newnoteapp/models/category.dart';
import 'package:uuid/uuid.dart';

class NoteService {
  final NoteRepository _noteRepository;
  final CategoryRepository _categoryRepository;
  final NoteCategoryRepository _noteCategoryRepository;
  final Uuid _uuid = Uuid();

  NoteService({
    required NoteRepository noteRepository,
    required CategoryRepository categoryRepository,
    required NoteCategoryRepository noteCategoryRepository,
  })  : _noteRepository = noteRepository,
        _categoryRepository = categoryRepository,
        _noteCategoryRepository = noteCategoryRepository;

  // Getters cho các repository
  NoteRepository get noteRepository => _noteRepository;
  CategoryRepository get categoryRepository => _categoryRepository;
  NoteCategoryRepository get noteCategoryRepository => _noteCategoryRepository;

  // Tạo ghi chú mới
  Future<Note> createNote({
    required String title,
    required String content,
    String color = '',
    bool isPinned = false,
    bool isProtected = false,
    List<String> categoryIds = const [],
  }) async {
    // Tạo note mới
    final note = Note.create(
      id: _uuid.v4(),
      title: title,
      content: content,
      color: color,
      isPinned: isPinned,
      isProtected: isProtected,
    );

    // Lưu vào database
    final savedNote = await _noteRepository.create(note);

    // Thêm các danh mục cho note
    if (categoryIds.isNotEmpty) {
      for (final categoryId in categoryIds) {
        await _noteCategoryRepository.create(savedNote.id, categoryId);
      }
    }

    return savedNote;
  }

  // Cập nhật ghi chú
  Future<Note?> updateNote({
    required String id,
    String? title,
    String? content,
    String? color,
    bool? isPinned,
    bool? isArchived,
    bool? isProtected,
    List<String>? categoryIds,
  }) async {
    // Lấy ghi chú hiện tại
    final currentNote = await _noteRepository.getById(id);
    if (currentNote == null) {
      return null;
    }

    // Tạo bản sao với các thông tin cập nhật
    final updatedNote = currentNote.copyWith(
      title: title,
      content: content,
      color: color,
      isPinned: isPinned,
      isArchived: isArchived,
      isProtected: isProtected,
    );

    // Cập nhật ghi chú
    await _noteRepository.update(updatedNote);

    // Cập nhật các danh mục nếu có
    if (categoryIds != null) {
      await _noteCategoryRepository.updateNoteCategories(id, categoryIds);
    }

    return updatedNote;
  }

  // Lấy chi tiết ghi chú kèm danh mục
  Future<Map<String, dynamic>> getNoteWithCategories(String noteId) async {
    final note = await _noteRepository.getById(noteId);
    if (note == null) {
      throw Exception('Note not found');
    }

    final categories = await _categoryRepository.getCategoriesForNote(noteId);

    return {
      'note': note,
      'categories': categories,
    };
  }

  // Lấy danh sách ghi chú theo bộ lọc
  Future<List<Note>> getNotes({
    NoteFilter filter = NoteFilter.all,
    NoteSort sort = NoteSort.updatedDesc,
    String categoryId = '',
  }) async {
    if (categoryId.isNotEmpty) {
      // Lấy ghi chú theo danh mục
      return await _categoryRepository.getNotesByCategory(categoryId);
    } else {
      // Lấy ghi chú theo bộ lọc
      return await _noteRepository.getAll(filter: filter, sort: sort);
    }
  }

  // Xóa ghi chú (soft delete)
  Future<bool> deleteNote(String noteId) async {
    final result = await _noteRepository.delete(noteId);
    return result > 0;
  }

  // Khôi phục ghi chú
  Future<bool> restoreNote(String noteId) async {
    final result = await _noteRepository.restore(noteId);
    return result > 0;
  }

  // Xóa vĩnh viễn ghi chú
  Future<bool> permanentlyDeleteNote(String noteId) async {
    // Xóa các liên kết với danh mục trước
    await _noteCategoryRepository.deleteAllForNote(noteId);
    
    // Xóa ghi chú
    final result = await _noteRepository.permanentDelete(noteId);
    return result > 0;
  }

  // Tìm kiếm ghi chú
  Future<List<Note>> searchNotes(String query) async {
    return await _noteRepository.search(query);
  }

  // Ghim/bỏ ghim ghi chú
  Future<bool> togglePinNote(String noteId, bool isPinned) async {
    final result = await _noteRepository.togglePin(noteId, isPinned);
    return result > 0;
  }

  // Lưu trữ/bỏ lưu trữ ghi chú
  Future<bool> toggleArchiveNote(String noteId, bool isArchived) async {
    final result = await _noteRepository.toggleArchive(noteId, isArchived);
    return result > 0;
  }

  // Bảo vệ/bỏ bảo vệ ghi chú
  Future<bool> toggleProtectNote(String noteId, bool isProtected) async {
    final result = await _noteRepository.toggleProtect(noteId, isProtected);
    return result > 0;
  }

  // Thêm ghi chú vào danh mục
  Future<void> addNoteToCategory(String noteId, String categoryId) async {
    await _noteCategoryRepository.create(noteId, categoryId);
  }

  // Xóa ghi chú khỏi danh mục
  Future<void> removeNoteFromCategory(String noteId, String categoryId) async {
    await _noteCategoryRepository.delete(noteId, categoryId);
  }

  // Đếm số ghi chú trong danh mục
  Future<int> countNotesInCategory(String categoryId) async {
    return await _noteCategoryRepository.countNotesInCategory(categoryId);
  }
  
  // Xóa danh mục
  Future<bool> deleteCategory(String categoryId) async {
    // Xóa các liên kết với note trước
    await _noteCategoryRepository.deleteAllForCategory(categoryId);
    
    // Xóa danh mục
    final result = await _categoryRepository.delete(categoryId);
    return result > 0;
  }

  // Sắp xếp lại thứ tự các danh mục
  Future<bool> reorderCategories(List<Category> categories) async {
    try {
      await _categoryRepository.reorderCategories(categories);
      return true;
    } catch (e) {
      print('Error reordering categories: $e');
      return false;
    }
  }

  // Lấy danh sách danh mục
  Future<List<Category>> getCategories() async {
    return await _categoryRepository.getAll();
  }

  // Lấy danh sách ghi chú không thuộc danh mục nào
  Future<List<Note>> getUnsortedNotes() async {
    // Lấy tất cả ghi chú (không bị xóa)
    final allNotes = await _noteRepository.getAll(filter: NoteFilter.all);
    final unsortedNotes = <Note>[];
    
    // Kiểm tra từng ghi chú
    for (final note in allNotes) {
      // Lấy danh mục của ghi chú
      final categories = await _categoryRepository.getCategoriesForNote(note.id);
      
      // Nếu không thuộc danh mục nào, thêm vào danh sách
      if (categories.isEmpty) {
        unsortedNotes.add(note);
      }
    }
    
    return unsortedNotes;
  }
} 