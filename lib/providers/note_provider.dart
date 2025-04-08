import 'package:flutter/material.dart';
import 'package:newnoteapp/database/database_helper.dart';
import 'package:newnoteapp/database/note_repository.dart';
import 'package:newnoteapp/database/category_repository.dart';
import 'package:newnoteapp/database/note_category_repository.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:newnoteapp/models/category.dart';
import 'package:newnoteapp/services/note_service.dart';
import 'package:newnoteapp/services/admob_service.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  NoteService? _noteService;
  AdMobService? _adMobService;
  
  List<Note> _notes = [];
  List<Category> _categories = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  NoteFilter _currentFilter = NoteFilter.all;
  NoteSort _currentSort = NoteSort.updatedNewest;
  String _selectedCategoryId = '';

  NoteProvider() {
    _initialize();
  }

  // Getters
  List<Note> get notes => _notes;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  NoteFilter get currentFilter => _currentFilter;
  NoteSort get currentSort => _currentSort;
  String get selectedCategoryId => _selectedCategoryId;
  NoteService get noteService => _noteService!;

  // Lấy các danh sách được lọc
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();
  List<Note> get unpinnedNotes => _notes.where((note) => !note.isPinned).toList();

  // Khởi tạo provider
  Future<void> _initialize() async {
    _setLoading(true);
    
    try {
      final databaseHelper = DatabaseHelper.instance;
      await databaseHelper.database;
      
      final noteRepository = NoteRepository(databaseHelper: databaseHelper);
      final categoryRepository = CategoryRepository(databaseHelper: databaseHelper);
      final noteCategoryRepository = NoteCategoryRepository(databaseHelper: databaseHelper);
      
      _noteService = NoteService(
        noteRepository: noteRepository,
        categoryRepository: categoryRepository,
        noteCategoryRepository: noteCategoryRepository,
      );
      
      _adMobService = AdMobService();
      
      await _loadNotes();
      await loadCategories();
    } catch (e) {
      print('Error initializing NoteProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Tải tất cả ghi chú
  Future<void> _loadNotes() async {
    _setLoading(true);
    
    try {
      if (_noteService == null) {
        _notes = [];
        return;
      }
      
      if (_searchQuery.isNotEmpty) {
        _notes = await _noteService!.searchNotes(_searchQuery);
      } else if (_selectedCategoryId.isNotEmpty) {
        _notes = await _noteService!.getNotes(categoryId: _selectedCategoryId);
      } else {
        _notes = await _noteService!.getNotes(filter: _currentFilter, sort: _currentSort);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading notes: $e');
      _notes = [];
    } finally {
      _setLoading(false);
    }
  }

  // Tải tất cả danh mục
  Future<void> loadCategories() async {
    try {
      _categories = await _noteService!.categoryRepository.getAll();
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // Thiết lập loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Tìm kiếm ghi chú
  Future<void> searchNotes(String query) async {
    _searchQuery = query;
    await _loadNotes();
    return;
  }

  // Xóa tìm kiếm
  Future<void> clearSearch() async {
    _searchQuery = '';
    await _loadNotes();
    return;
  }

  // Thay đổi bộ lọc
  Future<void> changeFilter(NoteFilter filter) async {
    _currentFilter = filter;
    _selectedCategoryId = '';
    await _loadNotes();
    return;
  }

  // Thay đổi sắp xếp
  Future<void> changeSort(NoteSort sort) async {
    _currentSort = sort;
    await _loadNotes();
    return;
  }

  // Chọn danh mục
  Future<void> selectCategory(String categoryId) async {
    _selectedCategoryId = categoryId;
    _currentFilter = NoteFilter.all;
    await _loadNotes();
  }

  // Xóa chọn danh mục
  Future<void> clearCategorySelection() async {
    _selectedCategoryId = '';
    await _loadNotes();
  }

  // Tạo ghi chú mới
  Future<Note> createNote({
    required String title,
    required String content,
    String color = '',
    bool isPinned = false,
    bool isProtected = false,
    List<String> categoryIds = const [],
  }) async {
    _setLoading(true);
    
    try {
      final note = await _noteService!.createNote(
        title: title,
        content: content,
        color: color,
        isPinned: isPinned,
        isProtected: isProtected,
        categoryIds: categoryIds,
      );
      
      // Hiển thị quảng cáo theo dõi hành động
      await _adMobService!.trackUserAction();
      
      await _loadNotes();
      return note;
    } finally {
      _setLoading(false);
    }
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
    _setLoading(true);
    
    try {
      final note = await _noteService!.updateNote(
        id: id,
        title: title,
        content: content,
        color: color,
        isPinned: isPinned,
        isArchived: isArchived,
        isProtected: isProtected,
        categoryIds: categoryIds,
      );
      
      await _loadNotes();
      return note;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa ghi chú (soft delete)
  Future<bool> deleteNote(String id) async {
    _setLoading(true);
    
    try {
      final result = await _noteService!.deleteNote(id);
      
      // Hiển thị quảng cáo theo dõi hành động
      await _adMobService!.trackUserAction();
      
      await _loadNotes();
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Khôi phục ghi chú
  Future<bool> restoreNote(String id) async {
    _setLoading(true);
    
    try {
      final result = await _noteService!.restoreNote(id);
      await _loadNotes();
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa vĩnh viễn ghi chú
  Future<bool> permanentlyDeleteNote(String id) async {
    _setLoading(true);
    
    try {
      final result = await _noteService!.permanentlyDeleteNote(id);
      
      // Hiển thị quảng cáo theo dõi hành động
      await _adMobService!.trackUserAction();
      
      await _loadNotes();
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle pin
  Future<void> togglePin(String id, bool isPinned) async {
    await _noteService!.togglePinNote(id, isPinned);
    await _loadNotes();
  }

  // Toggle archive
  Future<void> toggleArchive(String id, bool isArchived) async {
    await _noteService!.toggleArchiveNote(id, isArchived);
    await _loadNotes();
  }

  // Toggle protect
  Future<void> toggleProtect(String id, bool isProtected) async {
    await _noteService!.toggleProtectNote(id, isProtected);
    await _loadNotes();
  }

  // Lấy chi tiết ghi chú kèm danh mục
  Future<Map<String, dynamic>> getNoteDetails(String id) async {
    return await _noteService!.getNoteWithCategories(id);
  }

  // Tạo danh mục mới
  Future<Category> createCategory({
    required String name,
    String color = '#5D9CEC',
  }) async {
    final uuid = Uuid();
    final category = await _noteService!.categoryRepository.create(
      Category.create(
        id: uuid.v4(),
        name: name, 
        color: color, 
        orderIndex: _categories.length
      ),
    );
    
    await loadCategories();
    return category;
  }

  // Cập nhật danh mục
  Future<Category?> updateCategory({
    required String id,
    String? name,
    String? color,
  }) async {
    final currentCategory = await _noteService!.categoryRepository.getById(id);
    if (currentCategory == null) return null;
    
    final updatedCategory = currentCategory.copyWith(
      name: name,
      color: color,
    );
    
    await _noteService!.categoryRepository.update(updatedCategory);
    await loadCategories();
    
    return updatedCategory;
  }

  // Xóa danh mục
  Future<bool> deleteCategory(String id) async {
    final result = await _noteService!.categoryRepository.delete(id);
    await loadCategories();
    
    // Nếu đang chọn danh mục này, xóa lựa chọn
    if (_selectedCategoryId == id) {
      _selectedCategoryId = '';
      await _loadNotes();
    }
    
    return result > 0;
  }

  // Thay đổi thứ tự danh mục
  Future<void> reorderCategories(List<Category> orderedCategories) async {
    await _noteService!.categoryRepository.reorderCategories(orderedCategories);
    await loadCategories();
  }

  // Thêm ghi chú vào danh mục
  Future<void> addNoteToCategory(String noteId, String categoryId) async {
    await _noteService!.addNoteToCategory(noteId, categoryId);
    
    if (_selectedCategoryId.isNotEmpty) {
      await _loadNotes();
    }
  }

  // Xóa ghi chú khỏi danh mục
  Future<void> removeNoteFromCategory(String noteId, String categoryId) async {
    await _noteService!.removeNoteFromCategory(noteId, categoryId);
    
    if (_selectedCategoryId.isNotEmpty) {
      await _loadNotes();
    }
  }

  // Cập nhật các danh mục của một ghi chú
  Future<void> updateNoteCategories(String noteId, List<String> categoryIds) async {
    await _noteService!.noteCategoryRepository.updateNoteCategories(noteId, categoryIds);
    
    if (_selectedCategoryId.isNotEmpty) {
      await _loadNotes();
    }
  }

  // Đếm số ghi chú trong danh mục
  Future<int> countNotesInCategory(String categoryId) async {
    try {
      return await _noteService!.noteCategoryRepository.countNotesInCategory(categoryId);
    } catch (e) {
      print('Error counting notes in category: $e');
      return 0;
    }
  }
} 