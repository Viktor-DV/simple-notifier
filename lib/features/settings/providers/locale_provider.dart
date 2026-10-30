import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocalePreference {
  system,
  english,
  russian;

  String get storageValue => switch (this) {
        AppLocalePreference.system => 'system',
        AppLocalePreference.english => 'en',
        AppLocalePreference.russian => 'ru',
      };

  static AppLocalePreference fromStorage(String? raw) {
    return switch (raw) {
      'en' => AppLocalePreference.english,
      'ru' => AppLocalePreference.russian,
      _ => AppLocalePreference.system,
    };
  }

  /// `null` means follow the device locale.
  Locale? get fixedLocale => switch (this) {
        AppLocalePreference.system => null,
        AppLocalePreference.english => const Locale('en'),
        AppLocalePreference.russian => const Locale('ru'),
      };
}

const _localeKey = 'app_locale_v1';

final localePreferenceProvider =
    StateNotifierProvider<LocalePreferenceNotifier, AppLocalePreference>(
  (ref) => LocalePreferenceNotifier(),
);

class LocalePreferenceNotifier extends StateNotifier<AppLocalePreference> {
  LocalePreferenceNotifier() : super(AppLocalePreference.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLocalePreference.fromStorage(prefs.getString(_localeKey));
  }

  Future<void> setPreference(AppLocalePreference value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value.storageValue);
  }

  static Future<Locale> resolveEffectiveLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final preference =
        AppLocalePreference.fromStorage(prefs.getString(_localeKey));
    final fixed = preference.fixedLocale;
    if (fixed != null) return fixed;

    final system = PlatformDispatcher.instance.locale;
    if (system.languageCode == 'ru') {
      return const Locale('ru');
    }
    return const Locale('en');
  }
}
