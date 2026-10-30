// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Простые напоминания';

  @override
  String get loading => 'Загрузка...';

  @override
  String get searchHint => 'Поиск...';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortDateAsc => 'Сначала ближайшие даты';

  @override
  String get sortDateDesc => 'Сначала поздние даты';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsDefaultNotificationTime =>
      'Время уведомлений по умолчанию';

  @override
  String get settingsDefaultNotificationTimeSubtitle =>
      'Для новых напоминаний и тех, где выбрано «по умолчанию»';

  @override
  String get settingsCheckNotificationPermission =>
      'Проверить разрешение на уведомления';

  @override
  String get settingsCheckNotificationPermissionSubtitle =>
      'Откроет настройки уведомлений для этого приложения';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageSystemSubtitle => 'Следовать языку устройства';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystemSubtitle => 'Следовать теме устройства';

  @override
  String get addReminder => 'Новое напоминание';

  @override
  String get editReminder => 'Редактирование';

  @override
  String get addNew => 'Добавить';

  @override
  String get create => 'Создать';

  @override
  String get save => 'Сохранить';

  @override
  String get apply => 'Применить';

  @override
  String get deleteReminder => 'Удалить напоминание';

  @override
  String get reminderTitle => 'Заголовок';

  @override
  String get reminderTitleHint => 'О чём напомнить';

  @override
  String get reminderDate => 'Дата напоминания';

  @override
  String get reminderDateHint => 'Выберите дату';

  @override
  String get category => 'Категория';

  @override
  String get newCategory => 'Новая категория';

  @override
  String get addNewCategory => 'Добавить категорию';

  @override
  String get notificationTime => 'Время уведомления';

  @override
  String get notificationTimeAppDefault => 'По умолчанию';

  @override
  String get notificationTimeCustom => 'Своё для этого напоминания';

  @override
  String get useAppDefaultTime => 'Использовать по умолчанию';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get requiredFieldsError => 'Укажите заголовок и дату напоминания.';

  @override
  String get emptyListTitle => 'Пока пусто';

  @override
  String get emptyListSubtitle => 'Нажмите +, чтобы добавить напоминание';

  @override
  String get deleteCategoryTitle => 'Удалить категорию?';

  @override
  String get deleteCategoryMessage =>
      'Напоминания из этой категории перейдут в «Все».';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get allCategory => 'Все';

  @override
  String get cardReminderDate => 'Дата напоминания';

  @override
  String get notificationTitle => 'Напоминание';

  @override
  String notificationBody(String name) {
    return 'Напомню тебе о «$name».';
  }

  @override
  String get notificationChannelName => 'Напоминания';

  @override
  String get notificationChannelDescription =>
      'Запланированные напоминания. На Xiaomi/Samsung включите канал, всплывающие уведомления и «Будильники»; при задержках — без ограничений батареи.';
}
