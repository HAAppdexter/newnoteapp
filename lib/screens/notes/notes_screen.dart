import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newnoteapp/providers/note_provider.dart';
import 'package:newnoteapp/providers/settings_provider.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:newnoteapp/database/note_repository.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isLoading = false;
  String _filter = 'all'; // all, pinned, archived, deleted
  String _view = 'grid'; // grid, list
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadNotes();
    
    // Lấy chế độ xem mặc định từ settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      setState(() {
        _view = settingsProvider.defaultView;
      });
    });
  }
  
  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });
    
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    try {
      // Thiết lập bộ lọc
      NoteFilter filter;
      switch (_filter) {
        case 'pinned':
          filter = NoteFilter.pinned;
          break;
        case 'archived':
          filter = NoteFilter.archived;
          break;
        case 'deleted':
          filter = NoteFilter.deleted;
          break;
        default:
          filter = NoteFilter.all;
      }
      
      // Nếu đang tìm kiếm
      if (_searchQuery.isNotEmpty) {
        await noteProvider.searchNotes(_searchQuery);
      } else {
        await noteProvider.changeFilter(filter);
      }
    } catch (e) {
      print('Error loading notes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notes),
                title: const Text('Tất cả ghi chú'),
                onTap: () {
                  setState(() {
                    _filter = 'all';
                  });
                  _loadNotes();
                  Navigator.pop(context);
                },
                selected: _filter == 'all',
              ),
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('Ghi chú đã ghim'),
                onTap: () {
                  setState(() {
                    _filter = 'pinned';
                  });
                  _loadNotes();
                  Navigator.pop(context);
                },
                selected: _filter == 'pinned',
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Lưu trữ'),
                onTap: () {
                  setState(() {
                    _filter = 'archived';
                  });
                  _loadNotes();
                  Navigator.pop(context);
                },
                selected: _filter == 'archived',
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Thùng rác'),
                onTap: () {
                  setState(() {
                    _filter = 'deleted';
                  });
                  _loadNotes();
                  Navigator.pop(context);
                },
                selected: _filter == 'deleted',
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final noteProvider = Provider.of<NoteProvider>(context);
        
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Mới nhất trước'),
                onTap: () {
                  noteProvider.changeSort(NoteSort.updatedDesc);
                  Navigator.pop(context);
                },
                selected: noteProvider.currentSort == NoteSort.updatedDesc,
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Cũ nhất trước'),
                onTap: () {
                  noteProvider.changeSort(NoteSort.updatedAsc);
                  Navigator.pop(context);
                },
                selected: noteProvider.currentSort == NoteSort.updatedAsc,
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('A-Z'),
                onTap: () {
                  noteProvider.changeSort(NoteSort.titleAsc);
                  Navigator.pop(context);
                },
                selected: noteProvider.currentSort == NoteSort.titleAsc,
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('Z-A'),
                onTap: () {
                  noteProvider.changeSort(NoteSort.titleDesc);
                  Navigator.pop(context);
                },
                selected: noteProvider.currentSort == NoteSort.titleDesc,
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _toggleView() {
    setState(() {
      _view = _view == 'grid' ? 'list' : 'grid';
    });
    
    // Lưu lại setting
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.setDefaultView(_view);
  }
  
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadNotes();
    
    if (query.isNotEmpty) {
      // Lưu từ khóa tìm kiếm gần đây
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.addRecentSearch(query);
    }
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _loadNotes();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchQuery.isEmpty
            ? const Text('Ghi chú')
            : TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
                ),
                onSubmitted: _handleSearch,
              ),
        actions: [
          IconButton(
            icon: Icon(_searchQuery.isEmpty ? Icons.search : Icons.cancel),
            onPressed: () {
              if (_searchQuery.isEmpty) {
                setState(() {
                  // Hiển thị thanh tìm kiếm
                  _searchController.clear();
                });
              } else {
                _clearSearch();
              }
            },
          ),
          IconButton(
            icon: Icon(_view == 'grid' ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Lọc ghi chú'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Sắp xếp'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'filter') {
                _showFilterMenu(context);
              } else if (value == 'sort') {
                _showSortMenu(context);
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Mở màn hình tạo ghi chú mới
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildBody() {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        if (_isLoading || noteProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final notes = noteProvider.notes;
        
        if (notes.isEmpty) {
          return _buildEmptyState();
        }
        
        return _view == 'grid'
            ? _buildGridView(notes)
            : _buildListView(notes);
      },
    );
  }
  
  Widget _buildEmptyState() {
    IconData icon;
    String message;
    
    if (_searchQuery.isNotEmpty) {
      icon = Icons.search_off;
      message = 'Không tìm thấy ghi chú nào cho "$_searchQuery"';
    } else {
      switch (_filter) {
        case 'pinned':
          icon = Icons.push_pin_outlined;
          message = 'Chưa có ghi chú nào được ghim';
          break;
        case 'archived':
          icon = Icons.archive_outlined;
          message = 'Chưa có ghi chú nào được lưu trữ';
          break;
        case 'deleted':
          icon = Icons.delete_outline;
          message = 'Thùng rác trống';
          break;
        default:
          icon = Icons.note_outlined;
          message = 'Chưa có ghi chú nào. Tạo ghi chú mới?';
      }
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridView(List<Note> notes) {
    // Tách riêng các ghi chú đã ghim và chưa ghim
    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();
    
    return CustomScrollView(
      slivers: [
        // Hiển thị ghi chú đã ghim
        if (pinnedNotes.isNotEmpty && _filter != 'pinned') ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Đã ghim',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildNoteItem(pinnedNotes[index]),
                childCount: pinnedNotes.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Khác',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
        
        // Hiển thị các ghi chú khác
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildNoteItem(
                pinnedNotes.isNotEmpty && _filter != 'pinned'
                    ? unpinnedNotes[index]
                    : notes[index],
              ),
              childCount: pinnedNotes.isNotEmpty && _filter != 'pinned'
                  ? unpinnedNotes.length
                  : notes.length,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildListView(List<Note> notes) {
    // Tách riêng các ghi chú đã ghim và chưa ghim
    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();
    
    return CustomScrollView(
      slivers: [
        // Hiển thị ghi chú đã ghim
        if (pinnedNotes.isNotEmpty && _filter != 'pinned') ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Đã ghim',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildNoteListItem(pinnedNotes[index]),
              childCount: pinnedNotes.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Khác',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
        
        // Hiển thị các ghi chú khác
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildNoteListItem(
              pinnedNotes.isNotEmpty && _filter != 'pinned'
                  ? unpinnedNotes[index]
                  : notes[index],
            ),
            childCount: pinnedNotes.isNotEmpty && _filter != 'pinned'
                ? unpinnedNotes.length
                : notes.length,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoteItem(Note note) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final showDate = settingsProvider.showDate;
    final formattedDate = DateFormat('dd/MM/yyyy').format(note.updatedAt);
    
    Color cardColor = Colors.white;
    if (note.color.isNotEmpty) {
      cardColor = Color(int.parse(note.color.replaceAll('#', '0xFF')));
    }
    
    return Card(
      color: cardColor,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Mở màn hình xem/sửa ghi chú
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(
                      Icons.push_pin,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showDate) ...[
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
              if (note.isProtected)
                const Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNoteListItem(Note note) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final showDate = settingsProvider.showDate;
    final formattedDate = DateFormat('dd/MM/yyyy').format(note.updatedAt);
    
    Color cardColor = Colors.white;
    if (note.color.isNotEmpty) {
      cardColor = Color(int.parse(note.color.replaceAll('#', '0xFF')));
    }
    
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Mở màn hình xem/sửa ghi chú
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      if (note.isProtected)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.lock,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      if (note.isPinned)
                        const Icon(
                          Icons.push_pin,
                          size: 18,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showDate) ...[
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 