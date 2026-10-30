import 'package:flutter/material.dart';

import 'package:simple_notifier/core/category_label.dart';
import 'package:simple_notifier/core/theme/app_palette.dart';
import 'package:simple_notifier/domain/models/category.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

class CategoryRadioGroup extends StatelessWidget {
  const CategoryRadioGroup({
    super.key,
    required this.categories,
    required this.l10n,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<Category> categories;
  final AppLocalizations l10n;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return RadioGroup<String>(
      groupValue: selectedCategoryId,
      onChanged: (value) {
        if (value != null) onCategorySelected(value);
      },
      child: Column(
        children: [
          for (final c in categories)
            RadioListTile<String>(
              activeColor: palette.accent,
              tileColor: palette.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(categoryDisplayName(c, l10n)),
              value: c.id,
            ),
        ],
      ),
    );
  }
}
