import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:simple_notifier/core/l10n/l10n_resolver.dart';
import 'package:simple_notifier/core/navigation/app_navigator.dart';
import 'package:simple_notifier/data/local/reminder_dao.dart';
import 'package:simple_notifier/features/reminder/edit_reminder_screen.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _reminderDao = ReminderDao();

  static const String _androidChannelId = 'reminders_v1';

  static String? _pendingReminderIdFromLaunch;
  static AppLocalizations? _cachedL10n;

  static void Function()? onNotificationStateChanged;

  static void setNotificationStateChangedHandler(void Function()? cb) {
    onNotificationStateChanged = cb;
  }

  static String encodePayload(String reminderId) => reminderId;

  static String? reminderIdFromPayload(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final i = raw.indexOf('|');
    if (i == -1) return raw;
    return raw.substring(0, i);
  }

  static Future<bool> init() async {
    _cachedL10n = await L10nResolver.load();
    final l10n = _cachedL10n!;

    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const settings = InitializationSettings(android: android);

    final channel = AndroidNotificationChannel(
      _androidChannelId,
      l10n.notificationChannelName,
      description: l10n.notificationChannelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final initOk = await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));

    final launchDetails = await _notifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final p = launchDetails!.notificationResponse?.payload;
      if (p != null && p.isNotEmpty) {
        _pendingReminderIdFromLaunch = reminderIdFromPayload(p);
      }
    }

    if (initOk != true) {
      developer.log(
        'flutter_local_notifications.initialize() returned false',
        name: 'NotificationService',
      );
    }

    await _ensureAndroidCanPostNotifications();
    return initOk ?? true;
  }

  static Future<void> refreshLocalization() async {
    _cachedL10n = await L10nResolver.load();
  }

  static AppLocalizations get _l10n =>
      _cachedL10n ?? lookupAppLocalizations(const Locale('en'));

  static void consumePendingLaunchNavigation() {
    final id = _pendingReminderIdFromLaunch;
    _pendingReminderIdFromLaunch = null;
    if (id == null || id.isEmpty) return;
    _openReminderEditor(id);
  }

  static void _onNotificationResponse(NotificationResponse details) {
    unawaited(_handleNotificationResponse(details));
  }

  static Future<void> _handleNotificationResponse(
    NotificationResponse details,
  ) async {
    await markDeliveredIfNeeded(details.payload);
    final id = reminderIdFromPayload(details.payload);
    if (id != null) {
      _openReminderEditor(id);
    }
  }

  static Future<void> markDeliveredIfNeeded(String? payload) async {
    final reminderId = reminderIdFromPayload(payload);
    if (reminderId == null) return;

    final r = await _reminderDao.getById(reminderId);
    if (r == null || r.notifDelivered) return;

    await _reminderDao.update(r.copyWith(notifDelivered: true));
    onNotificationStateChanged?.call();
  }

  static void _openReminderEditor(String reminderId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reminder = await _reminderDao.getById(reminderId);
      if (reminder == null) return;
      final nav = rootNavigatorKey.currentState;
      if (nav == null || !nav.context.mounted) return;
      await nav.push(
        MaterialPageRoute<void>(
          builder: (_) => EditReminderScreen(reminder: reminder),
        ),
      );
    });
  }

  static int buildNotificationId(String reminderId, int offset) {
    var hash = 0x811C9DC5;
    for (final unit in reminderId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash + offset;
  }

  static Future<void> _ensureAndroidCanPostNotifications() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    var enabled = await android.areNotificationsEnabled() ?? true;
    if (!enabled) {
      await android.requestNotificationsPermission();
      await android.areNotificationsEnabled();
    }

    await Future<void>.delayed(Duration.zero);
  }

  static AndroidBitmap<Object> _largeIconForReminder(String? imagePath) {
    if (imagePath != null && File(imagePath).existsSync()) {
      return FilePathAndroidBitmap(imagePath);
    }
    return const DrawableResourceAndroidBitmap('ic_app_default');
  }

  static NotificationDetails _reminderNotificationDetails({
    required String ticker,
    String? imagePath,
  }) {
    final l10n = _l10n;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        l10n.notificationChannelName,
        channelDescription: l10n.notificationChannelDescription,
        icon: 'ic_notification',
        largeIcon: _largeIconForReminder(imagePath),
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        ticker: ticker,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        channelAction: AndroidNotificationChannelAction.createIfNotExists,
      ),
    );
  }

  static Future<bool> requestExactAlarmsPermissionIfNeeded() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    final isGranted = await android.canScheduleExactNotifications();
    if (isGranted ?? false) return true;

    return await android.requestExactAlarmsPermission() ?? false;
  }

  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imagePath,
  }) async {
    await _ensureAndroidCanPostNotifications();
    await _notifications.show(
      id,
      title,
      body,
      _reminderNotificationDetails(ticker: title, imagePath: imagePath),
      payload: payload,
    );
  }

  static Future<bool> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
    String? imagePath,
  }) async {
    final tzNow = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime.from(date, tz.local);
    if (!when.isAfter(tzNow)) {
      if (date.isAfter(DateTime.now())) {
        when = tzNow.add(const Duration(seconds: 1));
      } else {
        return false;
      }
    }
    await _ensureAndroidCanPostNotifications();
    final mode = await _resolveScheduleMode();
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      when,
      _reminderNotificationDetails(ticker: title, imagePath: imagePath),
      androidScheduleMode: mode,
      payload: payload,
    );
    return true;
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static Future<AndroidScheduleMode> _resolveScheduleMode() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final exactGranted = await android.canScheduleExactNotifications();
    if (exactGranted ?? false) {
      return AndroidScheduleMode.alarmClock;
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }
}
