class Reminder {
  final String id;
  final String title;
  final DateTime scheduledAt;
  final String categoryId;
  final String? imagePath;
  final DateTime createdAt;

  final bool notifUsesDefaultTime;
  final int? notifHour;
  final int? notifMinute;

  final bool notifDelivered;

  Reminder({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.categoryId,
    this.imagePath,
    required this.createdAt,
    this.notifUsesDefaultTime = true,
    this.notifHour,
    this.notifMinute,
    this.notifDelivered = false,
  });

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? scheduledAt,
    String? categoryId,
    String? imagePath,
    DateTime? createdAt,
    bool? notifUsesDefaultTime,
    int? notifHour,
    int? notifMinute,
    bool clearNotifHour = false,
    bool clearNotifMinute = false,
    bool? notifDelivered,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      categoryId: categoryId ?? this.categoryId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      notifUsesDefaultTime: notifUsesDefaultTime ?? this.notifUsesDefaultTime,
      notifHour: clearNotifHour ? null : (notifHour ?? this.notifHour),
      notifMinute:
          clearNotifMinute ? null : (notifMinute ?? this.notifMinute),
      notifDelivered: notifDelivered ?? this.notifDelivered,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'scheduledAt': scheduledAt.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'imagePath': imagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'notifUsesDefaultTime': notifUsesDefaultTime ? 1 : 0,
      'notifHour': notifHour,
      'notifMinute': notifMinute,
      'notifDelivered': notifDelivered ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    final usesDefault = (map['notifUsesDefaultTime'] as int? ?? 1) != 0;
    final delivered = map['notifDelivered'] as int?;
    final legacyDay = map['notifDayDelivered'] as int?;
    final legacyAdvance = map['notifAdvanceDelivered'] as int?;

    return Reminder(
      id: map['id'] as String,
      title: (map['title'] ?? map['name']) as String,
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(
        (map['scheduledAt'] ?? map['expirationDate']) as int,
      ),
      categoryId: map['categoryId'] as String,
      imagePath: map['imagePath'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      notifUsesDefaultTime: usesDefault,
      notifHour: map['notifHour'] as int?,
      notifMinute: map['notifMinute'] as int?,
      notifDelivered: delivered != null
          ? delivered != 0
          : ((legacyDay ?? legacyAdvance ?? 0) != 0),
    );
  }
}
