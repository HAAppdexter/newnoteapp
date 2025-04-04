import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newnoteapp/screens/notes/notes_screen.dart';
import 'package:newnoteapp/screens/notes/note_editor_screen.dart';
import 'package:newnoteapp/screens/categories/categories_screen.dart';
import 'package:newnoteapp/screens/settings/settings_screen.dart';
import 'package:newnoteapp/providers/ad_provider.dart';
import 'package:newnoteapp/providers/note_provider.dart';
import 'package:newnoteapp/providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Khởi tạo sẵn các màn hình để tránh rebuild không cần thiết
  late final List<Widget> _screens;
  
  final List<String> _titles = const [
    'Ghi chú',
    'Danh mục',
    'Cài đặt',
  ];
  
  @override
  void initState() {
    super.initState();
    // Khởi tạo các màn hình một lần duy nhất
    _screens = [
      const NotesScreen(),
      const CategoriesScreen(),
      const SettingsScreen(),
    ];
    
    // Trễ việc tải banner ad để tránh làm chậm quá trình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdProvider adProvider = Provider.of<AdProvider>(context, listen: false);
      if (!adProvider.isBannerAdLoaded) {
        adProvider.initialize();
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onTabSelected(int index) {
    // Nếu đã ở tab hiện tại, không làm gì để tránh rebuild không cần thiết
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _openNoteEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteEditorScreen(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          // Cập nhật _currentIndex mà không gọi setState() nếu đã được thay đổi qua _onTabSelected
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAdBanner(),
          _buildBottomNavigationBar(),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
    );
  }
  
  // Tách các widgets để cải thiện khả năng đọc và tạo điều kiện cho Flutter tối ưu rebuilds
  Widget _buildBottomNavigationBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabSelected,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: isDarkMode ? const Color(0xFFAAAAAA) : const Color(0xFF757575),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'Ghi chú',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
    );
  }
  
  Widget _buildFAB() {
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: _openNoteEditor,
      tooltip: 'Tạo ghi chú mới',
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      child: const Icon(Icons.add),
    );
  }
  
  Widget _buildAdBanner() {
    return Consumer<AdProvider>(
      builder: (context, adProvider, child) {
        if (!adProvider.isBannerAdLoaded) {
          return const SizedBox(height: 0);  // Zero-sized widget thay vì SizedBox.shrink()
        }
        
        return Container(
          width: adProvider.bannerAd!.size.width.toDouble(),
          height: adProvider.bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          child: AdWidget(ad: adProvider.bannerAd!),
        );
      },
    );
  }
} 