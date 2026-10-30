import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_notifier/core/theme/app_palette.dart';
import 'package:simple_notifier/domain/models/reminder.dart';
import 'package:simple_notifier/features/home/providers/reminders_provider.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

import 'widgets/category_radio_group.dart';
import 'widgets/reminder_notification_time_field.dart';

class EditReminderScreen extends ConsumerStatefulWidget {
  final Reminder reminder;

  const EditReminderScreen({super.key, required this.reminder});

  @override
  ConsumerState<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends ConsumerState<EditReminderScreen> {
  late TextEditingController titleController;
  late DateTime selectedDate;
  late String selectedCategory;
  String? imagePath;

  late bool notifUsesDefaultTime;
  late int? notifHour;
  late int? notifMinute;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    titleController = TextEditingController(text: r.title);
    selectedDate = r.scheduledAt;
    selectedCategory = r.categoryId;
    imagePath = r.imagePath;
    notifUsesDefaultTime = r.notifUsesDefaultTime;
    notifHour = r.notifHour;
    notifMinute = r.notifMinute;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final categories = ref.watch(categoriesProvider);
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final hPad = (shortestSide * 0.042).clamp(14.0, 20.0);
    final blockGap = (shortestSide * 0.042).clamp(14.0, 18.0);
    final photoHeight = (shortestSide * 0.40).clamp(140.0, 190.0);
    final iconButtonSize = (shortestSide * 0.12).clamp(42.0, 52.0);
    final sectionTitleSize = (shortestSide * 0.058).clamp(26.0, 34.0) / 2;
    final textSize = (shortestSide * 0.05).clamp(22.0, 30.0) / 2;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editReminder)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addPhoto,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  fontSize: sectionTitleSize,
                ),
              ),
              SizedBox(height: blockGap / 2),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: photoHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: palette.backgroundSecondary,
                    border: Border.all(color: palette.accent),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: imagePath == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: palette.accent,
                                  size: iconButtonSize * 0.55),
                              const SizedBox(height: 8),
                              Text(l10n.addPhoto),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            Image.file(
                              File(imagePath!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: SizedBox(
                                width: iconButtonSize,
                                height: iconButtonSize,
                                child: IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: palette.accent,
                                    foregroundColor: palette.onAccent,
                                  ),
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    setState(() => imagePath = null);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: blockGap),
              Text(
                l10n.reminderTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  fontSize: sectionTitleSize,
                ),
              ),
              SizedBox(height: blockGap / 2),
              TextField(
                controller: titleController,
                maxLength: 80,
                style: TextStyle(fontSize: textSize),
                decoration: InputDecoration(
                  hintText: l10n.reminderTitleHint,
                  counterText: '',
                ),
              ),
              SizedBox(height: blockGap),
              Text(
                l10n.reminderDate,
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
                    '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                    style: TextStyle(fontSize: textSize),
                  ),
                  trailing: Icon(Icons.calendar_today, color: palette.accent),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
              ),
              SizedBox(height: blockGap),
              ReminderNotificationTimeField(
                l10n: l10n,
                usesDefaultTime: notifUsesDefaultTime,
                customHour: notifHour,
                customMinute: notifMinute,
                sectionTitleSize: sectionTitleSize,
                textSize: textSize,
                blockGap: blockGap,
                onChanged: ({
                  required bool usesDefaultTime,
                  int? hour,
                  int? minute,
                }) {
                  setState(() {
                    notifUsesDefaultTime = usesDefaultTime;
                    notifHour = hour;
                    notifMinute = minute;
                  });
                },
              ),
              SizedBox(height: blockGap),
              Text(
                l10n.category,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  fontSize: sectionTitleSize,
                ),
              ),
              SizedBox(height: blockGap / 2),
              CategoryRadioGroup(
                categories: categories,
                l10n: l10n,
                selectedCategoryId: selectedCategory,
                onCategorySelected: (id) {
                  setState(() => selectedCategory = id);
                },
              ),
              TextButton(
                onPressed: () => _showAddCategoryDialog(context, l10n),
                child: Text(
                  l10n.addNewCategory,
                  style: TextStyle(color: palette.accent, fontSize: textSize),
                ),
              ),
              SizedBox(height: blockGap),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: palette.backgroundPrimary,
          border: Border(top: BorderSide(color: palette.backgroundSecondary)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(hPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(l10n.save),
                  ),
                ),
                SizedBox(height: blockGap / 2),
                TextButton(
                  onPressed: () {
                    ref
                        .read(remindersProvider.notifier)
                        .deleteReminder(widget.reminder.id);
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.deleteReminder,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => imagePath = file.path);
    }
  }

  void _showAddCategoryDialog(BuildContext context, AppLocalizations l10n) {
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

  void _save() {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    final updated = Reminder(
      id: widget.reminder.id,
      title: title,
      scheduledAt: selectedDate,
      categoryId: selectedCategory,
      imagePath: imagePath,
      createdAt: widget.reminder.createdAt,
      notifUsesDefaultTime: notifUsesDefaultTime,
      notifHour: notifUsesDefaultTime ? null : notifHour,
      notifMinute: notifUsesDefaultTime ? null : notifMinute,
      notifDelivered: widget.reminder.notifDelivered,
    );

    ref.read(remindersProvider.notifier).updateReminder(updated);
    Navigator.pop(context);
  }
}
