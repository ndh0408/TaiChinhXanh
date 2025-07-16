import 'dart:math';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';

class SmartSuggestionsEngine {
  // Generate personalized suggestions (simplified version)
  static List<AISuggestion> generateSuggestions({
    required List<Transaction> transactions,
    required List<SalaryRecord> salaryRecords,
    required List<IncomeSource> incomeSources,
    required List<Category> categories,
  }) {
    final suggestions = <AISuggestion>[];

    // Basic expense analysis
    final expenseTransactions = transactions
        .where((t) => t.type == 'expense')
        .toList();
    final incomeTransactions = transactions
        .where((t) => t.type == 'income')
        .toList();

    final totalExpenses = expenseTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    final totalIncome = incomeTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    // Generate basic suggestions
    if (totalIncome > 0) {
      final expenseRatio = totalExpenses / totalIncome;

      if (expenseRatio > 0.8) {
        suggestions.add(
          AISuggestion(
            type: 'expense_warning',
            title: 'Cảnh báo chi tiêu',
            content:
                'Chi tiêu chiếm ${(expenseRatio * 100).toStringAsFixed(1)}% thu nhập. Cần cắt giảm chi tiêu ngay.',
            priority: 5,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }

      final savingsRate = (totalIncome - totalExpenses) / totalIncome;
      if (savingsRate < 0.2) {
        suggestions.add(
          AISuggestion(
            type: 'savings_improvement',
            title: 'Cải thiện tiết kiệm',
            content:
                'Tỷ lệ tiết kiệm chỉ ${(savingsRate * 100).toStringAsFixed(1)}%. Hãy tăng cường tiết kiệm lên ít nhất 20%.',
            priority: 4,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Income diversification
    if (incomeSources.length < 2) {
      suggestions.add(
        AISuggestion(
          type: 'income_diversification',
          title: 'Đa dạng thu nhập',
          content:
              'Chỉ có ${incomeSources.length} nguồn thu nhập. Hãy tạo thêm nguồn thu nhập phụ để giảm rủi ro.',
          priority: 3,
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Salary growth analysis
    if (salaryRecords.length >= 2) {
      final latest = salaryRecords.last;
      final previous = salaryRecords[salaryRecords.length - 2];
      final growthRate =
          (latest.netAmount - previous.netAmount) / previous.netAmount;

      if (growthRate < 0.05) {
        suggestions.add(
          AISuggestion(
            type: 'career_growth',
            title: 'Phát triển sự nghiệp',
            content:
                'Lương tăng chậm (${(growthRate * 100).toStringAsFixed(1)}%/năm). Cần nhắc thương lượng tăng lương hoặc đổi việc.',
            priority: 3,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Category-based suggestions
    final categorySpending = <int, double>{};
    for (final expense in expenseTransactions) {
      categorySpending[expense.categoryId] =
          (categorySpending[expense.categoryId] ?? 0) + expense.amount;
    }

    // Find highest spending category
    if (categorySpending.isNotEmpty && totalExpenses > 0) {
      final topCategoryId = categorySpending.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final topCategory = categories.firstWhere(
        (c) => c.id == topCategoryId,
        orElse: () => categories.first,
      );
      final percentage =
          (categorySpending[topCategoryId]! / totalExpenses) * 100;

      if (percentage > 30) {
        suggestions.add(
          AISuggestion(
            type: 'category_optimization',
            title: 'Tối ưu chi tiêu ${topCategory.name}',
            content:
                'Chi tiêu ${topCategory.name} chiếm ${percentage.toStringAsFixed(1)}% tổng chi tiêu. Hãy cân nhắc cắt giảm.',
            priority: 2,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Sort by priority and limit
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    return suggestions.take(10).toList();
  }

  // Generate personalized tips
  static List<AISuggestion> generatePersonalizedTips({
    required List<Transaction> transactions,
    required List<SalaryRecord> salaryRecords,
    required List<IncomeSource> incomeSources,
    required List<Category> categories,
  }) {
    final tips = <AISuggestion>[];

    // Basic spending pattern analysis
    final expenseTransactions = transactions
        .where((t) => t.type == 'expense')
        .toList();

    if (expenseTransactions.isNotEmpty) {
      final avgExpense =
          expenseTransactions.map((t) => t.amount).reduce((a, b) => a + b) /
          expenseTransactions.length;

      tips.add(
        AISuggestion(
          type: 'spending_pattern',
          title: 'Gợi ý tiết kiệm',
          content:
              'Chi tiêu trung bình ${avgExpense.toStringAsFixed(0)}đ/giao dịch. Hãy theo dõi các giao dịch lớn.',
          priority: 2,
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Income optimization
    if (salaryRecords.isNotEmpty) {
      final latestSalary = salaryRecords.last;
      final taxRate =
          (latestSalary.grossAmount - latestSalary.netAmount) /
          latestSalary.grossAmount;

      if (taxRate > 0.2) {
        tips.add(
          AISuggestion(
            type: 'tax_optimization',
            title: 'Tối ưu thuế',
            content:
                'Thuế chiếm ${(taxRate * 100).toStringAsFixed(1)}% lương. Hãy tìm hiểu các khoản khấu trừ hợp pháp.',
            priority: 3,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    return tips;
  }

  // Generate smart alerts
  static List<AISuggestion> generateSmartAlerts({
    required List<Transaction> transactions,
    required List<SalaryRecord> salaryRecords,
    required List<IncomeSource> incomeSources,
    required List<Category> categories,
  }) {
    final alerts = <AISuggestion>[];

    // Detect unusual spending
    final expenseTransactions = transactions
        .where((t) => t.type == 'expense')
        .toList();

    if (expenseTransactions.isNotEmpty) {
      final avgExpense =
          expenseTransactions.map((t) => t.amount).reduce((a, b) => a + b) /
          expenseTransactions.length;
      final unusualTransactions = expenseTransactions
          .where((t) => t.amount > avgExpense * 2)
          .toList();

      if (unusualTransactions.isNotEmpty) {
        alerts.add(
          AISuggestion(
            type: 'anomaly_alert',
            title: 'Phát hiện chi tiêu bất thường',
            content:
                'Có ${unusualTransactions.length} giao dịch chi tiêu cao bất thường. Hãy kiểm tra lại.',
            priority: 4,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Income stability check
    if (salaryRecords.length >= 3) {
      final amounts = salaryRecords.map((s) => s.netAmount).toList();
      final avgSalary = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance =
          amounts
              .map((a) => (a - avgSalary) * (a - avgSalary))
              .reduce((a, b) => a + b) /
          amounts.length;
      final stdDev = sqrt(variance);

      if (stdDev > avgSalary * 0.2) {
        alerts.add(
          AISuggestion(
            type: 'income_stability',
            title: 'Thu nhập không ổn định',
            content:
                'Thu nhập biến động lớn. Hãy cân nhắc tạo quỹ khẩn cấp lớn hơn.',
            priority: 3,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    return alerts;
  }

  // Generate seasonal tips
  static List<AISuggestion> generateSeasonalTips() {
    final tips = <AISuggestion>[];
    final now = DateTime.now();

    String title = 'Gợi ý tài chính';
    String content = 'Hãy theo dõi chi tiêu và tiết kiệm đều đặn.';

    switch (now.month) {
      case 1:
        title = 'Mục tiêu tài chính năm mới';
        content =
            'Đầu năm là thời điểm tốt để lập kế hoạch tài chính. Hãy đặt mục tiêu tiết kiệm cụ thể.';
        break;
      case 2:
        title = 'Chuẩn bị Tết';
        content =
            'Sắp đến Tết, hãy lập ngân sách cho quà tặng và các chi phí khác.';
        break;
      case 6:
        title = 'Đánh giá giữa năm';
        content = 'Đã qua nửa năm, hãy xem xét lại mục tiêu tài chính.';
        break;
      case 12:
        title = 'Chuẩn bị cuối năm';
        content =
            'Cuối năm là thời điểm tốt để đánh giá tài chính và lập kế hoạch.';
        break;
    }

    tips.add(
      AISuggestion(
        type: 'seasonal',
        title: title,
        content: content,
        priority: 2,
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    return tips;
  }
}
