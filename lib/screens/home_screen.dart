import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:newnoteapp/screens/notes/notes_screen.dart';
import 'package:newnoteapp/screens/notes/note_editor_screen.dart';
import 'package:newnoteapp/screens/categories/categories_screen.dart';
import 'package:newnoteapp/screens/settings/settings_screen.dart';
import 'package:newnoteapp/providers/ad_provider.dart';

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
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }
  
  Future<void> _openNoteEditor() async {
    await Navigator.push(
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
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAdBanner(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
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