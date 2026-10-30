import 'dart:io';

import 'package:flutter/services.dart';

/// Opens the system screen for this app's notification settings (Android).
abstract final class NotificationSettingsOpener {
  static const _channel =
      MethodChannel('com.viktor.dv.simple_notifier/notifications');

  static Future<void> open() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('openNotificationSettings');
  }
}
