import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simple_notifier/core/notifications/notification_service.dart';
import 'package:simple_notifier/core/notifications/notification_settings_opener.dart';
import 'package:simple_notifier/core/notifications/notification_time_utils.dart';
import 'package:simple_notifier/core/theme/app_palette.dart';
import 'package:simple_notifier/features/home/providers/reminders_provider.dart';
import 'package:simple_notifier/features/home/providers/settings_provider.dart';
import 'package:simple_notifier/features/settings/providers/locale_provider.dart';
import 'package:simple_notifier/features/settings/providers/theme_mode_provider.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final selectedTheme = ref.watch(themePreferenceProvider);
    final selectedLocale = ref.watch(localePreferenceProvider);
    final defaultTime = ref.watch(notificationTimeProvider);
    final timeLabel = TimeOfDay(
      hour: defaultTime.hour,
      minute: defaultTime.minute,
    ).format(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _sectionHeader(l10n.settingsLanguage, palette),
          RadioGroup<AppLocalePreference>(
            groupValue: selectedLocale,
            onChanged: (value) async {
              if (value == null) return;
              await ref.read(localePreferenceProvider.notifier).setPreference(value);
              await NotificationService.refreshLocalization();
            },
            child: Column(
              children: [
                _localeTile(l10n, palette, AppLocalePreference.system, l10n.languageSystem, l10n.languageSystemSubtitle),
                _localeTile(l10n, palette, AppLocalePreference.english, l10n.languageEnglish, null),
                _localeTile(l10n, palette, AppLocalePreference.russian, l10n.languageRussian, null),
              ],
            ),
          ),
          const Divider(height: 32),
          _sectionHeader(l10n.settingsNotifications, palette),
          ListTile(
            leading: Icon(Icons.schedule_rounded, color: palette.accent),
            title: Text(
              l10n.settingsDefaultNotificationTime,
              style: TextStyle(color: palette.textPrimary),
            ),
            subtitle: Text(
              l10n.settingsDefaultNotificationTimeSubtitle,
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
            trailing: Text(
              timeLabel,
              style: TextStyle(
                color: palette.accent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            onTap: () async {
              final picked = await pickNotificationTime(
                context,
                initialTime: TimeOfDay(
                  hour: defaultTime.hour,
                  minute: defaultTime.minute,
                ),
              );
              if (picked == null) return;
              await ref
                  .read(notificationTimeProvider.notifier)
                  .setTime(picked.hour, picked.minute);
              await NotificationService.refreshLocalization();
              await ref
                  .read(remindersProvider.notifier)
                  .rescheduleRemindersUsingDefaultNotificationTime();
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_rounded, color: palette.accent),
            title: Text(
              l10n.settingsCheckNotificationPermission,
              style: TextStyle(color: palette.textPrimary),
            ),
            subtitle: Text(
              l10n.settingsCheckNotificationPermissionSubtitle,
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
            onTap: NotificationSettingsOpener.open,
          ),
          const Divider(height: 32),
          _sectionHeader(l10n.settingsAppearance, palette),
          RadioGroup<AppThemePreference>(
            groupValue: selectedTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(themePreferenceProvider.notifier).setPreference(value);
              }
            },
            child: Column(
              children: [
                _themeTile(l10n, palette, AppThemePreference.system, l10n.themeSystem, l10n.themeSystemSubtitle),
                _themeTile(l10n, palette, AppThemePreference.light, l10n.themeLight, null),
                _themeTile(l10n, palette, AppThemePreference.dark, l10n.themeDark, null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          color: palette.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  RadioListTile<AppLocalePreference> _localeTile(
    AppLocalizations l10n,
    AppPalette palette,
    AppLocalePreference value,
    String title,
    String? subtitle,
  ) {
    return RadioListTile<AppLocalePreference>(
      title: Text(title, style: TextStyle(color: palette.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: palette.textSecondary, fontSize: 13))
          : null,
      value: value,
      activeColor: palette.accent,
    );
  }

  RadioListTile<AppThemePreference> _themeTile(
    AppLocalizations l10n,
    AppPalette palette,
    AppThemePreference value,
    String title,
    String? subtitle,
  ) {
    return RadioListTile<AppThemePreference>(
      title: Text(title, style: TextStyle(color: palette.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: palette.textSecondary, fontSize: 13))
          : null,
      value: value,
      activeColor: palette.accent,
    );
  }
}
