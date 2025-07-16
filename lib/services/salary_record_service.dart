import '../db/db_init.dart';
import '../models/salary_record.dart';

class SalaryRecordService {
  static Future<int> insert(SalaryRecord salaryRecord) async {
    final db = await AppDatabase.database;
    return await db.insert('salary_records', salaryRecord.toMap());
  }

  static Future<List<SalaryRecord>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salary_records',
      orderBy: 'received_date DESC',
    );
    return List.generate(maps.length, (i) => SalaryRecord.fromMap(maps[i]));
  }

  static Future<List<SalaryRecord>> getByIncomeSource(
    int incomeSourceId,
  ) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salary_records',
      where: 'income_source_id = ?',
      whereArgs: [incomeSourceId],
      orderBy: 'received_date DESC',
    );
    return List.generate(maps.length, (i) => SalaryRecord.fromMap(maps[i]));
  }

  static Future<List<SalaryRecord>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salary_records',
      where: 'received_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'received_date DESC',
    );
    return List.generate(maps.length, (i) => SalaryRecord.fromMap(maps[i]));
  }

  static Future<SalaryRecord?> getById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salary_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SalaryRecord.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> update(SalaryRecord salaryRecord) async {
    final db = await AppDatabase.database;
    return await db.update(
      'salary_records',
      salaryRecord.toMap(),
      where: 'id = ?',
      whereArgs: [salaryRecord.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('salary_records', where: 'id = ?', whereArgs: [id]);
  }

  // Analytics methods
  static Future<double> getTotalNetIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(net_amount) as total FROM salary_records WHERE received_date BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final value = result.first['total'];
    return (value as double?) ?? 0.0;
  }

  static Future<double> getTotalGrossIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(gross_amount) as total FROM salary_records WHERE received_date BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final value = result.first['total'];
    return (value as double?) ?? 0.0;
  }

  static Future<double> getAverageNetSalary(int incomeSourceId) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT AVG(net_amount) as average FROM salary_records WHERE income_source_id = ?',
      [incomeSourceId],
    );
    final value = result.first['average'];
    return (value as double?) ?? 0.0;
  }

  static Future<List<Map<String, dynamic>>> getMonthlyTotals(int year) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        strftime('%m', received_date) as month,
        SUM(gross_amount) as gross_total,
        SUM(net_amount) as net_total,
        SUM(bonus_amount) as bonus_total,
        COUNT(*) as record_count
      FROM salary_records 
      WHERE strftime('%Y', received_date) = ?
      GROUP BY strftime('%m', received_date)
      ORDER BY month
    ''',
      [year.toString()],
    );

    return result;
  }

  static Future<SalaryRecord?> getLatestRecord(int incomeSourceId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salary_records',
      where: 'income_source_id = ?',
      whereArgs: [incomeSourceId],
      orderBy: 'received_date DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return SalaryRecord.fromMap(maps.first);
    }
    return null;
  }

  static Future<double> calculateGrowthRate(
    int incomeSourceId,
    int months,
  ) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT net_amount, received_date
      FROM salary_records 
      WHERE income_source_id = ?
      ORDER BY received_date DESC 
      LIMIT ?
    ''',
      [incomeSourceId, months],
    );

    if (result.length < 2) return 0.0;

    final latest = result.first['net_amount'] as double;
    final earliest = result.last['net_amount'] as double;

    if (earliest == 0) return 0.0;
    return ((latest - earliest) / earliest) * 100;
  }
}

