import 'dart:math' as math;
import '../models/budget.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/salary_record.dart';

class SmartBudgetingEngine {
  static const int _minDataPointsRequired = 3;
  static const Map<String, double> _categoryPriorityWeights = {
    'essential': 1.0, // Food, utilities, rent
    'important': 0.8, // Transportation, healthcare
    'discretionary': 0.6, // Entertainment, shopping
    'savings': 0.9, // Savings, investments
  };

  /// Generate comprehensive budget suggestions based on spending patterns
  static Future<List<BudgetSuggestion>> generateBudgetSuggestions({
    required List<Transaction> transactions,
    required List<Category> categories,
    required List<SalaryRecord> salaryRecords,
    required List<Budget> existingBudgets,
    int analysisMonths = 6,
  }) async {
    List<BudgetSuggestion> suggestions = [];

    // Calculate monthly income average
    double monthlyIncome = _calculateAverageMonthlyIncome(salaryRecords);

    // Analyze spending patterns by category
    Map<String, SpendingAnalysis> spendingAnalysis = _analyzeSpendingByCategory(
      transactions,
      categories,
      analysisMonths,
    );

    // Generate suggestions for each category
    for (String categoryId in spendingAnalysis.keys) {
      SpendingAnalysis analysis = spendingAnalysis[categoryId]!;
      Category category = categories.firstWhere((c) => c.id.toString() == categoryId);

      BudgetSuggestion? suggestion = _generateCategorySuggestion(
        categoryId: categoryId,
        category: category,
        analysis: analysis,
        monthlyIncome: monthlyIncome,
        existingBudgets: existingBudgets,
      );

      if (suggestion != null) {
        suggestions.add(suggestion);
      }
    }

    // Add suggestions for uncategorized spending categories
    List<String> uncategorizedCategoryIds = _findUncategorizedSpending(
      categories,
      existingBudgets,
      spendingAnalysis,
    );

    for (String categoryId in uncategorizedCategoryIds) {
      Category category = categories.firstWhere((c) => c.id.toString() == categoryId);
      SpendingAnalysis analysis = spendingAnalysis[categoryId]!;

      BudgetSuggestion suggestion = BudgetSuggestion(
        categoryId: categoryId,
        categoryName: category.name,
        suggestedAmount: analysis.averageMonthlySpending * 1.1, // 10% buffer
        currentSpending: analysis.currentMonthSpending,
        historicalAverage: analysis.averageMonthlySpending,
        reason: 'Tạo ngân sách mới cho danh mục có chi tiêu thường xuyên',
        confidence: _calculateConfidence(analysis),
        type: BudgetSuggestionType.create,
        tips: _generateBudgetTips(category, analysis),
      );

      suggestions.add(suggestion);
    }

    // Sort by priority and confidence
    suggestions.sort((a, b) {
      double priorityA = _getCategoryPriority(a.categoryName);
      double priorityB = _getCategoryPriority(b.categoryName);

      if (priorityA != priorityB) {
        return priorityB.compareTo(priorityA);
      }
      return b.confidence.compareTo(a.confidence);
    });

    return suggestions;
  }

