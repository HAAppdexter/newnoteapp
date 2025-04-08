import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newnoteapp/providers/note_provider.dart';
import 'package:newnoteapp/providers/settings_provider.dart';
import 'package:newnoteapp/providers/theme_provider.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:newnoteapp/database/note_repository.dart';
import 'package:intl/intl.dart';
import 'package:newnoteapp/screens/notes/widgets/note_card.dart';
import 'package:newnoteapp/screens/notes/note_editor_screen.dart';
import 'package:newnoteapp/providers/ad_provider.dart';
import 'package:newnoteapp/screens/categories/categories_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newnoteapp/themes/app_theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  List<Note> _notes = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isGridView = true; // Mặc định hiển thị dạng lưới
  
  // Active tab and sort options
  String _selectedTab = 'All';
  String _currentSortMethod = 'by date changed';
  bool _showOnlyFavorites = false;
  
  // Tabs and sort options
  final List<String> _tabs = ['All', '#Categories', 'Calendar', 'Unsorted', 'Completed'];
  final List<String> _sortOptions = [
    'by date changed',
    'by date added',
    'alphabetical',
    'by scheduled date'
  ];
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadBannerAd();
    
    // Ensure predefined categories exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      noteProvider.ensurePredefinedCategories();
      noteProvider.addListener(_onNotesChanged);
    });
  }

  @override
  void dispose() {
    // Hủy đăng ký lắng nghe
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.removeListener(_onNotesChanged);
    
    _searchController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    if (mounted) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      setState(() {
        _notes = noteProvider.notes;
      });
    }
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      // Nếu provider không được khởi tạo, chỉ đặt trạng thái loading = false và trả về
      if (!noteProvider.isInitialized) {
        debugPrint('NoteProvider is not initialized yet. Waiting...');
        
        // Đặt notes bằng danh sách hiện có từ provider (có thể trống)
        if (mounted) {
          setState(() {
            _notes = noteProvider.notes;
            _isLoading = false;
          });
        }
        return;
      }
      
      // Lấy danh sách ghi chú trực tiếp từ provider mà không cần gọi loadNotes
      if (mounted) {
        setState(() {
          _notes = noteProvider.notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Không hiển thị snackbar để tránh quá nhiều thông báo lỗi
      debugPrint('Error loading notes in NotesScreen: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadBannerAd() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Nếu quảng cáo đã load, sử dụng nó
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
  }

  void _toggleViewMode() {
    // Đánh dấu tương tác với button để hiển thị quảng cáo
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.trackButtonClick();
    
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _sortOptions.map((option) {
              return ListTile(
                title: Text(option),
                leading: option == _currentSortMethod 
                    ? const Icon(Icons.check, color: Colors.green) 
                    : const SizedBox(width: 24),
                onTap: () {
                  setState(() {
                    _currentSortMethod = option;
                  });
                  // Apply sorting
                  _sortNotes();
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  void _sortNotes() {
    final List<Note> sortedNotes = List.from(_notes);
    
    switch (_currentSortMethod) {
      case 'by date changed':
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'by date added':
        sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'alphabetical':
        sortedNotes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'by scheduled date':
        // Assuming you might add a scheduledDate field in the future
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
    
    setState(() {
      _notes = sortedNotes;
    });
  }
  
  void _toggleFavoriteFilter() {
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
    });
  }
  
  void _changeTab(String tab) {
    if (_selectedTab == tab) return;
    
    setState(() {
      _selectedTab = tab;
    });
    
    // Apply filters based on tab
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    switch (tab) {
      case 'All':
        noteProvider.changeFilter(NoteFilter.all);
        break;
      case '#Categories':
        // Don't show bottom sheet, just display the category chips in the UI
        noteProvider.changeFilter(NoteFilter.all);
        break;
      case 'Calendar':
        // Show calendar view - don't show dialog immediately to let the UI update first
        break;
      case 'Unsorted':
        // Show notes without categories
        _showUnsortedNotes();
        break;
      case 'Completed':
        // Show completed notes (checkbox style notes with all items checked)
        _showCompletedNotes();
        break;
    }
  }

  void _showCategoriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final noteProvider = Provider.of<NoteProvider>(context);
        final categories = noteProvider.categories;
        
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Chọn danh mục',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoriesScreen(),
                          ),
                        );
                      },
                      tooltip: 'Thêm danh mục',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final categoryColor = AppTheme.hexToColor(category.color);
                    
                    return ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(category.name),
                      onTap: () {
                        Navigator.pop(context);
                        noteProvider.selectCategory(category.id);
                        setState(() {
                          _selectedTab = 'All'; // Reset selected tab
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCalendarView() {
    // Filter notes by selected date instead of showing a message
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.changeFilter(NoteFilter.all);
  }

  void _showUnsortedNotes() {
    // Show notes without categories
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.showUnsortedNotes();
  }

  void _showCompletedNotes() {
    // Show completed notes (checkbox style notes with all items checked)
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.showCompletedNotes();
  }

  List<Note> _getFilteredNotes() {
    if (!_showOnlyFavorites) return _notes;
    
    return _notes.where((note) => note.isPinned).toList();
  }

  // Add this method to filter by date
  void _filterByDate(DateTime date) {
    // Reset to all notes first
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.changeFilter(NoteFilter.all);
    
    // Then filter notes that have this date in their content or metadata
    // This would be a simplified implementation - in a real app you'd use a proper date field
    setState(() {
      final dateStr = DateFormat('dd/MM/yy').format(date);
      _notes = _notes.where((note) {
        return note.content.contains(dateStr) || 
               note.title.contains(dateStr) ||
               DateFormat('dd/MM/yy').format(note.createdAt) == dateStr;
      }).toList();
    });
    
    // Show a message about filtering
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing notes for ${DateFormat('dd/MM/yy').format(date)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Add method to show date picker
  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _filterByDate(selectedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final filteredNotes = _getFilteredNotes();
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                border: InputBorder.none,
              ),
              onChanged: (query) {
                final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                noteProvider.searchNotes(query);
              },
            )
          : const Text('Notes', style: TextStyle(fontSize: 28)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                  noteProvider.clearSearch();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(_showOnlyFavorites 
              ? Icons.star 
              : Icons.star_border),
            onPressed: _toggleFavoriteFilter,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildTabsRow(),
          if (_selectedTab == '#Categories')
            _buildCategoryChips(),
          if (_selectedTab == 'Calendar')
            _buildCalendarOptions(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : filteredNotes.isEmpty 
                ? _buildEmptyState()
                : _buildNotesGrid(filteredNotes),
          ),
          if (_isBannerAdLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: 50,
              child: AdWidget(
                key: ValueKey<int>(identityHashCode(_bannerAd)),
                ad: _bannerAd!,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Đánh dấu tương tác với button để hiển thị quảng cáo
          final adProvider = Provider.of<AdProvider>(context, listen: false);
          adProvider.trackButtonClick();
          
          // Mở màn hình tạo ghi chú mới
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteEditorScreen(),
            ),
          ).then((value) {
            if (value == true) {
              // Nếu có thay đổi, cập nhật lại danh sách
              _loadNotes();
            }
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTabsRow() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = tab == _selectedTab;
          
          return GestureDetector(
            onTap: () => _changeTab(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey,
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có ghi chú nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để tạo ghi chú mới',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid(List<Note> notes) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return _buildGridNoteCard(notes[index]);
        },
      ),
    );
  }

  Widget _buildGridNoteCard(Note note) {
    Color cardColor = Colors.white;
    if (note.color.isNotEmpty) {
      cardColor = Color(int.parse(note.color.replaceAll('#', '0xFF')));
    }
    
    // Format date for more user-friendly display
    String formattedDate;
    final now = DateTime.now();
    final difference = now.difference(note.updatedAt);
    
    if (difference.inDays == 0) {
      // Today - just show time
      formattedDate = 'Today, ${DateFormat('HH:mm').format(note.updatedAt)}';
    } else if (difference.inDays == 1) {
      // Yesterday
      formattedDate = 'Yesterday, ${DateFormat('HH:mm').format(note.updatedAt)}';
    } else if (difference.inDays < 7) {
      // Within a week - show day name
      formattedDate = '${DateFormat('E').format(note.updatedAt)}, ${DateFormat('HH:mm').format(note.updatedAt)}';
    } else {
      // Over a week - show full date
      formattedDate = DateFormat('dd/MM/yy HH:mm').format(note.updatedAt);
    }
    
    // Extract first few lines for preview
    final contentPreview = _getContentPreview(note.content);
    
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(noteId: note.id),
            ),
          ).then((value) {
            if (value == true) {
              _loadNotes();
            }
          });
        },
        onLongPress: () => _showNoteOptions(note),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and pin icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getContrastColor(cardColor),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Content preview
              Expanded(
                child: Text(
                  contentPreview,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getContrastColor(cardColor).withOpacity(0.8),
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Date/time
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: _getContrastColor(cardColor).withOpacity(0.6),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteOptions(Note note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Mark as completed'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement completion functionality
                  },
                ),
                ListTile(
                  leading: Icon(note.isPinned ? Icons.star : Icons.star_border),
                  title: Text(note.isPinned ? 'Remove from favorites' : 'Mark as favorite'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleNoteFavorite(note);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: const Text('Copy note'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement copy functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.push_pin_outlined),
                  title: const Text('Pin note'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleNoteFavorite(note);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Share note'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement share functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteNote(note);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _toggleNoteFavorite(Note note) async {
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.updateNote(
        id: note.id,
        title: note.title,
        content: note.content,
        color: note.color,
        isPinned: !note.isPinned,
        isProtected: note.isProtected,
      );
      
      _loadNotes();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }
  
  Future<void> _deleteNote(Note note) async {
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.deleteNote(note.id);
      
      _loadNotes();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Ideally would restore the note
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  String _getContentPreview(String content) {
    if (content.length > 200) {
      return content.substring(0, 200) + '...';
    }
    return content;
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance (0 is black, 1 is white)
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildCategoryChips() {
    // Predefined categories with colors matching the image
    final predefinedCategories = [
      {'name': 'All', 'color': '#9E9E9E'}, // Gray
      {'name': 'shopping', 'color': '#F44336'}, // Red
      {'name': 'class', 'color': '#FFA726'}, // Orange
      {'name': 'chores', 'color': '#607D8B'}, // Blue Gray
      {'name': 'work', 'color': '#5C6BC0'}, // Indigo
      {'name': 'workout', 'color': '#8E24AA'}, // Purple
      {'name': 'holiday', 'color': '#00BCD4'}, // Cyan
    ];
    
    String selectedCategory = 'All'; // Default selected category
    if (_selectedTab == '#Categories' && Provider.of<NoteProvider>(context).selectedCategoryId.isNotEmpty) {
      // Try to match with actual selected category
      final noteProvider = Provider.of<NoteProvider>(context);
      final categories = noteProvider.categories;
      for (var category in categories) {
        if (category.id == noteProvider.selectedCategoryId) {
          selectedCategory = category.name;
          break;
        }
      }
    }
    
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: predefinedCategories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = predefinedCategories[index];
          final isSelected = category['name'] == selectedCategory;
          final color = AppTheme.hexToColor(category['color']!);
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                category['name']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: color.withOpacity(0.2),
              selectedColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: color,
                  width: 1,
                ),
              ),
              onSelected: (selected) {
                if (category['name'] == 'All') {
                  // Handle "All" category
                  Provider.of<NoteProvider>(context, listen: false).clearCategorySelection();
                } else {
                  // Find the actual category from the provider to get its ID
                  final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                  final categories = noteProvider.categories;
                  for (var cat in categories) {
                    if (cat.name.toLowerCase() == category['name']!.toLowerCase()) {
                      noteProvider.selectCategory(cat.id);
                      break;
                    }
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  // New method to build calendar filter options
  Widget _buildCalendarOptions() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildCalendarOptionChip('today', () {
            _filterByDate(DateTime.now());
          }),
          const SizedBox(width: 8),
          _buildCalendarOptionChip('tomorrow', () {
            _filterByDate(DateTime.now().add(const Duration(days: 1)));
          }),
          const SizedBox(width: 8),
          _buildCalendarOptionChip('set date', () {
            _showDatePicker();
          }),
        ],
      ),
    );
  }

  // Helper method to create calendar option chips
  Widget _buildCalendarOptionChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
} 