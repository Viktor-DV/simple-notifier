import 'package:flutter/material.dart';

import 'package:simple_notifier/core/theme/app_palette.dart';
import 'package:simple_notifier/domain/models/reminder.dart';

class NotificationTimeOfDay {
  const NotificationTimeOfDay({required this.hour, required this.minute});

  final int hour;
  final int minute;

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  static NotificationTimeOfDay fromSettings(DateTime settingsTime) {
    return NotificationTimeOfDay(
      hour: settingsTime.hour,
      minute: settingsTime.minute,
    );
  }
}

extension ReminderNotificationTimeX on Reminder {
  NotificationTimeOfDay effectiveNotificationTime(DateTime defaultSettingsTime) {
    if (notifUsesDefaultTime) {
      return NotificationTimeOfDay.fromSettings(defaultSettingsTime);
    }
    return NotificationTimeOfDay(
      hour: notifHour ?? defaultSettingsTime.hour,
      minute: notifMinute ?? defaultSettingsTime.minute,
    );
  }

  DateTime notificationDateTimeOn(
    DateTime calendarDay,
    DateTime defaultSettingsTime,
  ) {
    final t = effectiveNotificationTime(defaultSettingsTime);
    return DateTime(
      calendarDay.year,
      calendarDay.month,
      calendarDay.day,
      t.hour,
      t.minute,
    );
  }
}

Future<TimeOfDay?> pickNotificationTime(
  BuildContext context, {
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (pickerContext, child) {
      final palette = pickerContext.palette;
      final base = Theme.of(pickerContext);
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: palette.accent,
            surface: palette.backgroundSecondary,
          ),
        ),
        child: child!,
      );
    },
  );
}
