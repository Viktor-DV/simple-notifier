import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationTimeProvider =
StateNotifierProvider<NotificationTimeNotifier, DateTime>(
      (ref) => NotificationTimeNotifier(),
);

class NotificationTimeNotifier extends StateNotifier<DateTime> {
  NotificationTimeNotifier() : super(_defaultTime) {
    load();
  }

  static final _defaultTime = DateTime(0, 0, 0, 10, 0); // 10:00

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final hour = prefs.getInt('notif_hour') ?? 10;
    final minute = prefs.getInt('notif_minute') ?? 0;

    state = DateTime(0, 0, 0, hour, minute);
  }

  Future<void> setTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('notif_hour', hour);
    await prefs.setInt('notif_minute', minute);

    state = DateTime(0, 0, 0, hour, minute);
  }
}