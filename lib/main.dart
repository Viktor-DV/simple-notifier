import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simple_notifier/core/navigation/app_navigator.dart';
import 'package:simple_notifier/core/notifications/notification_service.dart';
import 'package:simple_notifier/core/theme/app_system_ui.dart';
import 'package:simple_notifier/core/theme/app_theme.dart';
import 'package:simple_notifier/features/settings/providers/locale_provider.dart';
import 'package:simple_notifier/features/settings/providers/theme_mode_provider.dart';
import 'package:simple_notifier/features/startup/startup_flow_screen.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppSystemUi.applyForBrightness(
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );

  final notificationsOk = await NotificationService.init();
  if (!notificationsOk) {
    debugPrint(
      'simple_notifier: NotificationService.init() failed; local notifications may not work.',
    );
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themePreferenceProvider);
    final localePreference = ref.watch(localePreferenceProvider);

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themePreference.themeMode,
      locale: localePreference.fixedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (localePreference != AppLocalePreference.system) {
          return localePreference.fixedLocale;
        }
        if (locale != null && locale.languageCode == 'ru') {
          return const Locale('ru');
        }
        return const Locale('en');
      },
      builder: (context, child) {
        AppSystemUi.applyFromContext(context);
        return child ?? const SizedBox.shrink();
      },
      home: const StartupFlowScreen(),
    );
  }
}
