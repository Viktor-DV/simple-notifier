import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_notifier/core/l10n/l10n_resolver.dart';
import 'package:simple_notifier/core/notifications/notification_service.dart';
import 'package:simple_notifier/core/notifications/notification_time_utils.dart';
import 'package:simple_notifier/features/home/providers/settings_provider.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/category_dao.dart';
import '../../../data/local/reminder_dao.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/reminder.dart';

const uuid = Uuid();

final reminderDao = ReminderDao();
final categoryDao = CategoryDao();

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>(
  (ref) => CategoriesNotifier(),
);

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([]) {
    load();
  }

  static Category defaultCategory() => Category(
        id: 'all',
        name: 'all',
        createdAt: DateTime.now(),
        isSystem: true,
      );

  Future<void> load() async {
    final data = await categoryDao.getAll();
    if (data.isEmpty) {
      await categoryDao.insert(defaultCategory());
      state = [defaultCategory()];
    } else {
      state = data;
    }
  }

  Future<void> addCategory(String name) async {
    final newCategory = Category(
      id: uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await categoryDao.insert(newCategory);
    state = [...state, newCategory];
  }

  Future<void> deleteCategory(String id) async {
    await categoryDao.delete(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>(
  (ref) => RemindersNotifier(ref),
);

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  final Ref ref;

  static const int _notificationOffset = 0;

  RemindersNotifier(this.ref) : super([]) {
    NotificationService.setNotificationStateChangedHandler(() {
      Future.microtask(() => load());
    });
    load();
  }

  Future<void> load() async {
    state = await reminderDao.getAll();
  }

  Future<void> reconcilePastNotificationSlots() async {
    final now = DateTime.now();
    final all = await reminderDao.getAll();
    final defaultTime = ref.read(notificationTimeProvider);
    var any = false;

    for (final r in all) {
      final fireAt = r.notificationDateTimeOn(r.scheduledAt, defaultTime);
      if (!r.notifDelivered && !fireAt.isAfter(now)) {
        await reminderDao.update(r.copyWith(notifDelivered: true));
        any = true;
      }
    }

    if (any) await load();
  }

  bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _cancelNotification(String id) async {
    await NotificationService.cancel(
      NotificationService.buildNotificationId(id, _notificationOffset),
    );
  }

  Future<void> _syncReminderNotifications(
    Reminder reminder,
    AppLocalizations l10n,
  ) async {
    await _cancelNotification(reminder.id);

    final defaultTime = ref.read(notificationTimeProvider);
    final now = DateTime.now();
    final fireAt = reminder.notificationDateTimeOn(
      reminder.scheduledAt,
      defaultTime,
    );

    var r = reminder;
    if (r.notifDelivered) return;

    final id = NotificationService.buildNotificationId(
      r.id,
      _notificationOffset,
    );
    final payload = NotificationService.encodePayload(r.id);
    final title = l10n.notificationTitle;
    final body = l10n.notificationBody(r.title);

    if (fireAt.isAfter(now)) {
      final scheduled = await NotificationService.schedule(
        id: id,
        title: title,
        body: body,
        date: fireAt,
        payload: payload,
        imagePath: r.imagePath,
      );
      if (!scheduled && fireAt.isAfter(DateTime.now())) {
        await NotificationService.showNow(
          id: id,
          title: title,
          body: body,
          payload: payload,
          imagePath: r.imagePath,
        );
        r = r.copyWith(notifDelivered: true);
        await reminderDao.update(r);
        state = state.map((x) => x.id == r.id ? r : x).toList();
      }
      return;
    }

    await NotificationService.showNow(
      id: id,
      title: title,
      body: body,
      payload: payload,
      imagePath: r.imagePath,
    );
    r = r.copyWith(notifDelivered: true);
    await reminderDao.update(r);
    state = state.map((x) => x.id == r.id ? r : x).toList();
  }

  Future<void> _runNotificationsSafely(Future<void> Function() action) async {
    try {
      await action();
    } catch (e, st) {
      developer.log(
        'Notification flow error',
        name: 'RemindersNotifier',
        error: e,
        stackTrace: st,
        level: 1000,
      );
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    final l10n = await L10nResolver.load();
    await reminderDao.insert(reminder);
    state = [...state, reminder];
    await _runNotificationsSafely(
      () => _syncReminderNotifications(reminder, l10n),
    );
  }

  Future<void> deleteReminder(String id) async {
    await reminderDao.delete(id);
    state = state.where((r) => r.id != id).toList();
    await _runNotificationsSafely(() => _cancelNotification(id));
  }

  Future<void> updateReminder(Reminder updated) async {
    final l10n = await L10nResolver.load();
    final matches = state.where((x) => x.id == updated.id);
    final prev = matches.isEmpty ? null : matches.first;

    var toSave = updated;
    if (prev != null &&
        !_sameCalendarDay(prev.scheduledAt, updated.scheduledAt)) {
      toSave = updated.copyWith(notifDelivered: false);
    }

    await reminderDao.update(toSave);
    state = state.map((r) => r.id == toSave.id ? toSave : r).toList();
    await _runNotificationsSafely(
      () => _syncReminderNotifications(toSave, l10n),
    );
  }

  Future<void> moveRemindersToAll(String categoryId) async {
    final updated = state.map((r) {
      if (r.categoryId == categoryId) {
        return r.copyWith(categoryId: 'all');
      }
      return r;
    }).toList();

    for (final r in updated) {
      await reminderDao.update(r);
    }
    state = updated;
  }

  Future<void> rescheduleAll() async {
    final l10n = await L10nResolver.load();
    final reminders = await reminderDao.getAll();
    await _runNotificationsSafely(() async {
      for (final r in reminders) {
        await _syncReminderNotifications(r, l10n);
      }
    });
  }

  Future<void> rescheduleRemindersUsingDefaultNotificationTime() async {
    final l10n = await L10nResolver.load();
    final defaultOnly = state.where((r) => r.notifUsesDefaultTime).toList();
    await _runNotificationsSafely(() async {
      for (final r in defaultOnly) {
        await _syncReminderNotifications(r, l10n);
      }
    });
  }
}
