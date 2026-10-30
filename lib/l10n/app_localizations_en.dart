// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Simple Reminders';

  @override
  String get loading => 'Loading...';

  @override
  String get searchHint => 'Search...';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortDateAsc => 'Earliest date first';

  @override
  String get sortDateDesc => 'Latest date first';

  @override
  String get settings => 'Settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDefaultNotificationTime => 'Default notification time';

  @override
  String get settingsDefaultNotificationTimeSubtitle =>
      'Used for new reminders and those set to app default';

  @override
  String get settingsCheckNotificationPermission =>
      'Check notification permission';

  @override
  String get settingsCheckNotificationPermissionSubtitle =>
      'Opens notification settings for this app';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageSystemSubtitle => 'Follow device language';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystemSubtitle => 'Follow device theme';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get addNew => 'Add new';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get apply => 'Apply';

  @override
  String get deleteReminder => 'Delete reminder';

  @override
  String get reminderTitle => 'Title';

  @override
  String get reminderTitleHint => 'What to remind about';

  @override
  String get reminderDate => 'Reminder date';

  @override
  String get reminderDateHint => 'Pick a date';

  @override
  String get category => 'Category';

  @override
  String get newCategory => 'New category';

  @override
  String get addNewCategory => 'Add new category';

  @override
  String get notificationTime => 'Notification time';

  @override
  String get notificationTimeAppDefault => 'App default';

  @override
  String get notificationTimeCustom => 'Custom for this reminder';

  @override
  String get useAppDefaultTime => 'Use app default';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get requiredFieldsError => 'Please enter a title and reminder date.';

  @override
  String get emptyListTitle => 'No reminders yet';

  @override
  String get emptyListSubtitle => 'Tap + to add your first reminder';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String get deleteCategoryMessage =>
      'Reminders in this category will move to \"All\".';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get allCategory => 'All';

  @override
  String get cardReminderDate => 'Reminder date';

  @override
  String get notificationTitle => 'Reminder';

  @override
  String notificationBody(String name) {
    return 'I\'ll remind you about $name.';
  }

  @override
  String get notificationChannelName => 'Reminders';

  @override
  String get notificationChannelDescription =>
      'Scheduled reminders. On Xiaomi/Samsung enable this channel, pop-ups, and Alarms & reminders; use Unrestricted battery if alerts are late.';
}
