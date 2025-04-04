import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newnoteapp/providers/theme_provider.dart';
import 'package:newnoteapp/providers/settings_provider.dart';
import 'package:newnoteapp/providers/note_provider.dart';
import 'package:newnoteapp/providers/security_provider.dart';
import 'package:newnoteapp/providers/ad_provider.dart';
import 'package:newnoteapp/models/category.dart';
import 'package:newnoteapp/themes/app_theme.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _fontSize = 16.0;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _fontSize = settingsProvider.fontSize;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Giao diện
              _buildSection(
                title: 'Giao diện',
                children: [
                  _buildThemeSelector(),
                  _buildFontSizeSlider(),
                  _buildSwitch(
                    title: 'Hiển thị ngày trên ghi chú',
                    value: settingsProvider.showDate,
                    onChanged: (value) => settingsProvider.setShowDate(value),
                  ),
                  _buildViewModeSelector(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Bảo mật
              _buildSection(
                title: 'Bảo mật',
                children: [
                  Consumer<SecurityProvider>(
                    builder: (context, securityProvider, child) {
                      return Column(
                        children: [
                          ListTile(
                            title: const Text('Đặt mã khóa bảo vệ'),
                            subtitle: FutureBuilder<bool>(
                              future: securityProvider.hasPasscode,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text('Đang tải...');
                                }
                                return Text(
                                  snapshot.data! ? 'Đã bật' : 'Đã tắt',
                                );
                              },
                            ),
                            leading: const Icon(Icons.lock_outline),
                            onTap: () {
                              // TODO: Hiển thị màn hình đặt mã khóa
                            },
                          ),
                          FutureBuilder<bool>(
                            future: Future.value(securityProvider.isBiometricAvailable),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || !snapshot.data!) {
                                return const SizedBox.shrink();
                              }
                              
                              return FutureBuilder<bool>(
                                future: securityProvider.hasPasscode,
                                builder: (context, hasPasscodeSnapshot) {
                                  if (!hasPasscodeSnapshot.hasData || !hasPasscodeSnapshot.data!) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  return FutureBuilder<bool>(
                                    future: securityProvider.isBiometricEnabled,
                                    builder: (context, biometricEnabledSnapshot) {
                                      if (!biometricEnabledSnapshot.hasData) {
                                        return const ListTile(
                                          title: Text('Xác thực sinh trắc học'),
                                          subtitle: Text('Đang tải...'),
                                          leading: Icon(Icons.fingerprint),
                                        );
                                      }
                                      
                                      return SwitchListTile(
                                        title: const Text('Xác thực sinh trắc học'),
                                        subtitle: const Text(
                                          'Sử dụng vân tay hoặc Face ID để mở khóa ghi chú',
                                        ),
                                        value: biometricEnabledSnapshot.data!,
                                        onChanged: (value) {
                                          securityProvider.setBiometricEnabled(value);
                                        },
                                        secondary: const Icon(Icons.fingerprint),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          // Thêm nút đăng xuất nếu cần
                          ListTile(
                            title: const Text('Đăng xuất'),
                            subtitle: const Text('Xóa dữ liệu đăng nhập'),
                            leading: const Icon(Icons.logout),
                            onTap: _logout,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Dữ liệu
              _buildSection(
                title: 'Dữ liệu',
                children: [
                  _buildDefaultCategorySelector(),
                  SwitchListTile(
                    title: const Text('Tự động sao lưu'),
                    subtitle: const Text('Sao lưu dữ liệu tự động mỗi ngày'),
                    value: settingsProvider.autoBackup,
                    onChanged: (value) => settingsProvider.setAutoBackup(value),
                    secondary: const Icon(Icons.backup),
                  ),
                  ListTile(
                    title: const Text('Sao lưu dữ liệu'),
                    subtitle: Text(
                      settingsProvider.lastBackupTime != null
                          ? 'Lần cuối: ${DateFormat('dd/MM/yyyy HH:mm').format(settingsProvider.lastBackupTime!)}'
                          : 'Chưa có sao lưu nào',
                    ),
                    leading: const Icon(Icons.save),
                    onTap: () {
                      // TODO: Thực hiện sao lưu dữ liệu
                      final now = DateTime.now();
                      settingsProvider.setLastBackupTime(now);
                    },
                  ),
                  ListTile(
                    title: const Text('Khôi phục dữ liệu'),
                    subtitle: const Text('Khôi phục từ bản sao lưu'),
                    leading: const Icon(Icons.restore),
                    onTap: () {
                      // TODO: Thực hiện khôi phục dữ liệu
                    },
                  ),
                  ListTile(
                    title: const Text('Xóa lịch sử tìm kiếm'),
                    subtitle: Text(
                      'Đã lưu ${settingsProvider.recentSearches.length} từ khóa tìm kiếm',
                    ),
                    leading: const Icon(Icons.history),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Xác nhận'),
                            content: const Text(
                              'Bạn có chắc muốn xóa lịch sử tìm kiếm không?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  settingsProvider.clearRecentSearches();
                                  Navigator.pop(context);
                                },
                                child: const Text('Xóa'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Đặt lại tất cả cài đặt'),
                    subtitle: const Text('Khôi phục về cài đặt mặc định'),
                    leading: const Icon(Icons.settings_backup_restore),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Xác nhận'),
                            content: const Text(
                              'Bạn có chắc muốn đặt lại tất cả cài đặt về mặc định không? '
                              'Dữ liệu ghi chú sẽ không bị mất.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  settingsProvider.resetAllSettings();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Đặt lại'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Thông tin
              _buildSection(
                title: 'Thông tin',
                children: [
                  const ListTile(
                    title: Text('Phiên bản'),
                    subtitle: Text('1.0.0'),
                    leading: Icon(Icons.info_outline),
                  ),
                  ListTile(
                    title: const Text('Giới thiệu'),
                    subtitle: const Text('Thông tin về ứng dụng'),
                    leading: const Icon(Icons.help_outline),
                    onTap: () {
                      // TODO: Hiển thị màn hình giới thiệu
                    },
                  ),
                  ListTile(
                    title: const Text('Đánh giá ứng dụng'),
                    subtitle: const Text('Cho chúng tôi biết ý kiến của bạn'),
                    leading: const Icon(Icons.star_outline),
                    onTap: () {
                      // TODO: Mở trang đánh giá
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildThemeSelector() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          title: const Text('Chủ đề'),
          subtitle: Text(
            themeProvider.themeMode == ThemeMode.light
                ? 'Sáng'
                : themeProvider.themeMode == ThemeMode.dark
                    ? 'Tối'
                    : 'Tự động',
          ),
          leading: const Icon(Icons.palette),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Chọn chủ đề'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Sáng'),
                        leading: const Icon(Icons.light_mode),
                        selected: themeProvider.themeMode == ThemeMode.light,
                        onTap: () {
                          themeProvider.setThemeMode(ThemeMode.light);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Tối'),
                        leading: const Icon(Icons.dark_mode),
                        selected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () {
                          themeProvider.setThemeMode(ThemeMode.dark);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Tự động'),
                        leading: const Icon(Icons.brightness_auto),
                        selected: themeProvider.themeMode == ThemeMode.system,
                        onTap: () {
                          themeProvider.setThemeMode(ThemeMode.system);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildFontSizeSlider() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          title: const Text('Cỡ chữ'),
          subtitle: Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 14,
                  max: 24,
                  divisions: 5,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                  onChangeEnd: (value) {
                    settingsProvider.setFontSize(value);
                  },
                ),
              ),
              Text('A', style: TextStyle(fontSize: _fontSize)),
            ],
          ),
          leading: const Icon(Icons.text_fields),
        );
      },
    );
  }
  
  Widget _buildViewModeSelector() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          title: const Text('Chế độ xem mặc định'),
          subtitle: Text(
            settingsProvider.defaultView == 'grid' ? 'Lưới' : 'Danh sách',
          ),
          leading: Icon(
            settingsProvider.defaultView == 'grid'
                ? Icons.grid_view
                : Icons.view_list,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Chọn chế độ xem mặc định'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Lưới'),
                        leading: const Icon(Icons.grid_view),
                        selected: settingsProvider.defaultView == 'grid',
                        onTap: () {
                          settingsProvider.setDefaultView('grid');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Danh sách'),
                        leading: const Icon(Icons.view_list),
                        selected: settingsProvider.defaultView == 'list',
                        onTap: () {
                          settingsProvider.setDefaultView('list');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildDefaultCategorySelector() {
    return Consumer2<SettingsProvider, NoteProvider>(
      builder: (context, settingsProvider, noteProvider, child) {
        final defaultCategoryId = settingsProvider.defaultCategory;
        
        return ListTile(
          title: const Text('Danh mục mặc định'),
          subtitle: FutureBuilder<Category?>(
            future: defaultCategoryId != null
                ? noteProvider.noteService.categoryRepository.getById(defaultCategoryId)
                : null,
            builder: (context, snapshot) {
              if (defaultCategoryId == null || !snapshot.hasData) {
                return const Text('Không có');
              }
              return Text(snapshot.data!.name);
            },
          ),
          leading: const Icon(Icons.category),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'Chọn danh mục mặc định',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Không có'),
                        selected: defaultCategoryId == null,
                        onTap: () {
                          settingsProvider.setDefaultCategory(null);
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: noteProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = noteProvider.categories[index];
                            return ListTile(
                              title: Text(category.name),
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.hexToColor(category.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              selected: category.id == defaultCategoryId,
                              onTap: () {
                                settingsProvider.setDefaultCategory(category.id);
                                Navigator.pop(context);
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
          },
        );
      },
    );
  }
  
  Widget _buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
    IconData? icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
      secondary: icon != null ? Icon(icon) : null,
    );
  }

  Future<void> _logout() async {
    final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
    securityProvider.logout();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bạn đã đăng xuất khỏi ứng dụng'),
      ),
    );
  }
} 