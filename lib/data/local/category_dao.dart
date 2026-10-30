import 'package:sqflite/sqflite.dart';
import '../../domain/models/category.dart';
import 'app_database.dart';

class CategoryDao {
  Future<Database> get db async => AppDatabase.instance.database;

  Future<void> insert(Category category) async {
    final database = await db;
    await database.insert('categories', category.toMap());
  }

  Future<List<Category>> getAll() async {
    final database = await db;
    final maps = await database.query('categories');

    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<void> delete(String id) async {
    final database = await db;
    await database.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}