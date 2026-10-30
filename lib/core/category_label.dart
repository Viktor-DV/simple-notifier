import 'package:simple_notifier/domain/models/category.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

String categoryDisplayName(Category category, AppLocalizations l10n) {
  if (category.id == 'all') return l10n.allCategory;
  return category.name;
}
