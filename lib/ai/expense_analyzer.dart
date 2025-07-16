import 'dart:math';
import '../models/transaction.dart';
import '../models/category.dart';

class ExpenseAnalyzer {
  // Phát hiện bất thường
  static List<Map<String, dynamic>> detectAnomalies(
    List<Transaction> transactions,
  ) {
    if (transactions.length < 10) {
      return [];
    }

    // Lọc chỉ expense transactions
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    if (expenses.length < 5) return [];

    // Tính toán Z-score cho từng giao dịch
    final amounts = expenses.map((t) => t.amount).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final standardDeviation = _calculateStandardDeviation(amounts);

    List<Map<String, dynamic>> anomalies = [];

    for (final transaction in expenses) {
      final zScore = (transaction.amount - mean) / standardDeviation;

      // Phát hiện bất thường nếu Z-score > 2 (ngoài 95% dữ liệu)
      if (zScore.abs() > 2.0) {
        final severity = zScore.abs() > 3.0 ? 'high' : 'medium';

        anomalies.add({
          'transaction': transaction,
          'z_score': zScore,
          'severity': severity,
          'deviation_amount': transaction.amount - mean,
          'analysis': _generateAnomalyAnalysis(transaction, mean, zScore),
          'recommendation': _generateAnomalyRecommendation(transaction, zScore),
        });
      }
    }

    // Sắp xếp theo mức độ nghiêm trọng
    anomalies.sort(
      (a, b) => (b['z_score'] as double).abs().compareTo(
        (a['z_score'] as double).abs(),
      ),
    );

    return anomalies.take(10).toList(); // Giới hạn 10 bất thường cao nhất
  }

  // Phân tích pattern chi tiêu
  static Map<String, dynamic> analyzeSpendingPatterns(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return {
        'category_distribution': <String, double>{},
        'time_patterns': <String, double>{},
        'spending_trends': <String, dynamic>{},
        'analysis': 'Không có dữ liệu chi tiêu để phân tích',
      };
    }

    final expenses = transactions.where((t) => t.type == 'expense').toList();

    // Phân tích theo category
    final categoryDistribution = _analyzeCategoryDistribution(expenses);

    // Phân tích theo thời gian
    final timePatterns = _analyzeTimePatterns(expenses);

    // Phân tích xu hướng
    final spendingTrends = _analyzeSpendingTrends(expenses);

    // Correlation analysis
    final correlations = _analyzeCorrelations(expenses);

