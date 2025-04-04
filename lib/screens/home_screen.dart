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
  
  final List<Widget> _screens = [
    const NotesScreen(),
    const CategoriesScreen(),
    const SettingsScreen(),
  ];
  
  final List<String> _titles = [
    'Ghi chú',
    'Danh mục',
    'Cài đặt',
  ];
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onTabSelected(int index) {
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.system
                    ? (themeProvider.isDarkMode 
                        ? Icons.dark_mode 
                        : Icons.light_mode)
                    : (themeProvider.themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode),
              ),
              onPressed: () {
                if (_currentIndex != 2) {
                  _onTabSelected(2);
                }
                
                Future.delayed(const Duration(milliseconds: 300), () {
                  // Đây là ví dụ, bạn có thể cần điều chỉnh tùy thuộc vào cấu trúc của SettingsScreen
                  // hoặc triển khai một dialog chọn theme ở đây
                });
              },
              tooltip: themeProvider.themeMode == ThemeMode.system
                  ? 'Chế độ tự động (theo thiết bị)'
                  : (themeProvider.themeMode == ThemeMode.dark
                      ? 'Chế độ tối'
                      : 'Chế độ sáng'),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAdBanner(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
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
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openNoteEditor,
              tooltip: 'Tạo ghi chú mới',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildAdBanner() {
    return Consumer<AdProvider>(
      builder: (context, adProvider, child) {
        if (!adProvider.isBannerAdLoaded) {
          return const SizedBox.shrink();
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