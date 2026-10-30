import 'package:sqflite/sqflite.dart';

import '../../domain/models/reminder.dart';
import 'app_database.dart';

class ReminderDao {
  Future<Database> get db async => AppDatabase.instance.database;

  Future<void> insert(Reminder reminder) async {
    final database = await db;
    await database.insert('reminders', reminder.toMap());
  }

  Future<List<Reminder>> getAll() async {
    final database = await db;
    final maps = await database.query('reminders');
    return maps.map(Reminder.fromMap).toList();
  }

  Future<Reminder?> getById(String id) async {
    final database = await db;
    final maps = await database.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Reminder.fromMap(maps.first);
  }

  Future<void> delete(String id) async {
    final database = await db;
    await database.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> update(Reminder reminder) async {
    final database = await db;
    await database.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }
}