    return {
      'category_distribution': categoryDistribution,
      'time_patterns': timePatterns,
      'spending_trends': spendingTrends,
      'correlations': correlations,
      'analysis': _generatePatternAnalysis(
        categoryDistribution,
        timePatterns,
        spendingTrends,
      ),
      'insights': _generateSpendingInsights(expenses),
    };
  }

  // Gợi ý cắt giảm chi tiêu
  static List<Map<String, dynamic>> suggestExpenseReduction(
    List<Transaction> transactions,
    List<Category> categories,
    double targetReduction,
  ) {
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    if (expenses.isEmpty) return [];

    // Phân tích chi tiêu theo category
    final categoryTotals = <int, double>{};
    final categoryTransactions = <int, List<Transaction>>{};

    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
      categoryTransactions[expense.categoryId] =
          (categoryTransactions[expense.categoryId] ?? [])..add(expense);
    }

    List<Map<String, dynamic>> suggestions = [];

    for (final categoryId in categoryTotals.keys) {
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(
          id: categoryId,
          name: 'Unknown',
          type: 'expense',
          color: '#000000',
          icon: 'category',
          budgetLimit: 0,
          isEssential: false,
          priority: 1,
        ),
      );

      final total = categoryTotals[categoryId]!;
      final transactionList = categoryTransactions[categoryId]!;

      // Tính potential savings dựa trên priority và essential
      double potentialSavings = 0;
      String strategy = '';

      if (!category.isEssential) {
        potentialSavings = total * 0.3; // Có thể cắt 30% cho non-essential
        strategy = 'Giảm chi tiêu không thiết yếu';
      } else {
        potentialSavings = total * 0.1; // Chỉ cắt 10% cho essential
        strategy = 'Tối ưu hóa chi tiêu thiết yếu';
      }

      // Phân tích tần suất và pattern
      final frequency = _analyzeFrequency(transactionList);
      final avgAmount = total / transactionList.length;

      suggestions.add({
        'category': category,
        'current_spending': total,
        'potential_savings': potentialSavings,
        'reduction_percentage': (potentialSavings / total * 100),
        'strategy': strategy,
        'priority': category.priority,
        'frequency': frequency,
        'average_amount': avgAmount,
        'specific_suggestions': _generateSpecificSuggestions(
          category,
          transactionList,
        ),
        'impact_analysis': _generateImpactAnalysis(
          potentialSavings,
          total,
          category.isEssential,
        ),
      });
    }

    // Sắp xếp theo potential savings và priority
    suggestions.sort((a, b) {
      final aSavings = a['potential_savings'] as double;
      final bSavings = b['potential_savings'] as double;
      final aPriority = a['priority'] as int;
      final bPriority = b['priority'] as int;

      // Ưu tiên savings cao và priority thấp (dễ cắt)
      final aScore = aSavings / aPriority;
      final bScore = bSavings / bPriority;

      return bScore.compareTo(aScore);
    });

    // Lọc để đạt target reduction
    double totalSavings = 0;
    final finalSuggestions = <Map<String, dynamic>>[];

    for (final suggestion in suggestions) {
      if (totalSavings < targetReduction) {
        finalSuggestions.add(suggestion);
        totalSavings += suggestion['potential_savings'] as double;
      } else {
        break;
      }
    }

    return finalSuggestions;
  }

  // Helper methods
  static double _calculateStandardDeviation(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    return sqrt(variance);
  }

  static String _generateAnomalyAnalysis(
    Transaction transaction,
    double mean,
    double zScore,
  ) {
    if (zScore > 2) {
      return 'Giao dịch ${transaction.amount.toStringAsFixed(0)}đ cao hơn ${((transaction.amount - mean) / mean * 100).toStringAsFixed(1)}% so với trung bình';
    } else {
      return 'Giao dịch ${transaction.amount.toStringAsFixed(0)}đ thấp hơn ${((mean - transaction.amount) / mean * 100).toStringAsFixed(1)}% so với trung bình';
    }
  }

  static String _generateAnomalyRecommendation(
    Transaction transaction,
    double zScore,
  ) {
    if (zScore > 3) {
      return 'Kiểm tra lại giao dịch này - có thể là chi tiêu bất thường hoặc nhập sai';
    } else if (zScore > 2) {
      return 'Cân nhắc xem có thể giảm chi tiêu loại này không';
    } else {
      return 'Chi tiêu thấp bất thường - có thể đã tiết kiệm tốt';
    }
  }

  static Map<String, double> _analyzeCategoryDistribution(
    List<Transaction> expenses,
  ) {
    final distribution = <String, double>{};
    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);

    final categoryTotals = <int, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    for (final entry in categoryTotals.entries) {
      final percentage = (entry.value / total) * 100;
      distribution['Category ${entry.key}'] = percentage;
    }

    return distribution;
  }

  static Map<String, double> _analyzeTimePatterns(List<Transaction> expenses) {
    final patterns = <String, double>{};

    // Phân tích theo giờ trong ngày
    final hourlySpending = <int, double>{};
    for (final expense in expenses) {
      final hour = expense.transactionDate.hour;
      hourlySpending[hour] = (hourlySpending[hour] ?? 0) + expense.amount;
    }

    // Tìm giờ chi tiêu nhiều nhất
    if (hourlySpending.isNotEmpty) {
      final maxHour = hourlySpending.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      patterns['peak_spending_hour'] = maxHour.key.toDouble();
      patterns['peak_spending_amount'] = maxHour.value;
    }

    // Phân tích theo ngày trong tuần
    final weeklySpending = <int, double>{};
    for (final expense in expenses) {
      final weekday = expense.transactionDate.weekday;
      weeklySpending[weekday] = (weeklySpending[weekday] ?? 0) + expense.amount;
    }

    if (weeklySpending.isNotEmpty) {
      final maxDay = weeklySpending.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      patterns['peak_spending_weekday'] = maxDay.key.toDouble();
    }

    return patterns;
  }

  static Map<String, dynamic> _analyzeSpendingTrends(
    List<Transaction> expenses,
  ) {
    if (expenses.length < 7) return {'trend': 'insufficient_data'};

    // Sắp xếp theo thời gian
    expenses.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    // Tính trung bình chi tiêu hàng tuần
    final weeklySpending = <int, double>{};
    for (final expense in expenses) {
      final week = _getWeekNumber(expense.transactionDate);
      weeklySpending[week] = (weeklySpending[week] ?? 0) + expense.amount;
    }

    if (weeklySpending.length < 2) return {'trend': 'insufficient_data'};

    final weeks = weeklySpending.keys.toList()..sort();
    final amounts = weeks.map((w) => weeklySpending[w]!).toList();

    // Linear regression cho trend
    final n = amounts.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += amounts[i];
      sumXY += i * amounts[i];
      sumX2 += i * i;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    String trend = 'stable';
    if (slope > 10000) {
      trend = 'increasing';
    } else if (slope < -10000) {
      trend = 'decreasing';
    }

    return {
      'trend': trend,
      'slope': slope,
      'weekly_average': amounts.reduce((a, b) => a + b) / amounts.length,
      'weeks_analyzed': n,
    };
  }

  static Map<String, dynamic> _analyzeCorrelations(List<Transaction> expenses) {
    // Phân tích correlation giữa amount và các factors khác
    final correlations = <String, double>{};

    // Correlation với ngày trong tuần
    final weekdayAmounts = <int, List<double>>{};
    for (final expense in expenses) {
      final weekday = expense.transactionDate.weekday;
      weekdayAmounts[weekday] = (weekdayAmounts[weekday] ?? [])
        ..add(expense.amount);
    }

    return correlations;
  }

  static String _generatePatternAnalysis(
    Map<String, double> categoryDist,
    Map<String, double> timePatterns,
    Map<String, dynamic> trends,
  ) {
    String analysis = 'Phân tích pattern chi tiêu:\n';

    if (categoryDist.isNotEmpty) {
      final topCategory = categoryDist.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      analysis +=
          '• Chi tiêu nhiều nhất cho ${topCategory.key} (${topCategory.value.toStringAsFixed(1)}%)\n';
    }

    if (timePatterns.containsKey('peak_spending_hour')) {
      final hour = timePatterns['peak_spending_hour']!.toInt();
      analysis += '• Thường chi tiêu nhiều vào ${hour}h\n';
    }

    if (trends['trend'] != 'insufficient_data') {
      analysis += '• Xu hướng chi tiêu: ${trends['trend']}\n';
    }

    return analysis;
  }

  static List<String> _generateSpendingInsights(List<Transaction> expenses) {
    final insights = <String>[];

    if (expenses.isEmpty) return insights;

    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final average = total / expenses.length;

    insights.add(
      'Chi tiêu trung bình: ${average.toStringAsFixed(0)}đ/giao dịch',
    );
    insights.add('Tổng chi tiêu: ${total.toStringAsFixed(0)}đ');
    insights.add('Số giao dịch: ${expenses.length}');

    return insights;
  }

  static String _analyzeFrequency(List<Transaction> transactions) {
    if (transactions.length < 2) return 'irregular';

    transactions.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final intervals = <int>[];
    for (int i = 1; i < transactions.length; i++) {
      final diff = transactions[i].transactionDate
          .difference(transactions[i - 1].transactionDate)
          .inDays;
      intervals.add(diff);
    }

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

    if (avgInterval <= 7) return 'weekly';
    if (avgInterval <= 30) return 'monthly';
    return 'irregular';
  }

  static List<String> _generateSpecificSuggestions(
    Category category,
    List<Transaction> transactions,
  ) {
    final suggestions = <String>[];
    final total = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    final average = total / transactions.length;

    switch (category.name.toLowerCase()) {
      case 'ăn uống':
        suggestions.add('Nấu ăn tại nhà thay vì mua ngoài');
        suggestions.add(
          'Đặt ngân sách ${(average * 0.8).toStringAsFixed(0)}đ/bữa',
        );
        break;
      case 'di chuyển':
        suggestions.add('Sử dụng phương tiện công cộng');
        suggestions.add('Đi chung xe với đồng nghiệp');
        break;
      case 'giải trí':
        suggestions.add('Tìm các hoạt động miễn phí');
        suggestions.add('Giới hạn ${(total * 0.7).toStringAsFixed(0)}đ/tháng');
        break;
      default:
        suggestions.add('Theo dõi chặt chẽ chi tiêu loại này');
        suggestions.add('So sánh giá trước khi mua');
    }

    return suggestions;
  }

  static String _generateImpactAnalysis(
    double savings,
    double total,
    bool isEssential,
  ) {
    final percentage = (savings / total * 100);

    if (isEssential) {
      return 'Tác động thấp - chi tiêu thiết yếu, cần cân nhắc kỹ';
    } else {
      if (percentage > 25) {
        return 'Tác động cao - có thể tiết kiệm đáng kể mà không ảnh hưởng cuộc sống';
      } else {
        return 'Tác động trung bình - cân nhắc cắt giảm từ từ';
      }
    }
  }

  static int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear / 7).floor();
  }
}

