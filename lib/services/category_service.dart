import 'package:newnoteapp/database/category_repository.dart';
import 'package:newnoteapp/database/note_category_repository.dart';
import 'package:newnoteapp/models/category.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:uuid/uuid.dart';

class CategoryService {
  final CategoryRepository _categoryRepository;
  final NoteCategoryRepository _noteCategoryRepository;
  final _uuid = Uuid();

  CategoryService({
    required CategoryRepository categoryRepository,
    required NoteCategoryRepository noteCategoryRepository,
  })  : _categoryRepository = categoryRepository,
        _noteCategoryRepository = noteCategoryRepository;

  // Tạo danh mục mới
  Future<Category> createCategory({
    required String name,
    String color = '#5D9CEC',
    int? orderIndex,
  }) async {
    // Lấy tất cả danh mục để xác định orderIndex nếu chưa có
    if (orderIndex == null) {
      final categories = await _categoryRepository.getAll();
      orderIndex = categories.length;
    }

    // Tạo danh mục mới
    final category = Category.create(
      id: _uuid.v4(),
      name: name,
      color: color,
      orderIndex: orderIndex,
    );

    // Lưu vào database
    return await _categoryRepository.create(category);
  }

  // Cập nhật danh mục
  Future<Category?> updateCategory({
    required String id,
    String? name,
    String? color,
    int? orderIndex,
  }) async {
    // Lấy danh mục hiện tại
    final currentCategory = await _categoryRepository.getById(id);
    if (currentCategory == null) {
      return null;
    }

    // Tạo bản sao với các thông tin cập nhật
    final updatedCategory = currentCategory.copyWith(
      name: name,
      color: color,
      orderIndex: orderIndex,
    );

    // Cập nhật danh mục
    await _categoryRepository.update(updatedCategory);
    return updatedCategory;
  }

  // Xóa danh mục
  Future<bool> deleteCategory(String categoryId) async {
    // Xóa các liên kết với note trước
    await _noteCategoryRepository.deleteAllForCategory(categoryId);
    
    // Xóa danh mục
    final result = await _categoryRepository.delete(categoryId);
    return result > 0;
  }

  // Lấy tất cả danh mục
  Future<List<Category>> getAllCategories() async {
    return await _categoryRepository.getAll();
  }

  // Lấy danh mục theo ID
  Future<Category?> getCategoryById(String categoryId) async {
    return await _categoryRepository.getById(categoryId);
  }

  // Lấy ghi chú trong danh mục
  Future<List<Note>> getNotesInCategory(String categoryId) async {
    return await _categoryRepository.getNotesByCategory(categoryId);
  }

  // Đếm số lượng ghi chú trong danh mục
  Future<int> countNotesInCategory(String categoryId) async {
    return await _noteCategoryRepository.countNotesInCategory(categoryId);
  }

  // Lấy danh mục của một ghi chú
  Future<List<Category>> getCategoriesForNote(String noteId) async {
    return await _categoryRepository.getCategoriesForNote(noteId);
  }

  // Cập nhật thứ tự các danh mục
  Future<void> reorderCategories(List<Category> categories) async {
    await _categoryRepository.reorderCategories(categories);
  }

  // Kiểm tra xem ghi chú có thuộc danh mục không
  Future<bool> isNoteInCategory(String noteId, String categoryId) async {
    return await _noteCategoryRepository.isNoteInCategory(noteId, categoryId);
  }
} 