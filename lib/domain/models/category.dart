class Category {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isSystem;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    this.isSystem = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isSystem': isSystem ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      createdAt:
      DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isSystem: map['isSystem'] == 1,
    );
  }
}