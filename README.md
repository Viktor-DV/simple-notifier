# Простые напоминания

Офлайн-приложение напоминаний для Android на **Flutter**: уведомление в нужный
день и час, категории и фото. Данные хранятся только на устройстве.

[![RuStore](https://img.shields.io/badge/RuStore-скачать-0077FF)](https://www.rustore.ru/catalog/app/com.viktor.dv.simple_notifier)
![Flutter](https://img.shields.io/badge/Flutter-Material_3-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android)

## Возможности

- Напоминания с заголовком, датой и временем уведомления.
- Время по умолчанию или своё для конкретного напоминания.
- Свои категории, фильтр по ним и общая категория «Все».
- Фото к напоминанию из галереи.
- Поиск и сортировка по дате.
- Проверка разрешения на уведомления прямо из настроек.
- Русский и английский интерфейс, светлая и тёмная тема.

## Архитектура

Слои `data` → `domain` → `features`: SQLite и DAO изолированы от UI,
экраны работают с моделями `Reminder` / `Category` через Riverpod-провайдеры.
Планирование уведомлений учитывает часовой пояс (`timezone`).

## Стек

Flutter / Dart · Material 3 · Riverpod · sqflite · flutter_local_notifications ·
timezone · image_picker · shared_preferences · intl (RU / EN)

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
