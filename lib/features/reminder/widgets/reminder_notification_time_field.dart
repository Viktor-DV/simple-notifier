import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simple_notifier/core/notifications/notification_time_utils.dart';
import 'package:simple_notifier/core/theme/app_palette.dart';
import 'package:simple_notifier/features/home/providers/settings_provider.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

class ReminderNotificationTimeField extends ConsumerWidget {
  const ReminderNotificationTimeField({
    super.key,
    required this.l10n,
    required this.usesDefaultTime,
    required this.customHour,
    required this.customMinute,
    required this.onChanged,
    required this.sectionTitleSize,
    required this.textSize,
    required this.blockGap,
  });

  final AppLocalizations l10n;
  final bool usesDefaultTime;
  final int? customHour;
  final int? customMinute;
  final void Function({
    required bool usesDefaultTime,
    int? hour,
    int? minute,
  }) onChanged;

  final double sectionTitleSize;
  final double textSize;
  final double blockGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final defaultTime = ref.watch(notificationTimeProvider);
    final effective = usesDefaultTime
        ? TimeOfDay(hour: defaultTime.hour, minute: defaultTime.minute)
        : TimeOfDay(
            hour: customHour ?? defaultTime.hour,
            minute: customMinute ?? defaultTime.minute,
          );
    final timeLabel = effective.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notificationTime,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
            fontSize: sectionTitleSize,
          ),
        ),
        SizedBox(height: blockGap / 2),
        Container(
          decoration: BoxDecoration(
            color: palette.backgroundSecondary,
            border: Border.all(color: palette.accent),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            title: Text(
              timeLabel,
              style: TextStyle(
                fontSize: textSize,
                color: palette.textPrimary,
              ),
            ),
            subtitle: Text(
              usesDefaultTime
                  ? l10n.notificationTimeAppDefault
                  : l10n.notificationTimeCustom,
              style: TextStyle(
                fontSize: textSize * 0.85,
                color: palette.textSecondary,
              ),
            ),
            trailing: Icon(Icons.schedule, color: palette.accent),
            onTap: () async {
              final picked = await pickNotificationTime(
                context,
                initialTime: effective,
              );
              if (picked == null) return;
              onChanged(
                usesDefaultTime: false,
                hour: picked.hour,
                minute: picked.minute,
              );
            },
          ),
        ),
        if (!usesDefaultTime)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                onChanged(usesDefaultTime: true, hour: null, minute: null);
              },
              child: Text(
                l10n.useAppDefaultTime,
                style: TextStyle(color: palette.accent, fontSize: textSize),
              ),
            ),
          ),
      ],
    );
  }
}
