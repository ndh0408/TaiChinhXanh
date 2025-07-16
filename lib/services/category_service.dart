import '../db/db_init.dart';
import '../models/category.dart';

class CategoryService {
  static Future<int> insert(Category category) async {
    final db = await AppDatabase.database;
    return await db.insert('categories', category.toMap());
  }

  static Future<List<Category>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  static Future<List<Category>> getByType(String type) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  static Future<List<Category>> getEssentialCategories() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'is_essential = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  static Future<Category?> getById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> update(Category category) async {
    final db = await AppDatabase.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Category?> findByName(String name, String type) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Category>> searchCategories(String query) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }
}

