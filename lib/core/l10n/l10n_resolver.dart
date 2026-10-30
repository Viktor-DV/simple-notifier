import 'package:simple_notifier/features/settings/providers/locale_provider.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

/// Resolves localized strings outside of widget tree (e.g. notification scheduling).
abstract final class L10nResolver {
  static Future<AppLocalizations> load() async {
    final locale = await LocalePreferenceNotifier.resolveEffectiveLocale();
    return lookupAppLocalizations(locale);
  }
}
