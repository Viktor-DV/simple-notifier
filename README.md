# Простые напоминания (simple_notifier)

Android-приложение для простых напоминаний с уведомлением в нужный день и
час. Работает офлайн, данные хранятся только на устройстве.

**Скачать:** [RuStore](https://www.rustore.ru/catalog/developer/x9jrid)

## Возможности

- Напоминания с заголовком, датой и временем уведомления.
- Время уведомления по умолчанию или своё для конкретного напоминания.
- Категории: свои категории, фильтр по ним и категория «Все».
- Фото к напоминанию из галереи.
- Поиск и сортировка по дате.
- Проверка разрешения на уведомления прямо из настроек.
- Русский и английский язык, светлая и тёмная тема.

## Стек

- Flutter / Dart, Material 3
- `flutter_riverpod` — состояние
- `sqflite` — база данных
- `flutter_local_notifications` + `timezone` — уведомления
- `image_picker` — фото
- `shared_preferences` — настройки

## Сборка

```bash
flutter pub get
flutter test
flutter build appbundle --release
```

## Структура

```
lib/
├── core/       # уведомления, тема, навигация, локализация
├── data/       # SQLite и DAO
├── domain/     # модели Reminder, Category
├── features/   # home, reminder, settings, startup
└── l10n/       # строки RU / EN
```