  /// Analyze spending patterns and suggest budget optimizations
  static BudgetOptimization analyzeBudgetPerformance({
    required List<Budget> budgets,
    required List<Transaction> transactions,
    required double monthlyIncome,
  }) {
    double totalBudgeted = budgets.fold(
      0,
      (sum, budget) => sum + budget.amount,
    );
    double totalSpent = budgets.fold(
      0,
      (sum, budget) => sum + budget.spentAmount,
    );
    double savingsRate = (monthlyIncome - totalSpent) / monthlyIncome * 100;

    List<String> insights = [];
    List<String> recommendations = [];
    BudgetHealthStatus overallHealth = BudgetHealthStatus.good;

    // Analyze savings rate
    if (savingsRate < 10) {
      overallHealth = BudgetHealthStatus.critical;
      insights.add('Tỷ lệ tiết kiệm thấp (${savingsRate.toStringAsFixed(1)}%)');
      recommendations.add('Tăng tỷ lệ tiết kiệm lên ít nhất 20% thu nhập');
    } else if (savingsRate < 20) {
      overallHealth = BudgetHealthStatus.warning;
      insights.add('Tỷ lệ tiết kiệm khá (${savingsRate.toStringAsFixed(1)}%)');
      recommendations.add('Cố gắng tăng tỷ lệ tiết kiệm lên 20-30%');
    } else {
      insights.add('Tỷ lệ tiết kiệm tốt (${savingsRate.toStringAsFixed(1)}%)');
    }

    // Analyze budget utilization
    int overBudgetCount = budgets.where((b) => b.isOverBudget).length;
    if (overBudgetCount > budgets.length * 0.3) {
      overallHealth = BudgetHealthStatus.critical;
      insights.add('$overBudgetCount/${budgets.length} ngân sách bị vượt quá');
      recommendations.add('Xem xét điều chỉnh ngân sách hoặc giảm chi tiêu');
    }

    // 50/30/20 rule analysis
    Map<String, double> spendingBreakdown = _analyze503020Rule(budgets);
    if (spendingBreakdown['needs']! > 60) {
      insights.add(
        'Chi tiêu thiết yếu cao (${spendingBreakdown['needs']!.toStringAsFixed(1)}%)',
      );
      recommendations.add('Tìm cách giảm chi phí cố định');
    }

    return BudgetOptimization(
      totalBudgeted: totalBudgeted,
      totalSpent: totalSpent,
      savingsRate: savingsRate,
      overallHealth: overallHealth,
      insights: insights,
      recommendations: recommendations,
      spendingBreakdown: spendingBreakdown,
    );
  }

  /// Generate automatic budget based on 50/30/20 rule and spending patterns
  static List<Budget> generateAutomaticBudgets({
    required List<Transaction> transactions,
    required List<Category> categories,
    required double monthlyIncome,
    required DateTime startDate,
    BudgetPeriod period = BudgetPeriod.monthly,
  }) {
    List<Budget> budgets = [];
    DateTime endDate = _calculateEndDate(startDate, period);

    // Apply 50/30/20 rule
    double needsAmount = monthlyIncome * 0.5;
    double wantsAmount = monthlyIncome * 0.3;
    double savingsAmount = monthlyIncome * 0.2;

    // Analyze historical spending patterns
    Map<String, SpendingAnalysis> spendingAnalysis = _analyzeSpendingByCategory(
      transactions,
      categories,
      6,
    );

    // Categorize categories into needs, wants, savings
    Map<String, List<Category>> categorizedCategories =
        _categorizeByNeedsWantsSavings(categories);

    // Distribute needs budget
    _distributeBudgetByCategory(
      budgets: budgets,
      categories: categorizedCategories['needs']!,
      totalAmount: needsAmount,
      spendingAnalysis: spendingAnalysis,
      startDate: startDate,
      endDate: endDate,
      period: period,
      budgetType: 'Thiết yếu',
    );

    // Distribute wants budget
    _distributeBudgetByCategory(
      budgets: budgets,
      categories: categorizedCategories['wants']!,
      totalAmount: wantsAmount,
      spendingAnalysis: spendingAnalysis,
      startDate: startDate,
      endDate: endDate,
      period: period,
      budgetType: 'Mong muốn',
    );

    // Distribute savings budget
    _distributeBudgetByCategory(
      budgets: budgets,
      categories: categorizedCategories['savings']!,
      totalAmount: savingsAmount,
      spendingAnalysis: spendingAnalysis,
      startDate: startDate,
      endDate: endDate,
      period: period,
      budgetType: 'Tiết kiệm',
    );

    return budgets;
  }

