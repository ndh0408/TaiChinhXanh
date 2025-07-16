import 'dart:math';
import '../models/salary_record.dart';
import '../models/income_source.dart';

class SalaryAnalyzer {
  // Phân tích tăng trưởng lương
  static Map<String, dynamic> analyzeSalaryGrowth(List<SalaryRecord> records) {
    if (records.length < 2) {
      return {
        'growth_rate': 0.0,
        'trend': 'insufficient_data',
        'analysis': 'Cần ít nhất 2 bản ghi để phân tích tăng trưởng',
        'recommendation':
            'Hãy thêm nhiều dữ liệu lương để phân tích chính xác hơn',
      };
    }

    // Sắp xếp theo ngày
    records.sort((a, b) => a.receivedDate.compareTo(b.receivedDate));

    final firstSalary = records.first.netAmount;
    final lastSalary = records.last.netAmount;
    final growthRate = ((lastSalary - firstSalary) / firstSalary) * 100;

    // Tính tăng trưởng trung bình hàng tháng
    final monthsDiff = _getMonthsDifference(
      records.first.receivedDate,
      records.last.receivedDate,
    );
    final monthlyGrowthRate = monthsDiff > 0 ? growthRate / monthsDiff : 0.0;

    // Phân tích xu hướng
    String trend = 'stable';
    if (growthRate > 5) {
      trend = 'increasing';
    } else if (growthRate < -5) {
      trend = 'decreasing';
    }

    // So sánh với lạm phát (giả định 3% hàng năm)
    final inflationRate = 3.0;
    final realGrowthRate = growthRate - (inflationRate * (monthsDiff / 12));

    String analysis = '';
    String recommendation = '';

    if (realGrowthRate > 0) {
      analysis =
          'Lương của bạn tăng trưởng tốt, vượt qua lạm phát ${realGrowthRate.toStringAsFixed(1)}%';
      recommendation =
          'Tiếp tục duy trì hiệu suất tốt và cân nhắc đầu tư để gia tăng tài sản';
    } else {
      analysis =
          'Lương tăng chậm hơn lạm phát ${realGrowthRate.abs().toStringAsFixed(1)}%';
      recommendation =
          'Cần tìm cách tăng thu nhập hoặc thương lượng tăng lương';
    }

    return {
      'growth_rate': growthRate,
      'monthly_growth_rate': monthlyGrowthRate,
      'real_growth_rate': realGrowthRate,
      'trend': trend,
      'analysis': analysis,
      'recommendation': recommendation,
      'first_salary': firstSalary,
      'last_salary': lastSalary,
      'months_analyzed': monthsDiff,
    };
  }

  // Dự báo thu nhập
  static Map<String, dynamic> predictIncome(
    List<SalaryRecord> records,
    IncomeSource incomeSource,
  ) {
    if (records.length < 3) {
      return {
        'predicted_amount': incomeSource.baseAmount,
        'confidence': 0.3,
        'method': 'base_amount',
        'analysis': 'Dự báo dựa trên mức lương cơ bản do thiếu dữ liệu lịch sử',
      };
    }

    // Sắp xếp theo ngày
    records.sort((a, b) => a.receivedDate.compareTo(b.receivedDate));

    // Linear regression để dự đoán
    final prediction = _linearRegression(records);

    // Seasonal adjustment dựa trên tần suất
    final seasonalAdjustment = _calculateSeasonalAdjustment(
      records,
      incomeSource.frequency,
    );

    final predictedAmount = prediction['predicted_value'] * seasonalAdjustment;
    final confidence = prediction['confidence'];

    // Tính khoảng tin cậy
    final standardDeviation = _calculateStandardDeviation(
      records.map((r) => r.netAmount).toList(),
    );
    final confidenceInterval =
        standardDeviation * 1.96; // 95% confidence interval

    return {
      'predicted_amount': predictedAmount,
      'confidence': confidence,
      'confidence_interval': confidenceInterval,
      'min_prediction': predictedAmount - confidenceInterval,
      'max_prediction': predictedAmount + confidenceInterval,
      'method': 'linear_regression_seasonal',
      'analysis': _generatePredictionAnalysis(
        predictedAmount,
        incomeSource.baseAmount,
        confidence,
      ),
      'seasonal_factor': seasonalAdjustment,
    };
  }

