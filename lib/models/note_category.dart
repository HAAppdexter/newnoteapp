class NoteCategory {
  final String id;
  final String noteId;
  final String categoryId;

  NoteCategory({
    required this.id,
    required this.noteId,
    required this.categoryId,
  });

  // Chuyển đổi từ Map thành NoteCategory object (khi đọc từ database)
  factory NoteCategory.fromMap(Map<String, dynamic> map) {
    return NoteCategory(
      id: map['id'],
      noteId: map['note_id'],
      categoryId: map['category_id'],
    );
  }

  // Chuyển đổi NoteCategory object thành Map (khi ghi vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'category_id': categoryId,
    };
  }
} 