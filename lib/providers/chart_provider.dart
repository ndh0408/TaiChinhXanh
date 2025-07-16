import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../services/salary_record_service.dart';
import '../models/salary_record.dart';

enum ChartType {
  incomeLineChart,
  expensePieChart,
  monthlyComparison,
  savingsProgress,
  categoryBreakdown,
  salaryTrends,
}

class ChartData {
  final ChartType type;
  final dynamic data;
  final DateTime lastUpdated;
  final Duration cacheDuration;

  ChartData({
    required this.type,
    required this.data,
    required this.lastUpdated,
    this.cacheDuration = const Duration(minutes: 5),
  });

  bool get isExpired {
    return DateTime.now().difference(lastUpdated) > cacheDuration;
  }
}

class ChartProvider with ChangeNotifier {
  final Map<ChartType, ChartData> _chartCache = {};
  final Map<ChartType, bool> _loadingStates = {};

  // Performance tracking
  final Map<ChartType, Duration> _loadTimes = {};

  // Getters for loading states
  bool isLoading(ChartType type) => _loadingStates[type] ?? false;
  bool isLoaded(ChartType type) =>
      _chartCache.containsKey(type) && !_chartCache[type]!.isExpired;

  // Get cached data
  dynamic getCachedData(ChartType type) {
    final cachedData = _chartCache[type];
    if (cachedData != null && !cachedData.isExpired) {
      return cachedData.data;
    }
    return null;
  }

