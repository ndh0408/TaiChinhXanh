import 'dart:math' as math;
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/expense_forecast.dart';

class ExpenseForecastingEngine {
  // static const double _anomalyThreshold = 2.0; // Standard deviations - unused
  // static const int _minDataPoints = 10; // unused
  // static const int _defaultForecastDays = 30; // unused

  /// Generate basic expense forecast for a category
  static Future<ExpenseForecast> generateCategoryForecast({
    required Category category,
    required List<Transaction> transactions,
    required DateTime startDate,
    int forecastDays = 30,
  }) async {
    // Filter transactions for this category
    List<Transaction> categoryTransactions = transactions
        .where((t) => t.categoryId == category.id && t.amount < 0)
        .toList();

    if (categoryTransactions.isEmpty) {
      return ExpenseForecast(
        categoryId: category.id!.toString(),
        categoryName: category.name,
        forecastAmount: 0.0,
        forecastPeriod: forecastDays,
        confidence: 0.0,
        method: ForecastMethod.historical,
        generatedAt: DateTime.now(),
        validUntil: startDate.add(Duration(days: forecastDays)),
        metadata: {'reason': 'No transaction data available'},
      );
    }

    // Calculate average daily expense
    double totalExpense = categoryTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount.abs(),
    );

    double dailyAverage = totalExpense / categoryTransactions.length;
    double forecastAmount = dailyAverage * forecastDays;

    // Simple confidence calculation based on data points
    double confidence = math.min(categoryTransactions.length / 30.0, 1.0);

    return ExpenseForecast(
      categoryId: category.id!.toString(),
      categoryName: category.name,
      forecastAmount: forecastAmount,
      forecastPeriod: forecastDays,
      confidence: confidence,
      method: ForecastMethod.historical,
      generatedAt: DateTime.now(),
      validUntil: startDate.add(Duration(days: forecastDays)),
      metadata: {
        'dailyAverage': dailyAverage,
        'transactionCount': categoryTransactions.length,
        'totalHistoricalExpense': totalExpense,
      },
    );
  }

  /// Generate forecast for all categories
  static Future<List<ExpenseForecast>> generateAllCategoryForecasts({
    required List<Category> categories,
    required List<Transaction> transactions,
    required DateTime startDate,
    int forecastDays = 30,
  }) async {
    List<ExpenseForecast> forecasts = [];

    for (Category category in categories) {
      ExpenseForecast forecast = await generateCategoryForecast(
        category: category,
        transactions: transactions,
        startDate: startDate,
        forecastDays: forecastDays,
      );
      forecasts.add(forecast);
    }

    return forecasts;
  }

  /// Generate total expense forecast
  static Future<ExpenseForecast> generateTotalExpenseForecast({
    required List<Transaction> transactions,
    required DateTime startDate,
    int forecastDays = 30,
  }) async {
    List<Transaction> expenseTransactions = transactions
        .where((t) => t.amount < 0)
        .toList();

    if (expenseTransactions.isEmpty) {
      return ExpenseForecast(
        categoryId: 'total',
        categoryName: 'Total Expenses',
        forecastAmount: 0.0,
        forecastPeriod: forecastDays,
        confidence: 0.0,
        method: ForecastMethod.historical,
        generatedAt: DateTime.now(),
        validUntil: startDate.add(Duration(days: forecastDays)),
        metadata: {'reason': 'No expense data available'},
      );
    }

    // Calculate monthly average
    Map<String, double> monthlyTotals = {};
    for (Transaction expense in expenseTransactions) {
      String monthKey = '${expense.date.year}-${expense.date.month}';
      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0) + expense.amount.abs();
    }

    double averageMonthlyExpense = monthlyTotals.values.isEmpty
        ? 0.0
        : monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length;

    double dailyAverage = averageMonthlyExpense / 30;
    double forecastAmount = dailyAverage * forecastDays;

    double confidence = math.min(
      monthlyTotals.length / 6.0,
      1.0,
    ); // Based on 6 months of data

    return ExpenseForecast(
      categoryId: 'total',
      categoryName: 'Total Expenses',
      forecastAmount: forecastAmount,
      forecastPeriod: forecastDays,
      confidence: confidence,
      method: ForecastMethod.historical,
      generatedAt: DateTime.now(),
      validUntil: startDate.add(Duration(days: forecastDays)),
      metadata: {
        'dailyAverage': dailyAverage,
        'monthlyAverage': averageMonthlyExpense,
        'monthsOfData': monthlyTotals.length,
        'totalTransactions': expenseTransactions.length,
      },
    );
  }
}