  // Tối ưu thuế
  static Map<String, dynamic> optimizeTaxDeductions(
    SalaryRecord record,
    IncomeSource incomeSource,
  ) {
    final grossAmount = record.grossAmount;
    final netAmount = record.netAmount;
    final currentTaxAmount = grossAmount - netAmount - record.deductionsAmount;
    final effectiveTaxRate = (currentTaxAmount / grossAmount) * 100;

    // Gợi ý các khoản khấu trừ hợp pháp
    List<Map<String, dynamic>> suggestions = [];

    // Bảo hiểm y tế
    if (record.deductionsAmount < grossAmount * 0.015) {
      suggestions.add({
        'type': 'health_insurance',
        'description': 'Mua bảo hiểm y tế để giảm thuế',
        'potential_savings': grossAmount * 0.01 * (incomeSource.taxRate / 100),
        'max_deduction': grossAmount * 0.015,
      });
    }

    // Đóng góp từ thiện
    suggestions.add({
      'type': 'charity',
      'description': 'Đóng góp từ thiện (tối đa 2% thu nhập)',
      'potential_savings': grossAmount * 0.02 * (incomeSource.taxRate / 100),
      'max_deduction': grossAmount * 0.02,
    });

    // Học tập và phát triển kỹ năng
    suggestions.add({
      'type': 'education',
      'description': 'Chi phí học tập và đào tạo nghề nghiệp',
      'potential_savings': grossAmount * 0.01 * (incomeSource.taxRate / 100),
      'max_deduction': grossAmount * 0.01,
    });

    final totalPotentialSavings = suggestions.fold<double>(
      0,
      (sum, item) => sum + (item['potential_savings'] as double),
    );

    return {
      'current_tax_rate': effectiveTaxRate,
      'current_tax_amount': currentTaxAmount,
      'optimization_suggestions': suggestions,
      'total_potential_savings': totalPotentialSavings,
      'optimized_tax_rate':
          effectiveTaxRate - (totalPotentialSavings / grossAmount * 100),
      'analysis': _generateTaxOptimizationAnalysis(
        effectiveTaxRate,
        totalPotentialSavings,
        grossAmount,
      ),
    };
  }

  // Helper methods
  static int _getMonthsDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  static Map<String, dynamic> _linearRegression(List<SalaryRecord> records) {
    final n = records.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble(); // Time index
      final y = records[i].netAmount;

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Predict next value
    final predictedValue = slope * n + intercept;

    // Calculate R-squared for confidence
    final yMean = sumY / n;
    double ssTotal = 0, ssRes = 0;

    for (int i = 0; i < n; i++) {
      final predicted = slope * i + intercept;
      final actual = records[i].netAmount;

      ssTotal += pow(actual - yMean, 2);
      ssRes += pow(actual - predicted, 2);
    }

    final rSquared = 1 - (ssRes / ssTotal);

    return {
      'predicted_value': predictedValue,
      'confidence': rSquared.clamp(0.0, 1.0),
      'slope': slope,
      'intercept': intercept,
    };
  }

  static double _calculateSeasonalAdjustment(
    List<SalaryRecord> records,
    String frequency,
  ) {
    switch (frequency) {
      case 'monthly':
        // Kiểm tra tháng hiện tại và điều chỉnh theo mùa
        final currentMonth = DateTime.now().month;
        if (currentMonth == 12 || currentMonth == 1) {
          return 1.2; // Tháng 13, Tết
        }
        if (currentMonth >= 6 && currentMonth <= 8) {
          return 0.95; // Hè, ít thưởng
        }
        return 1.0;
      case 'quarterly':
        return 1.0; // Ít biến động theo mùa
      case 'yearly':
        return 1.0;
      default:
        return 1.0;
    }
  }

  static double _calculateStandardDeviation(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    return sqrt(variance);
  }

  static String _generatePredictionAnalysis(
    double predicted,
    double baseAmount,
    double confidence,
  ) {
    final difference = predicted - baseAmount;
    final percentChange = (difference / baseAmount * 100).abs();

    if (confidence > 0.7) {
      if (difference > 0) {
        return 'Dự báo lương tăng ${percentChange.toStringAsFixed(1)}% so với mức cơ bản (độ tin cậy cao)';
      } else {
        return 'Dự báo lương giảm ${percentChange.toStringAsFixed(1)}% so với mức cơ bản (độ tin cậy cao)';
      }
    } else {
      return 'Dự báo có độ tin cậy thấp, cần thêm dữ liệu để phân tích chính xác';
    }
  }

  static String _generateTaxOptimizationAnalysis(
    double currentRate,
    double savings,
    double gross,
  ) {
    final savingsPercent = (savings / gross * 100);
    if (savingsPercent > 2) {
      return 'Có thể tiết kiệm đáng kể ${savingsPercent.toStringAsFixed(1)}% thuế thu nhập';
    } else if (savingsPercent > 1) {
      return 'Có cơ hội tiết kiệm thuế ${savingsPercent.toStringAsFixed(1)}%';
    } else {
      return 'Mức thuế hiện tại đã khá tối ưu';
    }
  }
}

