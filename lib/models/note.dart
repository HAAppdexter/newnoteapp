class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  String color;
  bool isPinned;
  bool isArchived;
  bool isDeleted;
  DateTime? deletedAt;
  bool isProtected;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.color = '#FFFFFF',
    this.isPinned = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.deletedAt,
    this.isProtected = false,
  });

  // Tạo một Note mới
  factory Note.create({
    required String id,
    String title = '',
    String content = '',
    String color = '#FFFFFF',
    bool isPinned = false,
    bool isProtected = false,
  }) {
    final now = DateTime.now();
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      color: color,
      isPinned: isPinned,
      isProtected: isProtected,
    );
  }

  // Chuyển đổi từ Map thành Note object (khi đọc từ database)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      color: map['color'] ?? '#FFFFFF',
      isPinned: map['is_pinned'] == 1,
      isArchived: map['is_archived'] == 1,
      isDeleted: map['is_deleted'] == 1,
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deleted_at'])
          : null,
      isProtected: map['is_protected'] == 1,
    );
  }

  // Chuyển đổi Note object thành Map (khi ghi vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'color': color,
      'is_pinned': isPinned ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
      'is_protected': isProtected ? 1 : 0,
    };
  }

  // Tạo bản sao của Note với các giá trị mới
  Note copyWith({
    String? title,
    String? content,
    String? color,
    bool? isPinned,
    bool? isArchived,
    bool? isDeleted,
    DateTime? deletedAt,
    bool? isProtected,
  }) {
    return Note(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isProtected: isProtected ?? this.isProtected,
    );
  }
} 