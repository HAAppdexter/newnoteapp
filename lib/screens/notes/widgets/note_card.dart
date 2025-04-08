import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newnoteapp/models/note.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Tối ưu việc render khi có nhiều card
    Color cardColor = note.color.isNotEmpty 
        ? Color(int.parse(note.color.replaceAll('#', '0xFF'))) 
        : Colors.white;
    
    // Xác định màu chữ tương phản với màu nền
    Color textColor = _getContrastColor(cardColor);
    
    return RepaintBoundary(
      child: Card(
        color: cardColor,
        elevation: note.isPinned ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với tiêu đề và icon trạng thái
                _buildHeader(textColor),
                
                const SizedBox(height: 8),
                
                // Nội dung chính của note
                Expanded(
                  child: _buildContent(textColor),
                ),
                
                const SizedBox(height: 8),
                
                // Footer với ngày và các thông tin khác
                _buildFooter(context, textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Xây dựng header với tiêu đề và icon
  Widget _buildHeader(Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị tiêu đề
        Expanded(
          child: Text(
            note.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Hiển thị sao cho ghi chú yêu thích
        if (note.isPinned)
          Icon(
            Icons.star,
            size: 18,
            color: Colors.amber,
          ),
      ],
    );
  }
  
  // Xây dựng nội dung theo loại ghi chú
  Widget _buildContent(Color textColor) {
    // Kiểm tra nếu nội dung có dạng danh sách
    if (_isChecklistContent(note.content)) {
      return _buildChecklistContent(textColor);
    }
    
    // Kiểm tra nếu có URL hình ảnh trong nội dung
    if (_containsImageUrl(note.content)) {
      return _buildRichContent(textColor);
    }
    
    // Nếu là ghi chú văn bản bình thường
    return Text(
      note.content,
      style: TextStyle(
        fontSize: 14,
        color: textColor.withOpacity(0.9),
      ),
      maxLines: 7,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  // Xây dựng footer với ngày và các icon
  Widget _buildFooter(BuildContext context, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ngày cập nhật được format
        Text(
          _getFormattedDate(note.updatedAt),
          style: TextStyle(
            fontSize: 11,
            color: textColor.withOpacity(0.7),
          ),
        ),
        
        // Icon thể hiện trạng thái
        _buildStatusIcons(textColor),
      ],
    );
  }
  
  // Xây dựng ghi chú dạng danh sách
  Widget _buildChecklistContent(Color textColor) {
    List<String> lines = note.content.split('\n');
    List<Widget> checklistItems = [];
    
    // Giới hạn số lượng item hiển thị
    int itemsToShow = lines.length > 5 ? 5 : lines.length;
    
    for (int i = 0; i < itemsToShow; i++) {
      String line = lines[i];
      bool isChecked = line.startsWith('- [x]') || line.startsWith('* [x]');
      String itemText = line.replaceAll(RegExp(r'- \[[ x]\]|\* \[[ x]\]'), '').trim();
      
      checklistItems.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 14,
              color: textColor.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                itemText,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.9),
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
      
      if (i < itemsToShow - 1) {
        checklistItems.add(const SizedBox(height: 4));
      }
    }
    
    // Hiển thị "...và X mục khác" nếu có nhiều mục
    if (lines.length > itemsToShow) {
      checklistItems.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '...và ${lines.length - itemsToShow} mục khác',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: checklistItems,
    );
  }
  
  // Xây dựng ghi chú có hình ảnh
  Widget _buildRichContent(Color textColor) {
    // Đây chỉ là mô phỏng cho màn hình demo
    // Trong thực tế, bạn sẽ cần phân tích nội dung để tìm URL và hiển thị hình ảnh
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            note.content,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.9),
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (_containsImageUrl(note.content)) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.image,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  // Tạo các icon thể hiện trạng thái của note
  Widget _buildStatusIcons(Color textColor) {
    final iconSize = 16.0;
    final iconColor = textColor.withOpacity(0.7);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (note.isProtected)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.lock,
              size: iconSize,
              color: iconColor,
            ),
          ),
          
        // Hiển thị icon theo loại ghi chú
        if (_isChecklistContent(note.content))
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.check_circle_outline,
              size: iconSize,
              color: iconColor,
            ),
          )
        else if (_containsImageUrl(note.content))
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.image,
              size: iconSize,
              color: iconColor,
            ),
          ),
      ],
    );
  }
  
  // Format ngày tháng
  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final noteDate = DateTime(date.year, date.month, date.day);
    
    if (noteDate == DateTime(now.year, now.month, now.day)) {
      // Hôm nay
      return 'Hôm nay, ${DateFormat.Hm().format(date)}';
    } else if (noteDate == yesterday) {
      // Hôm qua
      return 'Hôm qua, ${DateFormat.Hm().format(date)}';
    } else if (now.difference(date).inDays < 7) {
      // Trong tuần này
      return DateFormat('E').format(date) + ', ' + DateFormat.Hm().format(date);
    } else {
      // Các ngày khác
      return DateFormat('dd/MM/y').format(date);
    }
  }
  
  // Kiểm tra xem nội dung có phải dạng danh sách không
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
  
  // Kiểm tra xem nội dung có chứa URL hình ảnh không
  bool _containsImageUrl(String content) {
    // Đơn giản hóa: Kiểm tra nếu có đuôi .jpg, .png, .gif trong nội dung
    return content.contains(RegExp(r'https?:\/\/.*?\.(jpg|jpeg|png|gif)', caseSensitive: false));
  }
  
  // Tính toán màu chữ tương phản với màu nền
  Color _getContrastColor(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
} 