  /// Calculate optimal budget amount based on historical data and ML algorithms
  static double calculateOptimalBudgetAmount({
    required List<Transaction> transactions,
    required String categoryId,
    required double currentIncome,
    int analysisMonths = 6,
  }) {
    // Filter transactions for the category
    List<Transaction> categoryTransactions = transactions
        .where((t) => t.categoryId.toString() == categoryId)
        .toList();

    if (categoryTransactions.length < _minDataPointsRequired) {
      return 0.0;
    }

    // Calculate statistical measures
    List<double> monthlySpending = _getMonthlySpending(
      categoryTransactions,
      analysisMonths,
    );
    double mean =
        monthlySpending.reduce((a, b) => a + b) / monthlySpending.length;
    double stdDev = _calculateStandardDeviation(monthlySpending, mean);

    // Apply multiple algorithms and ensemble them
    double linearRegression = _linearRegressionPrediction(monthlySpending);
    double seasonalAdjusted = _seasonallyAdjustedPrediction(monthlySpending);
    double trendBased = _trendBasedPrediction(monthlySpending);
    double percentileBased = _percentileBasedPrediction(monthlySpending, 0.8);

    // Weighted ensemble
    double optimal =
        (linearRegression * 0.3 +
        seasonalAdjusted * 0.25 +
        trendBased * 0.25 +
        percentileBased * 0.2);

    // Apply income-based adjustment
    double incomeRatio = currentIncome / 50000000; // Assuming 50M base income
    optimal *= math.max(0.5, math.min(2.0, incomeRatio));

    // Apply confidence-based buffer
    double confidence = _calculateConfidenceFromVariance(stdDev, mean);
    double buffer = confidence < 0.7 ? 1.2 : 1.1;

    return optimal * buffer;
  }

  // Private helper methods
  static double _calculateAverageMonthlyIncome(
    List<SalaryRecord> salaryRecords,
  ) {
    if (salaryRecords.isEmpty) return 0.0;

    final now = DateTime.now();
    final lastMonthRecords = salaryRecords
        .where(
          (record) =>
              record.receivedDate.isAfter(
                DateTime(now.year, now.month - 1, 1),
              ) &&
              record.receivedDate.isBefore(DateTime(now.year, now.month, 1)),
        )
        .toList();

    if (lastMonthRecords.isEmpty) return 0.0;

    return lastMonthRecords
            .map((record) => record.netAmount)
            .reduce((a, b) => a + b) /
        lastMonthRecords.length;
  }

  static Map<String, SpendingAnalysis> _analyzeSpendingByCategory(
    List<Transaction> transactions,
    List<Category> categories,
    int months,
  ) {
    Map<String, SpendingAnalysis> analysis = {};

    for (Category category in categories) {
      List<Transaction> categoryTransactions = transactions
          .where((t) => t.categoryId == category.id)
          .toList();

      if (categoryTransactions.isNotEmpty) {
        analysis[category.id!.toString()] = _calculateSpendingAnalysis(
          categoryTransactions,
          months,
        );
      }
    }

    return analysis;
  }

  static SpendingAnalysis _calculateSpendingAnalysis(
    List<Transaction> transactions,
    int months,
  ) {
    double total = transactions.fold(0, (sum, t) => sum + t.amount.abs());
    double average = total / months;

    // Current month spending
    DateTime now = DateTime.now();
    DateTime currentMonthStart = DateTime(now.year, now.month, 1);
    double currentMonth = transactions
        .where((t) => t.transactionDate.isAfter(currentMonthStart))
        .fold(0, (sum, t) => sum + t.amount.abs());

    // Calculate trend
    List<double> monthlyAmounts = _getMonthlySpending(transactions, months);
    double trend = monthlyAmounts.length > 1
        ? (monthlyAmounts.last - monthlyAmounts.first) / monthlyAmounts.length
        : 0.0;

    // Calculate variance
    double variance = _calculateVariance(monthlyAmounts, average);

    return SpendingAnalysis(
      totalSpending: total,
      averageMonthlySpending: average,
      currentMonthSpending: currentMonth,
      trend: trend,
      variance: variance,
      transactionCount: transactions.length,
    );
  }

