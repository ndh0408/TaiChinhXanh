import '../db/db_init.dart';
import '../models/income_source.dart';

class IncomeSourceService {
  static Future<int> insert(IncomeSource incomeSource) async {
    final db = await AppDatabase.database;
    return await db.insert('income_sources', incomeSource.toMap());
  }

  static Future<List<IncomeSource>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('income_sources');
    return List.generate(maps.length, (i) => IncomeSource.fromMap(maps[i]));
  }

  static Future<List<IncomeSource>> getActive() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income_sources',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => IncomeSource.fromMap(maps[i]));
  }

  static Future<IncomeSource?> getById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income_sources',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return IncomeSource.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> update(IncomeSource incomeSource) async {
    final db = await AppDatabase.database;
    return await db.update(
      'income_sources',
      incomeSource.toMap(),
      where: 'id = ?',
      whereArgs: [incomeSource.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('income_sources', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deactivate(int id) async {
    final db = await AppDatabase.database;
    return await db.update(
      'income_sources',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<IncomeSource>> getByType(String type) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income_sources',
      where: 'type = ? AND is_active = ?',
      whereArgs: [type, 1],
    );
    return List.generate(maps.length, (i) => IncomeSource.fromMap(maps[i]));
  }

  static Future<double> getTotalBaseAmount() async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(base_amount) as total FROM income_sources WHERE is_active = 1',
    );
    final value = result.first['total'];
    return (value as double?) ?? 0.0;
  }
}

