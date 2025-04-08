class Category {
  final String id;
  String name;
  String color;
  int orderIndex;
  final DateTime createdAt;
  DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.color,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tạo một Category mới
  factory Category.create({
    required String id,
    required String name,
    String color = '#5D9CEC',
    int orderIndex = 0,
  }) {
    final now = DateTime.now();
    return Category(
      id: id,
      name: name,
      color: color,
      orderIndex: orderIndex,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Chuyển đổi từ Map thành Category object (khi đọc từ database)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'] ?? '#5D9CEC',
      orderIndex: map['order_index'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // Chuyển đổi Category object thành Map (khi ghi vào database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'order_index': orderIndex,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Tạo bản sao của Category với các giá trị mới
  Category copyWith({
    String? name,
    String? color,
    int? orderIndex,
  }) {
    return Category(
      id: this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 