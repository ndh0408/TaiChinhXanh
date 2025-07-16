import '../db/db_init.dart';
import '../models/transaction.dart';

class TransactionService {
  static Future<int> insert(Transaction transaction) async {
    final db = await AppDatabase.database;
    return await db.insert('transactions', transaction.toMap());
  }

  static Future<List<Transaction>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  static Future<List<Transaction>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transaction_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  static Future<List<Transaction>> getByType(String type) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  static Future<List<Transaction>> getByCategory(int categoryId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  static Future<Transaction?> getById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> update(Transaction transaction) async {
    final db = await AppDatabase.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Analytics methods
  static Future<double> getTotalByTypeAndDateRange(
    String type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND transaction_date BETWEEN ? AND ?',
      [type, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final value = result.first['total'];
    return (value as double?) ?? 0.0;
  }

  static Future<Map<String, double>> getCategoryTotals(
    String type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT c.name, SUM(t.amount) as total 
      FROM transactions t 
      JOIN categories c ON t.category_id = c.id 
      WHERE t.type = ? AND t.transaction_date BETWEEN ? AND ?
      GROUP BY c.id, c.name
    ''',
      [type, startDate.toIso8601String(), endDate.toIso8601String()],
    );

    final Map<String, double> categoryTotals = {};
    for (final row in result) {
      categoryTotals[row['name'] as String] = (row['total'] as double?) ?? 0.0;
    }
    return categoryTotals;
  }

  static Future<List<Transaction>> getRecentTransactions(int limit) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'transaction_date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  static Future<double> getAverageExpenseByCategory(
    int categoryId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT AVG(amount) as average 
      FROM transactions 
      WHERE category_id = ? AND type = 'expense' AND transaction_date BETWEEN ? AND ?
    ''',
      [categoryId, startDate.toIso8601String(), endDate.toIso8601String()],
    );

    final value = result.first['average'];
    return (value as double?) ?? 0.0;
  }
}

