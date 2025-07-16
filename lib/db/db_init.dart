import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema.dart';
import 'indexes.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'finance_app.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Create all tables
          await db.execute(categoriesTable);
          await db.execute(transactionsTable);
          await db.execute(incomeSourcesTable);
          await db.execute(salaryRecordsTable);
          await db.execute(billsTable);
          await db.execute(billPaymentsTable);
          await db.execute(financialPredictionsTable);
          await db.execute(budgetsTable);
          await db.execute(budgetSuggestionsTable);
          await db.execute(expenseForecastsTable);
          await db.execute(expenseAnomaliesTable);
          await db.execute(categoryPredictionsTable);
          await db.execute(seasonalAnalysisTable);
          await db.execute(budgetVarianceAlertsTable);

          // Create AI Analytics table
          await db.execute(aiAnalyticsTable);
          await db.execute(aiSuggestionsTable);

          // Create performance indexes
          await _createIndexes(db);

          // Seed default data
          await _seedDefaultData(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Handle database upgrades
        },
      );
    } catch (e) {
      debugPrint('[DEBUG]  initialization error: $e');
      rethrow;
    }
  }

  // Create all performance indexes
  static Future<void> _createIndexes(Database db) async {
    try {
      debugPrint('Creating database indexes...');

      // Create all indexes from the indexes.dart file
      for (String indexQuery in allIndexes) {
        await db.execute(indexQuery);
      }

      debugPrint('[DEBUG]  created ${allIndexes.length} database indexes');
    } catch (e) {
      debugPrint('[DEBUG]  creating indexes: $e');
      // Don't rethrow - indexes are performance optimization, not critical
    }
  }

  static Future<void> _seedDefaultData(Database db) async {
    // Default expense categories
    final defaultExpenseCategories = [
      {
        'name': 'Ä‚n uá»‘ng',
        'type': 'expense',
        'color': '#FF5722',
        'icon': 'restaurant',
        'is_essential': 1,
      },
      {
        'name': 'Di chuyá»ƒn',
        'type': 'expense',
        'color': '#2196F3',
        'icon': 'directions_car',
        'is_essential': 1,
      },
      {
        'name': 'Mua sáº¯m',
        'type': 'expense',
        'color': '#9C27B0',
        'icon': 'shopping_cart',
        'is_essential': 0,
      },
      {
        'name': 'Tiá»n nhÃ ',
        'type': 'expense',
        'color': '#4CAF50',
        'icon': 'home',
        'is_essential': 1,
      },
      {
        'name': 'Y táº¿',
        'type': 'expense',
        'color': '#F44336',
        'icon': 'local_hospital',
        'is_essential': 1,
      },
      {
        'name': 'Giáº£i trÃ­',
        'type': 'expense',
        'color': '#FF9800',
        'icon': 'movie',
        'is_essential': 0,
      },
      {
        'name': 'GiÃ¡o dá»¥c',
        'type': 'expense',
        'color': '#607D8B',
        'icon': 'school',
        'is_essential': 1,
      },
      {
        'name': 'KhÃ¡c',
        'type': 'expense',
        'color': '#795548',
        'icon': 'category',
        'is_essential': 0,
      },
    ];

    for (final category in defaultExpenseCategories) {
      await db.insert('categories', category);
    }

    // Default income categories
    final defaultIncomeCategories = [
      {'name': 'LÆ°Æ¡ng', 'type': 'income', 'color': '#4CAF50', 'icon': 'work'},
      {
        'name': 'ThÆ°á»Ÿng',
        'type': 'income',
        'color': '#8BC34A',
        'icon': 'star',
      },
      {
        'name': 'Freelance',
        'type': 'income',
        'color': '#CDDC39',
        'icon': 'computer',
      },
      {
        'name': 'Äáº§u tÆ°',
        'type': 'income',
        'color': '#FFC107',
        'icon': 'trending_up',
      },
      {
        'name': 'KhÃ¡c',
        'type': 'income',
        'color': '#FF9800',
        'icon': 'attach_money',
      },
    ];

    for (final category in defaultIncomeCategories) {
      await db.insert('categories', category);
    }
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance_app.db');
    await databaseFactory.deleteDatabase(path);
    _db = null;
  }

  // Migration method to add indexes to existing databases
  static Future<void> addIndexesToExistingDatabase() async {
    final db = await database;
    await _createIndexes(db);
  }

  // Get database performance information
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;

    try {
      // Get table counts
      final tables = [
        'transactions',
        'categories',
        'income_sources',
        'salary_records',
        'bills',
        'bill_payments',
        'ai_suggestions',
        'ai_analytics',
        'budgets',
        'expense_forecasts',
      ];

      Map<String, int> tableCounts = {};
      for (String table in tables) {
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $table',
        );
        tableCounts[table] = result.first['count'] as int;
      }

      // Get index information
      final indexResult = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
      );
      final indexCount = indexResult.length;

      return {
        'tableCounts': tableCounts,
        'indexCount': indexCount,
        'totalRecords': tableCounts.values.reduce((a, b) => a + b),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