  static BudgetSuggestion? _generateCategorySuggestion({
    required String categoryId,
    required Category category,
    required SpendingAnalysis analysis,
    required double monthlyIncome,
    required List<Budget> existingBudgets,
  }) {
    Budget? existingBudget =
        existingBudgets.where((b) => b.categoryId == categoryId).isNotEmpty
        ? existingBudgets.firstWhere((b) => b.categoryId == categoryId)
        : null;

    if (existingBudget == null) return null;

    double suggestedAmount = analysis.averageMonthlySpending;
    BudgetSuggestionType suggestionType = BudgetSuggestionType.maintain;
    String reason = '';

    // Analyze if budget should be increased, decreased, or maintained
    double currentBudget = existingBudget.amount;
    double utilizationRate = analysis.averageMonthlySpending / currentBudget;

    if (utilizationRate > 0.9) {
      // Budget too low
      suggestedAmount = analysis.averageMonthlySpending * 1.15;
      suggestionType = BudgetSuggestionType.increase;
      reason =
          'Ngân sách hiện tại thường xuyên bị vượt quá (${(utilizationRate * 100).toStringAsFixed(1)}%)';
    } else if (utilizationRate < 0.6) {
      // Budget too high
      suggestedAmount = analysis.averageMonthlySpending * 1.1;
      suggestionType = BudgetSuggestionType.decrease;
      reason =
          'Ngân sách hiện tại còn thừa nhiều (chỉ dùng ${(utilizationRate * 100).toStringAsFixed(1)}%)';
    } else {
      reason = 'Ngân sách hiện tại phù hợp với thói quen chi tiêu';
    }

    double confidence = _calculateConfidence(analysis);

    return BudgetSuggestion(
      categoryId: categoryId,
      categoryName: category.name,
      suggestedAmount: suggestedAmount,
      currentSpending: analysis.currentMonthSpending,
      historicalAverage: analysis.averageMonthlySpending,
      reason: reason,
      confidence: confidence,
      type: suggestionType,
      tips: _generateBudgetTips(category, analysis),
    );
  }

  static List<String> _generateBudgetTips(
    Category category,
    SpendingAnalysis analysis,
  ) {
    List<String> tips = [];

    // General tips based on category
    switch (category.name.toLowerCase()) {
      case 'ăn uống':
        tips.add('Nấu ăn tại nhà thay vì mua đồ ăn ngoài');
        tips.add('Lập kế hoạch thực đơn hàng tuần');
        break;
      case 'giao thông':
        tips.add('Sử dụng phương tiện công cộng');
        tips.add('Đi chung xe hoặc đi bộ khi có thể');
        break;
      case 'giải trí':
        tips.add('Tìm kiếm hoạt động giải trí miễn phí');
        tips.add('Đặt giới hạn chi tiêu giải trí hàng tháng');
        break;
      default:
        tips.add('Theo dõi chi tiêu hàng ngày');
        tips.add('So sánh giá trước khi mua');
    }

    // Tips based on spending pattern
    if (analysis.variance > analysis.averageMonthlySpending * 0.5) {
      tips.add('Chi tiêu biến động lớn - hãy lập kế hoạch rõ ràng hơn');
    }

    if (analysis.trend > 0) {
      tips.add('Chi tiêu đang tăng dần - cần kiểm soát chặt chẽ hơn');
    }

    return tips;
  }

  static double _calculateConfidence(SpendingAnalysis analysis) {
    if (analysis.transactionCount < _minDataPointsRequired) {
      return 0.3;
    }

    // Confidence based on data consistency
    double variabilityFactor = analysis.variance > 0
        ? math.min(1.0, analysis.averageMonthlySpending / analysis.variance)
        : 1.0;

    double dataPointsFactor = math.min(1.0, analysis.transactionCount / 10.0);

    return (variabilityFactor * 0.6 + dataPointsFactor * 0.4).clamp(0.0, 1.0);
  }

