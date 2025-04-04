import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newnoteapp/providers/note_provider.dart';
import 'package:newnoteapp/models/category.dart';
import 'package:newnoteapp/themes/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      // Tải lại danh sách danh mục
      await noteProvider.loadCategories();
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showAddEditCategoryDialog({Category? category}) {
    final TextEditingController nameController = TextEditingController();
    String selectedColorHex = '#5D9CEC'; // Màu mặc định
    
    if (category != null) {
      nameController.text = category.name;
      selectedColorHex = category.color;
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'Thêm danh mục' : 'Chỉnh sửa danh mục'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên danh mục',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Màu sắc:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppTheme.noteColors.map((color) {
                      final colorHex = AppTheme.colorToHex(color);
                      final isSelected = colorHex == selectedColorHex;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorHex = colorHex;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tên danh mục không được để trống'),
                        ),
                      );
                      return;
                    }
                    
                    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                    
                    try {
                      if (category == null) {
                        // Thêm danh mục mới
                        await noteProvider.createCategory(
                          name: name,
                          color: selectedColorHex,
                        );
                      } else {
                        // Cập nhật danh mục
                        await noteProvider.updateCategory(
                          id: category.id,
                          name: name,
                          color: selectedColorHex,
                        );
                      }
                      
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print('Error saving category: $e');
                    }
                  },
                  child: Text(category == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _deleteCategory(Category category) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc muốn xóa danh mục "${category.name}"? '
            'Các ghi chú sẽ không bị xóa nhưng sẽ không còn gán với danh mục này nữa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
    
    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);
        await noteProvider.deleteCategory(category.id);
      } catch (e) {
        print('Error deleting category: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<NoteProvider>(
              builder: (context, noteProvider, child) {
                final categories = noteProvider.categories;
                
                if (categories.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có danh mục nào.\nTạo danh mục mới?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: categories.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    
                    final orderedCategories = List<Category>.from(categories);
                    final item = orderedCategories.removeAt(oldIndex);
                    orderedCategories.insert(newIndex, item);
                    
                    noteProvider.reorderCategories(orderedCategories);
                  },
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryItem(category, index);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCategoryItem(Category category, int index) {
    final Color categoryColor = AppTheme.hexToColor(category.color);
    
    return Card(
      key: ValueKey(category.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: categoryColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(category.name),
        subtitle: FutureBuilder<int>(
          future: Provider.of<NoteProvider>(context, listen: false)
              .countNotesInCategory(category.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Đang tải...');
            }
            
            final count = snapshot.data ?? 0;
            return Text('$count ghi chú');
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddEditCategoryDialog(category: category),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCategory(category),
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
        onTap: () {
          // Chuyển đến màn hình hiển thị ghi chú của danh mục
          final noteProvider = Provider.of<NoteProvider>(context, listen: false);
          noteProvider.selectCategory(category.id);
          Navigator.pop(context);
        },
      ),
    );
  }
} 