  // Get performance metrics
  Duration? getLoadTime(ChartType type) => _loadTimes[type];

  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'totalCachedCharts': _chartCache.length,
      'averageLoadTime': _loadTimes.values.isEmpty
          ? Duration.zero
          : Duration(
              microseconds:
                  _loadTimes.values
                      .map((d) => d.inMicroseconds)
                      .reduce((a, b) => a + b) ~/
                  _loadTimes.length,
            ),
      'cacheHitRate': _calculateCacheHitRate(),
      'loadTimes': Map.fromEntries(
        _loadTimes.entries.map(
          (e) => MapEntry(e.key.toString(), e.value.inMilliseconds),
        ),
      ),
    };
  }

  double _calculateCacheHitRate() {
    // This would be tracked with actual usage metrics
    return _chartCache.length > 0 ? 0.75 : 0.0; // Mock value
  }

  // Lazy load chart data
  Future<T> loadChartData<T>(
    ChartType type,
    Future<T> Function() loader, {
    Duration? cacheDuration,
  }) async {
    // Check if already loading
    if (_loadingStates[type] == true) {
      // Wait for current loading to complete
      while (_loadingStates[type] == true) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return getCachedData(type) as T;
    }

    // Check cache first
    final cachedData = getCachedData(type);
    if (cachedData != null) {
      return cachedData as T;
    }

    // Start loading
    _loadingStates[type] = true;
    notifyListeners();

    try {
      final stopwatch = Stopwatch()..start();

      final data = await loader();

      stopwatch.stop();
      _loadTimes[type] = stopwatch.elapsed;

      // Cache the result
      _chartCache[type] = ChartData(
        type: type,
        data: data,
        lastUpdated: DateTime.now(),
        cacheDuration: cacheDuration ?? const Duration(minutes: 5),
      );

      _loadingStates[type] = false;
      notifyListeners();

      return data;
    } catch (e) {
      _loadingStates[type] = false;
      notifyListeners();
      rethrow;
    }
  }

  // Specific chart data loaders
  Future<Map<DateTime, double>> loadIncomeLineChartData() async {
    return loadChartData(ChartType.incomeLineChart, () async {
      final transactions = await TransactionService.getByType('income');
      final monthlyIncomes = <DateTime, double>{};

      for (final income in transactions) {
        final monthKey = DateTime(
          income.transactionDate.year,
          income.transactionDate.month,
        );
        monthlyIncomes[monthKey] =
            (monthlyIncomes[monthKey] ?? 0) + income.amount;
      }

      return monthlyIncomes;
    }, cacheDuration: const Duration(minutes: 10));
  }

  Future<Map<String, double>> loadExpensePieChartData() async {
    return loadChartData(ChartType.expensePieChart, () async {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final expenses = await TransactionService.getByDateRange(
        startOfMonth,
        now,
      );

      final categoryTotals = <String, double>{};
      for (final expense in expenses.where((t) => t.type == 'expense')) {
        // This would need category name lookup
        final categoryName = 'Category ${expense.categoryId}'; // Simplified
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + expense.amount;
      }

      return categoryTotals;
    });
  }

  Future<List<Map<String, dynamic>>> loadMonthlyComparisonData() async {
    return loadChartData(ChartType.monthlyComparison, () async {
      final now = DateTime.now();
      final months = List.generate(
        6,
        (index) => DateTime(now.year, now.month - index, 1),
      ).reversed.toList();

      final monthlyData = <Map<String, dynamic>>[];

      for (final month in months) {
        final nextMonth = DateTime(month.year, month.month + 1, 1);
        final transactions = await TransactionService.getByDateRange(
          month,
          nextMonth,
        );

        double income = 0;
        double expense = 0;

        for (final transaction in transactions) {
          if (transaction.type == 'income') {
            income += transaction.amount;
          } else {
            expense += transaction.amount;
          }
        }

        monthlyData.add({'month': month, 'income': income, 'expense': expense});
      }

      return monthlyData;
    }, cacheDuration: const Duration(minutes: 15));
  }

  Future<Map<String, double>> loadSavingsProgressData() async {
    return loadChartData(ChartType.savingsProgress, () async {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final transactions = await TransactionService.getByDateRange(
        startOfMonth,
        now,
      );

      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      final savings = totalIncome - totalExpense;
      final savingsRate = totalIncome > 0 ? savings / totalIncome : 0.0;

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'savings': savings,
        'savingsRate': savingsRate,
        'savingsGoal': 0.2, // 20% goal
      };
    });
  }

  Future<List<Map<String, dynamic>>> loadSalaryTrendsData() async {
    return loadChartData(
      ChartType.salaryTrends,
      () async {
        final salaryRecords = await SalaryRecordService.getAll();

        // Group by month and calculate trends
        final monthlyData = <DateTime, List<SalaryRecord>>{};
        for (final record in salaryRecords) {
          final monthKey = DateTime(
            record.receivedDate.year,
            record.receivedDate.month,
          );
          monthlyData[monthKey] ??= [];
          monthlyData[monthKey]!.add(record);
        }

        final trendData = monthlyData.entries.map((entry) {
          final totalGross = entry.value.fold<double>(
            0,
            (sum, record) => sum + record.grossAmount,
          );
          final totalNet = entry.value.fold<double>(
            0,
            (sum, record) => sum + record.netAmount,
          );

          return {
            'month': entry.key,
            'grossAmount': totalGross,
            'netAmount': totalNet,
            'recordCount': entry.value.length,
          };
        }).toList();

        // Sort by date
        trendData.sort(
          (a, b) => (a['month'] as DateTime).compareTo(b['month'] as DateTime),
        );

        return trendData;
      },
      cacheDuration: const Duration(
        minutes: 30,
      ), // Salary data changes less frequently
    );
  }

  // Invalidate specific chart cache
  void invalidateChart(ChartType type) {
    _chartCache.remove(type);
    notifyListeners();
  }

  // Invalidate all cache
  void invalidateAllCharts() {
    _chartCache.clear();
    _loadingStates.clear();
    notifyListeners();
  }

  // Preload charts (for performance optimization)
  Future<void> preloadCharts(List<ChartType> types) async {
    final futures = types.map((type) {
      switch (type) {
        case ChartType.incomeLineChart:
          return loadIncomeLineChartData();
        case ChartType.expensePieChart:
          return loadExpensePieChartData();
        case ChartType.monthlyComparison:
          return loadMonthlyComparisonData();
        case ChartType.savingsProgress:
          return loadSavingsProgressData();
        case ChartType.salaryTrends:
          return loadSalaryTrendsData();
        default:
          return Future.value(null);
      }
    });

    await Future.wait(futures);
  }

  // Memory management
  void clearOldCache() {
    final now = DateTime.now();
    _chartCache.removeWhere(
      (key, value) =>
          now.difference(value.lastUpdated) > const Duration(hours: 1),
    );
  }

  // Get cache status for debugging
  Map<String, dynamic> getCacheStatus() {
    return {
      'cachedCharts': _chartCache.keys.map((k) => k.toString()).toList(),
      'loadingCharts': _loadingStates.entries
          .where((e) => e.value)
          .map((e) => e.key.toString())
          .toList(),
      'cacheDetails': _chartCache.map(
        (key, value) => MapEntry(key.toString(), {
          'lastUpdated': value.lastUpdated.toIso8601String(),
          'isExpired': value.isExpired,
          'dataSize': value.data?.toString().length ?? 0,
        }),
      ),
    };
  }
}