  static List<String> _findUncategorizedSpending(
    List<Category> categories,
    List<Budget> existingBudgets,
    Map<String, SpendingAnalysis> spendingAnalysis,
  ) {
    Set<String> budgetedCategories = existingBudgets
        .map((b) => b.categoryId)
        .toSet();

    return spendingAnalysis.keys
        .where((categoryId) => !budgetedCategories.contains(categoryId))
        .where(
          (categoryId) =>
              spendingAnalysis[categoryId]!.averageMonthlySpending > 100000,
        ) // > 100k VND
        .toList();
  }

  static double _getCategoryPriority(String categoryName) {
    String lowerName = categoryName.toLowerCase();

    if ([
      'ăn uống',
      'tiền nhà',
      'điện nước',
      'y tế',
    ].any((s) => lowerName.contains(s))) {
      return _categoryPriorityWeights['essential']!;
    } else if ([
      'giao thông',
      'học tập',
      'bảo hiểm',
    ].any((s) => lowerName.contains(s))) {
      return _categoryPriorityWeights['important']!;
    } else if (['tiết kiệm', 'đầu tư'].any((s) => lowerName.contains(s))) {
      return _categoryPriorityWeights['savings']!;
    } else {
      return _categoryPriorityWeights['discretionary']!;
    }
  }

  static Map<String, double> _analyze503020Rule(List<Budget> budgets) {
    double needs = 0, wants = 0, savings = 0;
    double total = budgets.fold(0, (sum, b) => sum + b.amount);

    for (Budget budget in budgets) {
      double priority = _getCategoryPriority(budget.name);
      if (priority >= 0.9) {
        needs += budget.amount;
      } else if (priority >= 0.7) {
        savings += budget.amount;
      } else {
        wants += budget.amount;
      }
    }

    return {
      'needs': total > 0 ? (needs / total) * 100 : 0,
      'wants': total > 0 ? (wants / total) * 100 : 0,
      'savings': total > 0 ? (savings / total) * 100 : 0,
    };
  }

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

  static Map<String, List<Category>> _categorizeByNeedsWantsSavings(
    List<Category> categories,
  ) {
    Map<String, List<Category>> categorized = {
      'needs': [],
      'wants': [],
      'savings': [],
    };

    for (Category category in categories) {
      double priority = _getCategoryPriority(category.name);
      if (priority >= 0.9) {
        categorized['needs']!.add(category);
      } else if (priority >= 0.7) {
        categorized['savings']!.add(category);
      } else {
        categorized['wants']!.add(category);
      }
    }

    return categorized;
  }

  static void _distributeBudgetByCategory({
    required List<Budget> budgets,
    required List<Category> categories,
    required double totalAmount,
    required Map<String, SpendingAnalysis> spendingAnalysis,
    required DateTime startDate,
    required DateTime endDate,
    required BudgetPeriod period,
    required String budgetType,
  }) {
    double remainingAmount = totalAmount;

    for (Category category in categories) {
      SpendingAnalysis? analysis = spendingAnalysis[category.id!.toString()];
      double categoryAmount;

      if (analysis != null) {
        // Base on historical spending
        categoryAmount = math.min(
          analysis.averageMonthlySpending * 1.1,
          remainingAmount,
        );
      } else {
        // Default allocation
        categoryAmount = remainingAmount / categories.length;
      }

      if (categoryAmount > 0) {
        Budget budget = Budget(
          name: '$budgetType - ${category.name}',
          categoryId: category.id!.toString(),
          amount: categoryAmount,
          budgetLimit: categoryAmount,
          type: BudgetType.aiSuggested,
          period: period,
          startDate: startDate,
          endDate: endDate,
          status: BudgetStatus.active,
          isAIGenerated: true,
          aiReason: 'Tự động tạo dựa trên quy tắc 50/30/20 và lịch sử chi tiêu',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        budgets.add(budget);
        remainingAmount -= categoryAmount;
      }
    }
  }

  static List<double> _getMonthlySpending(
    List<Transaction> transactions,
    int months,
  ) {
    Map<String, double> monthlyTotals = {};
    DateTime cutoffDate = DateTime.now().subtract(Duration(days: 30 * months));

    for (Transaction transaction in transactions) {
      if (transaction.transactionDate.isAfter(cutoffDate)) {
        String monthKey =
            '${transaction.transactionDate.year}-${transaction.transactionDate.month}';
        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0) + transaction.amount.abs();
      }
    }

    return monthlyTotals.values.toList();
  }

