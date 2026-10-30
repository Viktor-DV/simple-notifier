import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_notifier/core/category_label.dart';
import 'package:simple_notifier/core/notifications/notification_service.dart';
import 'package:simple_notifier/core/theme/app_palette.dart';
import 'package:simple_notifier/domain/models/category.dart';
import 'package:simple_notifier/domain/models/reminder.dart';
import 'package:simple_notifier/features/reminder/add_reminder_screen.dart';
import 'package:simple_notifier/features/reminder/edit_reminder_screen.dart';
import 'package:simple_notifier/features/reminder/widgets/reminder_thumbnail.dart';
import 'package:simple_notifier/features/settings/settings_screen.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

import 'providers/filter_provider.dart';
import 'providers/reminders_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;

  bool get _searchExpanded =>
      _searchFocus.hasFocus || _searchController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _searchFocus.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.consumePendingLaunchNavigation();
      ref.read(remindersProvider.notifier).reconcilePastNotificationSlots();
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatReminderDate(DateTime date, Locale locale) {
    return DateFormat.yMMMd(locale.toString()).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final locale = Localizations.localeOf(context);
    final reminders = ref.watch(remindersProvider);
    final categories = ref.watch(categoriesProvider);

    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final sortType = ref.watch(sortTypeProvider);

    List<Reminder> filtered = reminders;

    if (selectedCategory != 'all') {
      filtered =
          filtered.where((r) => r.categoryId == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (r) => r.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    filtered.sort((a, b) {
      switch (sortType) {
        case SortType.dateAsc:
          return a.scheduledAt.compareTo(b.scheduledAt);
        case SortType.dateDesc:
          return b.scheduledAt.compareTo(a.scheduledAt);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;
                        final targetW = _searchExpanded
                            ? maxW
                            : math.min(132.0, maxW);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                          width: targetW,
                          height: 52,
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            decoration: InputDecoration(
                              hintText: l10n.searchHint,
                              prefixIcon:
                                  Icon(Icons.search, color: palette.accent),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (value) {
                              ref.read(searchQueryProvider.notifier).state =
                                  value;
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showSortBottomSheet(context),
                    tooltip: l10n.sortBy,
                    icon: Icon(Icons.sort_rounded, color: palette.accent),
                    style: IconButton.styleFrom(
                      foregroundColor: palette.accent,
                      backgroundColor: palette.backgroundSecondary,
                      side: BorderSide(color: palette.accent),
                      minimumSize: const Size(52, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    tooltip: l10n.settings,
                    icon: const Icon(Icons.settings_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: palette.accent,
                      backgroundColor: palette.backgroundSecondary,
                      side: BorderSide(color: palette.accent),
                      minimumSize: const Size(52, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: SizedBox(
                          height: 32,
                          width: 44,
                          child: ElevatedButton(
                            onPressed: () => _showAddCategoryDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.accent,
                              foregroundColor: palette.onAccent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Icon(Icons.add, size: 20),
                          ),
                        ),
                      ),
                    );
                  }

                  final category = categories[index - 1];
                  final isSelected = selectedCategory == category.id;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category.id;
                        },
                        onLongPress: () {
                          if (!category.isSystem) {
                            _showDeleteDialog(context, category);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? palette.accent
                                : palette.backgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            categoryDisplayName(category, l10n),
                            style: TextStyle(
                              color: isSelected
                                  ? palette.onAccent
                                  : palette.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final reminder = filtered[index];
                        final dateLabel =
                            _formatReminderDate(reminder.scheduledAt, locale);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      EditReminderScreen(reminder: reminder),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: palette.card,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  ReminderThumbnail(
                                    imagePath: reminder.imagePath,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reminder.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: palette.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          l10n.cardReminderDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: palette.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateLabel,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: palette.accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: palette.textSecondary,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(remindersProvider.notifier)
                                          .deleteReminder(reminder.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (filtered.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AddReminderScreen(),
                        ),
                      );
                    },
                    child: Text(l10n.addNew),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: filtered.isEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AddReminderScreen(),
                  ),
                );
              },
              backgroundColor: palette.accent,
              foregroundColor: palette.onAccent,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final palette = context.palette;
    SortType selectedSort = ref.read(sortTypeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.backgroundSecondary,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        final sheetL10n = AppLocalizations.of(sheetContext)!;
        final sheetPalette = sheetContext.palette;
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return SafeArea(
              top: false,
              child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      width: 42,
                      child: Divider(
                        thickness: 4,
                        color: sheetPalette.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      sheetL10n.sortBy,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: sheetPalette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  RadioGroup<SortType>(
                    groupValue: selectedSort,
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() => selectedSort = value);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<SortType>(
                          title: Text(sheetL10n.sortDateAsc),
                          value: SortType.dateAsc,
                          activeColor: sheetPalette.accent,
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<SortType>(
                          title: Text(sheetL10n.sortDateDesc),
                          value: SortType.dateDesc,
                          activeColor: sheetPalette.accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(sortTypeProvider.notifier).state =
                            selectedSort;
                        Navigator.pop(context);
                      },
                      child: Text(sheetL10n.apply),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.newCategory),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(categoriesProvider.notifier).addCategory(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteCategoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(remindersProvider.notifier).moveRemindersToAll(category.id);
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const double _headerHeight = 12 + 52 + 52;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final mq = MediaQuery.of(context);

    final iconSize = (shortestSide * 0.22).clamp(72.0, 120.0);
    final gapBelowIcon = (shortestSide * 0.04).clamp(12.0, 20.0);
    final titleSize = (shortestSide * 0.05).clamp(16.0, 22.0);
    final subtitleSize = (shortestSide * 0.04).clamp(14.0, 18.0);

    final fullH = mq.size.height;
    final topInset = mq.padding.top;
    final bottomInset = mq.padding.bottom;
    final safeCenterY = topInset + (fullH - topInset - bottomInset) / 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedCenterY =
            topInset + _headerHeight + constraints.maxHeight / 2;
        final dy = safeCenterY - expandedCenterY;

        return Transform.translate(
          offset: Offset(0, dy),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: iconSize,
                  color: palette.textSecondary.withValues(alpha: 0.55),
                ),
                SizedBox(height: gapBelowIcon),
                Text(
                  l10n.emptyListTitle,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.emptyListSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
