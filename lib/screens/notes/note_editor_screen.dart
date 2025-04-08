import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newnoteapp/providers/note_provider.dart';
import 'package:newnoteapp/providers/security_provider.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:newnoteapp/models/category.dart';
import 'package:newnoteapp/themes/app_theme.dart';
import 'package:newnoteapp/providers/ad_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  
  const NoteEditorScreen({
    super.key,
    this.noteId,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPinned = false;
  bool _isProtected = false;
  String _selectedColor = '';
  List<Category> _availableCategories = [];
  List<Category> _selectedCategories = [];
  
  // Add banner ad reference
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBannerAd();
    
    // Đánh dấu đang ở chế độ soạn thảo
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.enterEditingMode();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      // Kiểm tra nếu noteProvider chưa khởi tạo xong hoặc noteService null
      if (!noteProvider.isInitialized || noteProvider.noteService == null) {
        debugPrint('NoteProvider not fully initialized in NoteEditorScreen');
        // Đợi 1 giây và tiếp tục, nếu vẫn không khả dụng thì hiển thị trạng thái trống
        await Future.delayed(Duration(seconds: 1)); 
        if (!mounted) return;
      }
      
      // Tải danh sách danh mục
      _availableCategories = noteProvider.categories;
      
      // Nếu đang chỉnh sửa ghi chú hiện có
      if (widget.noteId != null) {
        try {
          final noteDetails = await noteProvider.getNoteDetails(widget.noteId!);
          final note = noteDetails['note'] as Note;
          final categories = noteDetails['categories'] as List<Category>;
          
          // Nếu là ghi chú được bảo vệ, cần xác thực
          if (note.isProtected) {
            final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
            final canAccess = await securityProvider.canAccessProtectedNote();
            
            if (!canAccess) {
              // Không có quyền truy cập, quay lại
              if (mounted) {
                Navigator.pop(context);
              }
              return;
            }
          }
          
          // Điền dữ liệu vào form
          if (mounted) {
            setState(() {
              _titleController.text = note.title;
              _contentController.text = note.content;
              _isPinned = note.isPinned;
              _isProtected = note.isProtected;
              _selectedColor = note.color;
              _selectedCategories = categories;
            });
          }
        } catch (e) {
          debugPrint('Error loading note details: $e');
          // Hiển thị thông báo lỗi
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không thể tải ghi chú. Đã xảy ra lỗi.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading note data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiêu đề không được để trống'),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final categoryIds = _selectedCategories.map((c) => c.id).toList();
      
      if (widget.noteId != null) {
        // Cập nhật ghi chú hiện có
        await noteProvider.updateNote(
          id: widget.noteId!,
          title: title,
          content: content,
          color: _selectedColor,
          isPinned: _isPinned,
          isProtected: _isProtected,
          categoryIds: categoryIds,
        );
      } else {
        // Tạo ghi chú mới
        await noteProvider.createNote(
          title: title,
          content: content,
          color: _selectedColor,
          isPinned: _isPinned,
          isProtected: _isProtected,
          categoryIds: categoryIds,
        );
      }
      
      if (mounted) {
        // Đánh dấu đã thoát chế độ soạn thảo trước khi thoát màn hình
        final adProvider = Provider.of<AdProvider>(context, listen: false);
        adProvider.exitEditingMode();
        
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving note: $e');
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
  
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Chọn màu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildColorOption('', Colors.white),
                  ...AppTheme.noteColors.skip(1).map((color) {
                    return _buildColorOption(
                      AppTheme.colorToHex(color),
                      color,
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildColorOption(String colorHex, Color color) {
    final isSelected = colorHex == _selectedColor;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = colorHex;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.blue,
              )
            : null,
      ),
    );
  }
  
  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Danh mục',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableCategories.length,
                      itemBuilder: (context, index) {
                        final category = _availableCategories[index];
                        final isSelected = _selectedCategories.any(
                          (c) => c.id == category.id,
                        );
                        
                        return CheckboxListTile(
                          title: Text(category.name),
                          value: isSelected,
                          activeColor: AppTheme.hexToColor(category.color),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                if (!_selectedCategories.any((c) => c.id == category.id)) {
                                  _selectedCategories.add(category);
                                }
                              } else {
                                _selectedCategories.removeWhere((c) => c.id == category.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategories.clear();
                            });
                          },
                          child: const Text('Xóa tất cả'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            this.setState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text('Xong'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _loadBannerAd() {
    try {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      
      // Kiểm tra quảng cáo đã load chưa
      if (adProvider.isBannerAdLoaded) {
        setState(() {
          _bannerAd = adProvider.bannerAd;
          _isBannerAdLoaded = true;
        });
      }
      
      // Đăng ký lắng nghe sự thay đổi trạng thái quảng cáo
      adProvider.addListener(() {
        if (mounted) {
          setState(() {
            _bannerAd = adProvider.bannerAd;
            _isBannerAdLoaded = adProvider.isBannerAdLoaded;
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading banner ad in NoteEditorScreen: $e');
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    
    // Đánh dấu đã thoát chế độ soạn thảo
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.exitEditingMode();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    if (_selectedColor.isNotEmpty) {
      backgroundColor = AppTheme.hexToColor(_selectedColor);
    }
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
            tooltip: _isPinned ? 'Bỏ ghim' : 'Ghim ghi chú',
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: _showColorPicker,
            tooltip: 'Đổi màu',
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: _showCategorySelection,
            tooltip: 'Danh mục',
          ),
          IconButton(
            icon: Icon(_isProtected ? Icons.lock : Icons.lock_open),
            onPressed: () {
              setState(() {
                _isProtected = !_isProtected;
              });
            },
            tooltip: _isProtected ? 'Bỏ bảo vệ' : 'Bảo vệ ghi chú',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content in an Expanded widget to take available space
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected categories chips
                      if (_selectedCategories.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          children: _selectedCategories.map((category) {
                            return Chip(
                              label: Text(category.name),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategories.remove(category);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    
                      // Title text field
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Tiêu đề',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Content text field
                      TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập nội dung ghi chú...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 16),
                        maxLines: null,
                        minLines: 15,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ),
          ),
          
          // Banner ad at the bottom
          if (_isBannerAdLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: 50,
              child: AdWidget(
                // Sử dụng identity hash để đảm bảo key thực sự duy nhất
                key: ValueKey<int>(identityHashCode(_bannerAd)),
                ad: _bannerAd!,
              ),
            ),
        ],
      ),
    );
  }
} 