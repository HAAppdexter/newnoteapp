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
  bool _isInitialized = false;
  String _searchQuery = '';
  NoteFilter _currentFilter = NoteFilter.all;
  NoteSort _currentSort = NoteSort.updatedNewest;
  String _selectedCategoryId = '';

  NoteProvider() {
    _initializeAsync();
  }

  // Getters
  List<Note> get notes => _notes;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get searchQuery => _searchQuery;
  NoteFilter get currentFilter => _currentFilter;
  NoteSort get currentSort => _currentSort;
  String get selectedCategoryId => _selectedCategoryId;
  
  // Getter với null check
  NoteService? get noteService => _noteService;

  // Lấy các danh sách được lọc
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();
  List<Note> get unpinnedNotes => _notes.where((note) => !note.isPinned).toList();

  // Khởi tạo provider bất đồng bộ
  void _initializeAsync() {
    _initialize().then((_) {
      debugPrint('NoteProvider initialization completed');
    }).catchError((e) {
      debugPrint('NoteProvider initialization failed: $e');
    });
  }

  // Khởi tạo provider
  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    
    try {
      debugPrint('Initializing NoteProvider...');
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
      debugPrint('NoteProvider services initialized successfully');
      
      // Load initial data directly from repositories
      try {
        if (_noteService != null) {
          _notes = await _noteService!.noteRepository.getAll();
          _categories = await _noteService!.categoryRepository.getAll();
          _isInitialized = true;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error loading initial data: $e');
        _notes = [];
        _categories = [];
      }
    } catch (e) {
      debugPrint('Error initializing NoteProvider: $e');
      // Ensure we don't crash if initialization fails
      _notes = [];
      _categories = [];
    } finally {
      _setLoading(false);
    }
  }

  // Thiết lập loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Tìm kiếm ghi chú - complete reimplementation
  Future<void> searchNotes(String query) async {
    if (_noteService == null) {
      debugPrint('Warning: noteService is null when searching notes');
      return;
    }
    
    _setLoading(true);
    _searchQuery = query;
    
    try {
      _notes = await _noteService!.searchNotes(query);
    } catch (e) {
      debugPrint('Error searching notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Xóa tìm kiếm - complete reimplementation
  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return; // Avoid unnecessary reload
    
    _searchQuery = '';
    await loadNotes(); // Use the public method
  }

  // Thay đổi bộ lọc - complete reimplementation
  Future<void> changeFilter(NoteFilter filter) async {
    _currentFilter = filter;
    _selectedCategoryId = '';
    await loadNotes(); // Use the public method
  }

  // Thay đổi sắp xếp - complete reimplementation
  Future<void> changeSort(NoteSort sort) async {
    _currentSort = sort;
    await loadNotes(); // Use the public method
  }

  // Chọn danh mục
  Future<void> selectCategory(String categoryId) async {
    _selectedCategoryId = categoryId;
    _currentFilter = NoteFilter.all;
    await loadNotes(); // Use the public method
  }
  
  // Xóa chọn danh mục
  Future<void> clearCategorySelection() async {
    _selectedCategoryId = '';
    await loadNotes(); // Use the public method
  }

  // Hiển thị các ghi chú không thuộc danh mục nào
  Future<void> showUnsortedNotes() async {
    if (_noteService == null) {
      debugPrint('Warning: noteService is null when trying to show unsorted notes');
      return;
    }

    _setLoading(true);
    _selectedCategoryId = '';
    
    try {
      // Lấy tất cả ghi chú không thuộc danh mục nào
      _notes = await _noteService!.getUnsortedNotes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading unsorted notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Hiển thị các ghi chú đã hoàn thành (có checklist và các mục đều đã check)
  Future<void> showCompletedNotes() async {
    if (_noteService == null) {
      debugPrint('Warning: noteService is null when trying to show completed notes');
      return;
    }

    _setLoading(true);
    _selectedCategoryId = '';
    
    try {
      // Lấy tất cả ghi chú
      final allNotes = await _noteService!.getNotes(filter: _currentFilter);
      
      // Lọc các ghi chú có nội dung dạng checklist và tất cả mục đều đã check
      _notes = allNotes.where((note) {
        // Kiểm tra có phải checklist không
        if (!_isChecklistContent(note.content)) return false;
        
        // Kiểm tra tất cả mục đã được check chưa
        return _areAllItemsChecked(note.content);
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading completed notes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper để kiểm tra nội dung có phải dạng checklist không
  bool _isChecklistContent(String content) {
    if (content.isEmpty) return false;
    
    // Tìm các dòng có dạng "- [ ]" hoặc "- [x]" hoặc "* [ ]" hoặc "* [x]"
    RegExp checklistPattern = RegExp(r'- \[[ x]\]|\* \[[ x]\]');
    List<String> lines = content.split('\n');
    
    // Nếu có ít nhất 2 dòng dạng checklist, coi là dạng danh sách
    int checklistLines = 0;
    for (String line in lines) {
      if (checklistPattern.hasMatch(line)) {
        checklistLines++;
      }
      if (checklistLines >= 2) return true;
    }
    
    return false;
  }
  
  // Helper để kiểm tra tất cả mục trong checklist đã được check chưa
  bool _areAllItemsChecked(String content) {
    // Nếu không có gì để check
    if (content.isEmpty) return false;
    
    // Pattern cho box đã check và chưa check
    RegExp uncheckedPattern = RegExp(r'- \[ \]|\* \[ \]');
    RegExp checkedPattern = RegExp(r'- \[x\]|\* \[x\]');
    
    // Đếm số lượng mục đã check và chưa check
    List<String> lines = content.split('\n');
    int uncheckedCount = 0;
    int checkedCount = 0;
    
    for (String line in lines) {
      if (uncheckedPattern.hasMatch(line)) {
        uncheckedCount++;
      } else if (checkedPattern.hasMatch(line)) {
        checkedCount++;
      }
    }
    
    // Nếu không có mục nào cần check, không phải là completed
    if (checkedCount == 0) return false;
    
    // Nếu có ít nhất một mục chưa check, không phải là completed
    return uncheckedCount == 0;
  }

  // Public method to load notes - completely rewritten to avoid recursion
  Future<void> loadNotes() async {
    if (_noteService == null) {
      debugPrint('Warning: noteService is null when trying to load notes');
      return;
    }

    _setLoading(true);
    
    try {
      if (_searchQuery.isNotEmpty) {
        _notes = await _noteService!.searchNotes(_searchQuery);
      } else if (_selectedCategoryId.isNotEmpty) {
        _notes = await _noteService!.getNotes(categoryId: _selectedCategoryId);
      } else {
        _notes = await _noteService!.getNotes(filter: _currentFilter, sort: _currentSort);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notes: $e');
      // Don't reset _notes here to preserve any existing data
    } finally {
      _setLoading(false);
    }
  }

  // Tải tất cả danh mục - simplified
  Future<void> loadCategories() async {
    if (_noteService == null) {
      debugPrint('Warning: noteService is null when trying to load categories');
      return;
    }

    try {
      _categories = await _noteService!.categoryRepository.getAll();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Don't reset _categories here to preserve any existing data
    }
  }
    
  // Lấy chi tiết ghi chú (phương thức duy nhất, không bị trùng lặp)
  Future<Map<String, dynamic>> getNoteDetails(String noteId) async {
    if (_noteService == null) {
      throw Exception('NoteService not initialized');
    }
    
    try {
      return await _noteService!.getNoteWithCategories(noteId);
    } catch (e) {
      debugPrint('Error getting note details: $e');
      rethrow;
    }
  }

  // Theo dõi hành động người dùng với null safety
  Future<void> trackUserAction() async {
    try {
      if (_adMobService == null) return;
      await _adMobService!.trackUserAction();
    } catch (e) {
      debugPrint('Error tracking user action: $e');
    }
  }

  // Helper để theo dõi click button
  Future<void> trackButtonClick() async {
    await trackUserAction();
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
      if (_noteService == null) {
        throw Exception('NoteService not initialized');
      }
      
      final note = await _noteService!.createNote(
        title: title,
        content: content,
        color: color,
        isPinned: isPinned,
        isProtected: isProtected,
        categoryIds: categoryIds,
      );
      
      // Hiển thị quảng cáo theo dõi hành động
      await trackUserAction();
      
      await loadNotes();
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
      if (_noteService == null) {
        throw Exception('NoteService not initialized');
      }
      
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
      
      await loadNotes();
      return note;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa ghi chú (soft delete)
  Future<bool> deleteNote(String id) async {
    _setLoading(true);
    
    try {
      if (_noteService == null) {
        throw Exception('NoteService not initialized');
      }
      
      final result = await _noteService!.deleteNote(id);
      
      // Hiển thị quảng cáo theo dõi hành động
      await trackUserAction();
      
      await loadNotes();
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Khôi phục ghi chú
  Future<bool> restoreNote(String id) async {
    _setLoading(true);
    
    try {
      if (_noteService == null) {
        throw Exception('NoteService not initialized');
      }
      
      final result = await _noteService!.restoreNote(id);
      await loadNotes();
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa vĩnh viễn ghi chú
  Future<bool> permanentlyDeleteNote(String id) async {
    _setLoading(true);
    
    try {
      if (_noteService == null) {
        throw Exception('NoteService not initialized');
      }
      
      final result = await _noteService!.permanentlyDeleteNote(id);
      
      // Hiển thị quảng cáo theo dõi hành động
      await trackUserAction();
      
      await loadNotes();
      return result;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle pin
  Future<void> togglePin(String id, bool isPinned) async {
    await _noteService!.togglePinNote(id, isPinned);
    await loadNotes();
  }

  // Toggle archive
  Future<void> toggleArchive(String id, bool isArchived) async {
    await _noteService!.toggleArchiveNote(id, isArchived);
    await loadNotes();
  }

  // Toggle protect
  Future<void> toggleProtect(String id, bool isProtected) async {
    await _noteService!.toggleProtectNote(id, isProtected);
    await loadNotes();
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
        color: color
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
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _noteService?.deleteCategory(categoryId);
      loadCategories();
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = '';
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  // Thêm ghi chú vào danh mục
  Future<void> addNoteToCategory(String noteId, String categoryId) async {
    await _noteService!.addNoteToCategory(noteId, categoryId);
    
    if (_selectedCategoryId.isNotEmpty) {
      await loadNotes();
    }
  }

  // Xóa ghi chú khỏi danh mục
  Future<void> removeNoteFromCategory(String noteId, String categoryId) async {
    await _noteService!.removeNoteFromCategory(noteId, categoryId);
    
    if (_selectedCategoryId.isNotEmpty) {
      await loadNotes();
    }
  }

  // Cập nhật các danh mục của một ghi chú
  Future<void> updateNoteCategories(String noteId, List<String> categoryIds) async {
    await _noteService!.noteCategoryRepository.updateNoteCategories(noteId, categoryIds);
    
    if (_selectedCategoryId.isNotEmpty) {
      await loadNotes();
    }
  }

  // Đếm số ghi chú trong danh mục
  Future<int> countNotesInCategory(String categoryId) async {
    if (_noteService == null) return 0;
    try {
      return await _noteService!.countNotesInCategory(categoryId);
    } catch (e) {
      debugPrint('Error counting notes in category: $e');
      return 0;
    }
  }

  // Helper method to get categories from note service
  Future<List<Category>?> getCategories() async {
    try {
      if (_noteService == null) return null;
      return await _noteService!.categoryRepository.getAll();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }
  
  // Add method to ensure predefined categories exist
  Future<void> ensurePredefinedCategories() async {
    if (_noteService == null) {
      debugPrint('Warning: noteService is null when adding predefined categories');
      return;
    }
    
    try {
      // Predefined categories with colors matching the UI
      final predefinedCategories = [
        {'name': 'shopping', 'color': '#F44336'}, // Red
        {'name': 'class', 'color': '#FFA726'}, // Orange
        {'name': 'chores', 'color': '#607D8B'}, // Blue Gray
        {'name': 'work', 'color': '#5C6BC0'}, // Indigo
        {'name': 'workout', 'color': '#8E24AA'}, // Purple
        {'name': 'holiday', 'color': '#00BCD4'}, // Cyan
      ];
      
      // Get existing categories
      final existingCategories = await _noteService!.categoryRepository.getAll();
      final existingNames = existingCategories.map((c) => c.name.toLowerCase()).toList();
      
      // Create Uuid instance for generating IDs
      final uuid = Uuid();
      
      // Create categories that don't exist yet
      for (var category in predefinedCategories) {
        if (!existingNames.contains(category['name']!.toLowerCase())) {
          await createCategory(
            name: category['name']!,
            color: category['color']!,
          );
          debugPrint('Created predefined category: ${category['name']}');
        }
      }
      
      // Reload categories
      await loadCategories();
    } catch (e) {
      debugPrint('Error ensuring predefined categories: $e');
    }
  }
  
  // Sắp xếp lại thứ tự danh mục
  Future<void> reorderCategories(List<Category> categories) async {
    try {
      if (_noteService == null) {
        throw Exception('NoteService not initialized');
      }
      
      await _noteService!.reorderCategories(categories);
      await loadCategories();
    } catch (e) {
      debugPrint('Error reordering categories: $e');
    }
  }
} 