import 'package:sqflite/sqflite.dart';
import '../db/db_init.dart';
import '../models/budget.dart';
import '../models/transaction.dart' as local;
import '../models/category.dart';
import '../models/salary_record.dart';
import '../ai/smart_budgeting_engine.dart';

class BudgetService {
  // CRUD Operations
  static Future<List<Budget>> getAllBudgets() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  static Future<int> createBudget(Budget budget) async {
    final db = await AppDatabase.database;
    return await db.insert('budgets', budget.toMap());
  }

  static Future<List<Budget>> getActiveBudgets() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'isActive = ? AND status = ?',
      whereArgs: [1, BudgetStatus.active.toString()],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  static Future<Budget?> getBudgetById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Budget>> getBudgetsByCategory(String categoryId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  static Future<int> updateBudget(Budget budget) async {
    final db = await AppDatabase.database;
    final updatedBudget = budget.copyWith(updatedAt: DateTime.now());

    return await db.update(
      'budgets',
      updatedBudget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  static Future<int> deleteBudget(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Budget Analytics and Management
  static Future<void> updateBudgetSpending(
    String categoryId,
    double amount,
  ) async {
    final db = await AppDatabase.database;

    // Get current budgets for the category
    List<Budget> budgets = await getBudgetsByCategory(categoryId);

    // Find active budget for current period
    DateTime now = DateTime.now();
    Budget? activeBudget =
        budgets
            .where(
              (b) =>
                  b.isActive &&
                  b.startDate.isBefore(now) &&
                  b.endDate.isAfter(now) &&
                  b.status == BudgetStatus.active,
            )
            .isNotEmpty
        ? budgets.firstWhere(
            (b) =>
                b.isActive &&
                b.startDate.isBefore(now) &&
                b.endDate.isAfter(now) &&
                b.status == BudgetStatus.active,
          )
        : null;

    if (activeBudget != null) {
      double newSpentAmount = activeBudget.spentAmount + amount.abs();
      await updateBudget(activeBudget.copyWith(spentAmount: newSpentAmount));
    }
  }

  static Future<List<Budget>> getOverBudgets() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM budgets 
      WHERE spentAmount > amount 
      AND isActive = 1 
      AND status = ?
      ORDER BY (spentAmount - amount) DESC
    ''',
      [BudgetStatus.active.toString()],
    );

    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  static Future<List<Budget>> getBudgetsNearLimit({
    double threshold = 0.8,
  }) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM budgets 
      WHERE (spentAmount / amount) >= ? 
      AND spentAmount <= amount
      AND isActive = 1 
      AND status = ?
      ORDER BY (spentAmount / amount) DESC
    ''',
      [threshold, BudgetStatus.active.toString()],
    );

    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  static Future<Map<String, double>> getBudgetSummary() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT 
        SUM(amount) as totalBudgeted,
        SUM(spentAmount) as totalSpent,
        COUNT(*) as totalBudgets,
        COUNT(CASE WHEN spentAmount > amount THEN 1 END) as overBudgetCount
      FROM budgets 
      WHERE isActive = 1 AND status = ?
    ''',
      [BudgetStatus.active.toString()],
    );

    if (result.isNotEmpty) {
      Map<String, dynamic> row = result.first;
      return {
        'totalBudgeted': row['totalBudgeted']?.toDouble() ?? 0.0,
        'totalSpent': row['totalSpent']?.toDouble() ?? 0.0,
        'totalBudgets': row['totalBudgets']?.toDouble() ?? 0.0,
        'overBudgetCount': row['overBudgetCount']?.toDouble() ?? 0.0,
      };
    }

    return {
      'totalBudgeted': 0.0,
      'totalSpent': 0.0,
      'totalBudgets': 0.0,
      'overBudgetCount': 0.0,
    };
  }

  static Future<List<Map<String, dynamic>>> getBudgetTrends({
    int months = 6,
  }) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', created_at) as month,
        SUM(amount) as budgeted,
        SUM(spentAmount) as spent,
        COUNT(*) as count
      FROM budgets 
      WHERE created_at >= date('now', '-$months months')
      GROUP BY strftime('%Y-%m', created_at)
      ORDER BY month
    ''');

    return result;
  }

  // AI-powered Budget Suggestions
  static Future<List<BudgetSuggestion>> generateBudgetSuggestions() async {
    // Get required data
    List<local.Transaction> transactions = await _getRecentTransactions();
    List<Category> categories = await _getCategories();
    List<SalaryRecord> salaryRecords = await _getSalaryRecords();
    List<Budget> existingBudgets = await getActiveBudgets();

    return await SmartBudgetingEngine.generateBudgetSuggestions(
      transactions: transactions,
      categories: categories,
      salaryRecords: salaryRecords,
      existingBudgets: existingBudgets,
    );
  }

  static Future<BudgetOptimization> analyzeBudgetPerformance() async {
    List<Budget> budgets = await getActiveBudgets();
    List<local.Transaction> transactions = await _getRecentTransactions();
    List<SalaryRecord> salaryRecords = await _getSalaryRecords();

    double monthlyIncome = salaryRecords.isNotEmpty
        ? salaryRecords.fold(0.0, (sum, record) => sum + record.amount) /
              salaryRecords.length
        : 0.0;

    return SmartBudgetingEngine.analyzeBudgetPerformance(
      budgets: budgets,
      transactions: transactions,
      monthlyIncome: monthlyIncome,
    );
  }

  static Future<List<Budget>> generateAutomaticBudgets({
    required double monthlyIncome,
    required DateTime startDate,
    BudgetPeriod period = BudgetPeriod.monthly,
  }) async {
    List<local.Transaction> transactions = await _getRecentTransactions();
    List<Category> categories = await _getCategories();

    return SmartBudgetingEngine.generateAutomaticBudgets(
      transactions: transactions,
      categories: categories,
      monthlyIncome: monthlyIncome,
      startDate: startDate,
      period: period,
    );
  }

  static Future<double> calculateOptimalBudgetAmount({
    required String categoryId,
    required double currentIncome,
  }) async {
    List<local.Transaction> transactions = await _getTransactionsByCategory(
      int.parse(categoryId),
    );

    return SmartBudgetingEngine.calculateOptimalBudgetAmount(
      transactions: transactions,
      categoryId: categoryId,
      currentIncome: currentIncome,
    );
  }

  // Budget Suggestions Storage
  static Future<void> saveBudgetSuggestion(BudgetSuggestion suggestion) async {
    final db = await AppDatabase.database;
    final Map<String, dynamic> data = suggestion.toMap();
    data['created_at'] = DateTime.now().toIso8601String();

    await db.insert('budget_suggestions', data);
  }

  static Future<List<BudgetSuggestion>> getSavedBudgetSuggestions() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budget_suggestions',
      orderBy: 'created_at DESC',
      limit: 50,
    );
    return List.generate(maps.length, (i) => BudgetSuggestion.fromMap(maps[i]));
  }

  static Future<void> clearOldBudgetSuggestions({int daysToKeep = 30}) async {
    final db = await AppDatabase.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    await db.delete(
      'budget_suggestions',
      where: 'created_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // Budget Templates and Presets
  static Future<List<Budget>> createBudgetTemplate({
    required String templateName,
    required double monthlyIncome,
    required BudgetPeriod period,
  }) async {
    List<Budget> budgets = [];
    DateTime startDate = DateTime.now();
    DateTime endDate = _calculateEndDate(startDate, period);

    // Create 50/30/20 rule budgets
    double needsAmount = monthlyIncome * 0.5;
    double wantsAmount = monthlyIncome * 0.3;
    double savingsAmount = monthlyIncome * 0.2;

    // Create essential budgets (50%)
    List<Map<String, double>> essentialBudgets = [
      {'Ăn uống': needsAmount * 0.4},
      {'Tiền nhà': needsAmount * 0.3},
      {'Điện nước': needsAmount * 0.15},
      {'Giao thông': needsAmount * 0.15},
    ];

    for (Map<String, double> budgetData in essentialBudgets) {
      String categoryName = budgetData.keys.first;
      double amount = budgetData.values.first;

      Budget budget = Budget(
        name: '$templateName - $categoryName',
        categoryId: categoryName.toLowerCase().replaceAll(' ', '_'),
        amount: amount,
        budgetLimit: amount,
        type: BudgetType.aiSuggested,
        period: period,
        startDate: startDate,
        endDate: endDate,
        status: BudgetStatus.active,
        isAIGenerated: true,
        aiReason: 'Tạo từ template $templateName',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      budgets.add(budget);
    }

    // Create wants budgets (30%)
    List<Map<String, double>> wantsBudgets = [
      {'Giải trí': wantsAmount * 0.4},
      {'Mua sắm': wantsAmount * 0.4},
      {'Du lịch': wantsAmount * 0.2},
    ];

    for (Map<String, double> budgetData in wantsBudgets) {
      String categoryName = budgetData.keys.first;
      double amount = budgetData.values.first;

      Budget budget = Budget(
        name: '$templateName - $categoryName',
        categoryId: categoryName.toLowerCase().replaceAll(' ', '_'),
        amount: amount,
        budgetLimit: amount,
        type: BudgetType.flexible,
        period: period,
        startDate: startDate,
        endDate: endDate,
        status: BudgetStatus.active,
        isAIGenerated: true,
        aiReason: 'Tạo từ template $templateName',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      budgets.add(budget);
    }

    // Create savings budget (20%)
    Budget savingsBudget = Budget(
      name: '$templateName - Tiết kiệm',
      categoryId: 'savings',
      amount: savingsAmount,
      budgetLimit: savingsAmount,
      type: BudgetType.fixed,
      period: period,
      startDate: startDate,
      endDate: endDate,
      status: BudgetStatus.active,
      isAIGenerated: true,
      aiReason: 'Tạo từ template $templateName',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    budgets.add(savingsBudget);

    return budgets;
  }

  // Batch Operations
  static Future<void> createMultipleBudgets(List<Budget> budgets) async {
    final db = await AppDatabase.database;
    final Batch batch = db.batch();

    for (Budget budget in budgets) {
      batch.insert('budgets', budget.toMap());
    }

    await batch.commit();
  }

  static Future<void> deactivateExpiredBudgets() async {
    final db = await AppDatabase.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'budgets',
      {
        'status': BudgetStatus.completed.toString(),
        'isActive': 0,
        'updated_at': now,
      },
      where: 'endDate < ? AND isActive = 1',
      whereArgs: [now],
    );
  }

  // Helper methods
  static DateTime _calculateEndDate(DateTime startDate, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return startDate.add(Duration(days: 7));
      case BudgetPeriod.biweekly:
        return startDate.add(Duration(days: 14));
      case BudgetPeriod.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case BudgetPeriod.quarterly:
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case BudgetPeriod.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
    }
  }

  static Future<List<local.Transaction>> _getRecentTransactions({
    int months = 6,
  }) async {
    final db = await AppDatabase.database;
    final DateTime thirtyDaysAgo = DateTime.now().subtract(
      const Duration(days: 30),
    );
    return _getTransactionsByDateRange(thirtyDaysAgo, DateTime.now());
  }

  static Future<List<local.Transaction>> _getTransactionsByCategory(
    int categoryId,
  ) async {
    final db = await AppDatabase.database;
    try {
      final maps = await db.query(
        'transactions',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
      return maps.map((map) => local.Transaction.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<local.Transaction>> _getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await AppDatabase.database;
    try {
      final maps = await db.query(
        'transactions',
        where: 'transaction_date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      );
      return maps.map((map) => local.Transaction.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Category>> _getCategories() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  static Future<List<SalaryRecord>> _getSalaryRecords({int months = 12}) async {
    final db = await AppDatabase.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: 30 * months));

    final List<Map<String, dynamic>> maps = await db.query(
      'salary_records',
      where: 'received_date >= ?',
      whereArgs: [cutoffDate.toIso8601String()],
      orderBy: 'received_date DESC',
    );

    return List.generate(maps.length, (i) => SalaryRecord.fromMap(maps[i]));
  }

  static Future<double> getTotalIncome(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Temporarily return 0 - method needs proper implementation
    return 0.0;
  }
}

