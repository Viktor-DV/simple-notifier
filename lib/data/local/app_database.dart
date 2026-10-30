import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('simple_notifier.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        scheduledAt INTEGER NOT NULL,
        categoryId TEXT NOT NULL,
        imagePath TEXT,
        createdAt INTEGER NOT NULL,
        notifDelivered INTEGER NOT NULL DEFAULT 0,
        notifUsesDefaultTime INTEGER NOT NULL DEFAULT 1,
        notifHour INTEGER,
        notifMinute INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        isSystem INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE products ADD COLUMN notifApproachDelivered INTEGER NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE products ADD COLUMN notifExpiryDayDelivered INTEGER NOT NULL DEFAULT 0
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE products ADD COLUMN notifUsesDefaultTime INTEGER NOT NULL DEFAULT 1
      ''');
      await db.execute('''
        ALTER TABLE products ADD COLUMN notifHour INTEGER
      ''');
      await db.execute('''
        ALTER TABLE products ADD COLUMN notifMinute INTEGER
      ''');
    }
    if (oldVersion < 4) {
      await _migrateProductsToReminders(db);
    }
    if (oldVersion < 5) {
      await _migrateToSingleNotification(db);
    }
  }

  Future<void> _migrateToSingleNotification(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(reminders)');
    final names = columns.map((c) => c['name'] as String).toSet();
    if (names.contains('notifDelivered')) return;

    await db.execute('''
      ALTER TABLE reminders ADD COLUMN notifDelivered INTEGER NOT NULL DEFAULT 0
    ''');

    if (names.contains('notifDayDelivered')) {
      await db.execute('''
        UPDATE reminders SET notifDelivered = 1
        WHERE notifDayDelivered = 1 OR notifAdvanceDelivered = 1
      ''');
    } else if (names.contains('notifExpiryDayDelivered')) {
      await db.execute('''
        UPDATE reminders SET notifDelivered = 1
        WHERE notifExpiryDayDelivered = 1 OR notifApproachDelivered = 1
      ''');
    }
  }

  Future<void> _migrateProductsToReminders(Database db) async {
    final tableExists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='products'",
    );
    if (tableExists.isEmpty) return;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        scheduledAt INTEGER NOT NULL,
        categoryId TEXT NOT NULL,
        imagePath TEXT,
        createdAt INTEGER NOT NULL,
        notifDelivered INTEGER NOT NULL DEFAULT 0,
        notifUsesDefaultTime INTEGER NOT NULL DEFAULT 1,
        notifHour INTEGER,
        notifMinute INTEGER
      )
    ''');

    await db.execute('''
      INSERT OR REPLACE INTO reminders (
        id, title, scheduledAt, categoryId, imagePath, createdAt,
        notifDelivered,
        notifUsesDefaultTime, notifHour, notifMinute
      )
      SELECT
        id,
        name,
        expirationDate,
        categoryId,
        imagePath,
        createdAt,
        CASE WHEN notifExpiryDayDelivered = 1 OR notifApproachDelivered = 1 THEN 1 ELSE 0 END,
        COALESCE(notifUsesDefaultTime, 1),
        notifHour,
        notifMinute
      FROM products
    ''');

    await db.execute('DROP TABLE IF EXISTS products');
  }
}