  static double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.isEmpty) return 0.0;

    double sumSquaredDiffs = values.fold(
      0,
      (sum, value) => sum + math.pow(value - mean, 2),
    );
    return math.sqrt(sumSquaredDiffs / values.length);
  }

  static double _calculateVariance(List<double> values, double mean) {
    if (values.isEmpty) return 0.0;

    double sumSquaredDiffs = values.fold(
      0,
      (sum, value) => sum + math.pow(value - mean, 2),
    );
    return sumSquaredDiffs / values.length;
  }

  static double _linearRegressionPrediction(List<double> monthlySpending) {
    if (monthlySpending.length < 2) {
      return monthlySpending.isNotEmpty ? monthlySpending.first : 0.0;
    }

    int n = monthlySpending.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += monthlySpending[i];
      sumXY += i * monthlySpending[i];
      sumX2 += i * i;
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    return slope * n + intercept; // Predict next month
  }

  static double _seasonallyAdjustedPrediction(List<double> monthlySpending) {
    if (monthlySpending.isEmpty) return 0.0;

    double mean =
        monthlySpending.reduce((a, b) => a + b) / monthlySpending.length;

    // Simple seasonal adjustment - could be enhanced with more sophisticated methods
    if (monthlySpending.length >= 12) {
      double seasonalFactor = monthlySpending.last / mean;
      return mean * seasonalFactor;
    }

    return mean;
  }

  static double _trendBasedPrediction(List<double> monthlySpending) {
    if (monthlySpending.length < 3) {
      return monthlySpending.isNotEmpty ? monthlySpending.last : 0.0;
    }

    // Calculate trend from last 3 months
    double trend =
        (monthlySpending.last - monthlySpending[monthlySpending.length - 3]) /
        3;
    return monthlySpending.last + trend;
  }

  static double _percentileBasedPrediction(
    List<double> monthlySpending,
    double percentile,
  ) {
    if (monthlySpending.isEmpty) return 0.0;

    List<double> sorted = List.from(monthlySpending)..sort();
    int index = (sorted.length * percentile).floor();
    return sorted[math.min(index, sorted.length - 1)];
  }

  static double _calculateConfidenceFromVariance(double stdDev, double mean) {
    if (mean == 0) return 0.5;

    double coefficientOfVariation = stdDev / mean;
    return math.max(0.0, math.min(1.0, 1.0 - coefficientOfVariation));
  }
}

// Supporting classes
class SpendingAnalysis {
  final double totalSpending;
  final double averageMonthlySpending;
  final double currentMonthSpending;
  final double trend;
  final double variance;
  final int transactionCount;

  SpendingAnalysis({
    required this.totalSpending,
    required this.averageMonthlySpending,
    required this.currentMonthSpending,
    required this.trend,
    required this.variance,
    required this.transactionCount,
  });
}

class BudgetOptimization {
  final double totalBudgeted;
  final double totalSpent;
  final double savingsRate;
  final BudgetHealthStatus overallHealth;
  final List<String> insights;
  final List<String> recommendations;
  final Map<String, double> spendingBreakdown;

  BudgetOptimization({
    required this.totalBudgeted,
    required this.totalSpent,
    required this.savingsRate,
    required this.overallHealth,
    required this.insights,
    required this.recommendations,
    required this.spendingBreakdown,
  });
}

enum BudgetHealthStatus { good, warning, critical }
