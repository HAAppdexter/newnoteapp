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
    return RepaintBoundary(
      child: Card(
        // Sử dụng màu từ note nếu được đặt, ngược lại sử dụng Card mặc định
        color: note.color != null ? Color(int.parse(note.color!.replaceFirst('#', '0xff'))) : null,
        elevation: note.isPinned ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị tiêu đề
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                if (note.title.isNotEmpty)
                  const SizedBox(height: 8),
                
                // Hiển thị nội dung
                Expanded(
                  child: Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Hiển thị ngày cập nhật và các icon trạng thái
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Tạo footer cho card
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Ngày cập nhật được format
        Expanded(
          child: Text(
            _getFormattedDate(note.updatedAt),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        
        // Icon thể hiện trạng thái
        _buildStatusIcons(context),
      ],
    );
  }
  
  // Tạo các icon thể hiện trạng thái của note
  Widget _buildStatusIcons(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final iconSize = 16.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (note.isPinned)
          Icon(
            Icons.push_pin,
            size: iconSize,
            color: iconColor,
          ),
          
        if (note.isProtected)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.lock,
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
      return DateFormat('EEEE, HH:mm', 'vi_VN').format(date);
    } else {
      // Các ngày khác
      return DateFormat('dd/MM/y, HH:mm').format(date);
    }
  }
} 