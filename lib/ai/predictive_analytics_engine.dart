import 'dart:math' as math;
import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/salary_record.dart';
import '../models/income_source.dart';

class PredictiveAnalyticsEngine {
  // Main prediction method
  static Map<String, dynamic> predictFutureSpending({
    required List<Transaction> transactions,
    required List<Bill> bills,
    required List<SalaryRecord> salaryRecords,
    required List<IncomeSource> incomeSources,
    int monthsToPredict = 6,
  }) {
    final expenseTransactions = transactions
        .where((t) => t.type == 'expense')
        .toList();

    if (expenseTransactions.length < 10) {
      return {
        'status': 'insufficient_data',
        'message': 'Cần ít nhất 10 giao dịch để dự đoán chính xác',
        'predictions': <Map<String, dynamic>>[],
      };
    }

    // Sort transactions by date
    expenseTransactions.sort(
      (a, b) => a.transactionDate.compareTo(b.transactionDate),
    );

    // Generate predictions using multiple methods
    final linearRegression = _linearRegressionPrediction(
      expenseTransactions,
      monthsToPredict,
    );
    final seasonalPrediction = _seasonalPrediction(
      expenseTransactions,
      monthsToPredict,
    );
    final trendPrediction = _trendAnalysisPrediction(
      expenseTransactions,
      monthsToPredict,
    );
    final billBasedPrediction = _billBasedPrediction(bills, monthsToPredict);
    final patternPrediction = _patternBasedPrediction(
      expenseTransactions,
      monthsToPredict,
    );

    // Ensemble prediction (weighted average)
    final ensemblePrediction = _ensemblePrediction([
      {'prediction': linearRegression, 'weight': 0.25},
      {'prediction': seasonalPrediction, 'weight': 0.25},
      {'prediction': trendPrediction, 'weight': 0.20},
      {'prediction': billBasedPrediction, 'weight': 0.20},
      {'prediction': patternPrediction, 'weight': 0.10},
    ]);

    // Calculate confidence score
    final confidenceScore = _calculateConfidenceScore(
      expenseTransactions,
      ensemblePrediction,
    );

    // Generate insights
    final insights = _generatePredictionInsights(
      expenseTransactions,
      ensemblePrediction,
      bills,
      salaryRecords,
    );

    return {
      'status': 'success',
      'predictions': ensemblePrediction,
      'confidence_score': confidenceScore,
      'insights': insights,
      'methods': {
        'linear_regression': linearRegression,
        'seasonal': seasonalPrediction,
        'trend': trendPrediction,
        'bill_based': billBasedPrediction,
        'pattern_based': patternPrediction,
      },
    };
  }

  // Linear regression prediction
  static List<Map<String, dynamic>> _linearRegressionPrediction(
    List<Transaction> transactions,
    int months,
  ) {
    final monthlyData = _groupTransactionsByMonth(transactions);
    final predictions = <Map<String, dynamic>>[];

    if (monthlyData.length < 3) {
      return predictions;
    }

    // Prepare data for regression
    final x = List.generate(monthlyData.length, (i) => i.toDouble());
    final y = monthlyData.values.toList();

    // Calculate linear regression coefficients
    final regression = _calculateLinearRegression(x, y);
    final slope = regression['slope']!;
    final intercept = regression['intercept']!;

    // Generate future predictions
    final now = DateTime.now();
    for (int i = 1; i <= months; i++) {
      final futureX = monthlyData.length + i - 1;
      final predictedAmount = slope * futureX + intercept;
      final predictionDate = DateTime(now.year, now.month + i, 1);

      predictions.add({
        'date': predictionDate,
        'amount': math.max(0, predictedAmount), // Ensure non-negative
        'method': 'linear_regression',
        'confidence': regression['r_squared'],
      });
    }

    return predictions;
  }

  // Seasonal prediction based on historical patterns
  static List<Map<String, dynamic>> _seasonalPrediction(
    List<Transaction> transactions,
    int months,
  ) {
    final monthlyData = _groupTransactionsByMonth(transactions);
    final seasonalFactors = _calculateSeasonalFactors(transactions);
    final predictions = <Map<String, dynamic>>[];

    if (monthlyData.isEmpty) return predictions;

    // Calculate base trend
    final values = monthlyData.values.toList();
    final averageSpending = values.reduce((a, b) => a + b) / values.length;

    final now = DateTime.now();
    for (int i = 1; i <= months; i++) {
      final predictionDate = DateTime(now.year, now.month + i, 1);
      final monthKey = predictionDate.month;
      final seasonalFactor = seasonalFactors[monthKey] ?? 1.0;

      final predictedAmount = averageSpending * seasonalFactor;

      predictions.add({
        'date': predictionDate,
        'amount': predictedAmount,
        'method': 'seasonal',
        'seasonal_factor': seasonalFactor,
        'confidence': _calculateSeasonalConfidence(seasonalFactors),
      });
    }

    return predictions;
  }

  // Trend analysis prediction
  static List<Map<String, dynamic>> _trendAnalysisPrediction(
    List<Transaction> transactions,
    int months,
  ) {
    final monthlyData = _groupTransactionsByMonth(transactions);
    final predictions = <Map<String, dynamic>>[];

    if (monthlyData.length < 3) return predictions;

    // Calculate moving averages and trends
    final movingAverages = _calculateMovingAverage(
      monthlyData.values.toList(),
      3,
    );
    final trendSlope = _calculateTrendSlope(movingAverages);

    final lastValue = monthlyData.values.last;
    final now = DateTime.now();

    for (int i = 1; i <= months; i++) {
      final predictionDate = DateTime(now.year, now.month + i, 1);
      final predictedAmount = lastValue + (trendSlope * i);

      predictions.add({
        'date': predictionDate,
        'amount': math.max(0, predictedAmount),
        'method': 'trend_analysis',
        'trend_slope': trendSlope,
        'confidence': _calculateTrendConfidence(movingAverages),
      });
    }

    return predictions;
  }

  // Bill-based prediction
  static List<Map<String, dynamic>> _billBasedPrediction(
    List<Bill> bills,
    int months,
  ) {
    final predictions = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 1; i <= months; i++) {
      final predictionDate = DateTime(now.year, now.month + i, 1);
      double totalBillAmount = 0;

      for (final bill in bills.where((b) => b.isActive)) {
        final monthlyAmount = _calculateMonthlyBillAmount(bill);
        totalBillAmount += monthlyAmount;
      }

      predictions.add({
        'date': predictionDate,
        'amount': totalBillAmount,
        'method': 'bill_based',
        'bill_count': bills.where((b) => b.isActive).length,
        'confidence': 0.9, // High confidence for fixed bills
      });
    }

    return predictions;
  }

  // Pattern-based prediction using historical spending patterns
  static List<Map<String, dynamic>> _patternBasedPrediction(
    List<Transaction> transactions,
    int months,
  ) {
    final patterns = _identifySpendingPatterns(transactions);
    final predictions = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 1; i <= months; i++) {
      final predictionDate = DateTime(now.year, now.month + i, 1);
      double predictedAmount = 0;

      // Apply identified patterns
      for (final pattern in patterns) {
        predictedAmount += pattern['monthly_impact'] as double;
      }

      predictions.add({
        'date': predictionDate,
        'amount': predictedAmount,
        'method': 'pattern_based',
        'patterns_count': patterns.length,
        'confidence': _calculatePatternConfidence(patterns),
      });
    }

    return predictions;
  }

  // Ensemble prediction (weighted average of all methods)
  static List<Map<String, dynamic>> _ensemblePrediction(
    List<Map<String, dynamic>> methodPredictions,
  ) {
    if (methodPredictions.isEmpty) return [];

    final predictions = <Map<String, dynamic>>[];
    final firstMethod =
        methodPredictions.first['prediction'] as List<Map<String, dynamic>>;

    for (int i = 0; i < firstMethod.length; i++) {
      final date = firstMethod[i]['date'] as DateTime;
      double weightedSum = 0;
      double totalWeight = 0;
      double totalConfidence = 0;

      for (final methodData in methodPredictions) {
        final prediction =
            methodData['prediction'] as List<Map<String, dynamic>>;
        final weight = methodData['weight'] as double;

        if (i < prediction.length) {
          final amount = prediction[i]['amount'] as double;
          final confidence = prediction[i]['confidence'] as double? ?? 0.5;

          weightedSum += amount * weight * confidence;
          totalWeight += weight * confidence;
          totalConfidence += confidence * weight;
        }
      }

      final finalAmount = totalWeight > 0 ? weightedSum / totalWeight : 0;
      final finalConfidence = totalWeight > 0
          ? totalConfidence / methodPredictions.length
          : 0;

      predictions.add({
        'date': date,
        'amount': finalAmount,
        'method': 'ensemble',
        'confidence': finalConfidence,
        'variance': _calculatePredictionVariance(methodPredictions, i),
      });
    }

    return predictions;
  }

  // Helper methods for calculations

  static Map<String, double> _groupTransactionsByMonth(
    List<Transaction> transactions,
  ) {
    final monthlyData = <String, double>{};

    for (final transaction in transactions) {
      final monthKey =
          '${transaction.transactionDate.year}-${transaction.transactionDate.month.toString().padLeft(2, '0')}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + transaction.amount;
    }

    return monthlyData;
  }

  static Map<String, double> _calculateLinearRegression(
    List<double> x,
    List<double> y,
  ) {
    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((val) => val * val).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Calculate R-squared
    final yMean = sumY / n;
    double ssTotal = 0, ssRes = 0;

    for (int i = 0; i < n; i++) {
      final predicted = slope * x[i] + intercept;
      ssTotal += math.pow(y[i] - yMean, 2);
      ssRes += math.pow(y[i] - predicted, 2);
    }

    final rSquared = 1 - (ssRes / ssTotal);

    return {
      'slope': slope,
      'intercept': intercept,
      'r_squared': rSquared.clamp(0.0, 1.0),
    };
  }

  static Map<int, double> _calculateSeasonalFactors(
    List<Transaction> transactions,
  ) {
    final monthlyAverages = <int, List<double>>{};

    for (final transaction in transactions) {
      final month = transaction.transactionDate.month;
      monthlyAverages[month] = (monthlyAverages[month] ?? [])
        ..add(transaction.amount);
    }

    final seasonalFactors = <int, double>{};
    double totalAverage = 0;
    int monthCount = 0;

    // Calculate monthly averages
    for (final entry in monthlyAverages.entries) {
      final monthAvg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      totalAverage += monthAvg;
      monthCount++;
    }

    totalAverage /= monthCount;

    // Calculate seasonal factors
    for (final entry in monthlyAverages.entries) {
      final monthAvg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      seasonalFactors[entry.key] = monthAvg / totalAverage;
    }

    return seasonalFactors;
  }

  static List<double> _calculateMovingAverage(List<double> data, int window) {
    final movingAverages = <double>[];

    for (int i = window - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = i - window + 1; j <= i; j++) {
        sum += data[j];
      }
      movingAverages.add(sum / window);
    }

    return movingAverages;
  }

  static double _calculateTrendSlope(List<double> movingAverages) {
    if (movingAverages.length < 2) return 0;

    final x = List.generate(movingAverages.length, (i) => i.toDouble());
    final regression = _calculateLinearRegression(x, movingAverages);
    return regression['slope']!;
  }

  static double _calculateMonthlyBillAmount(Bill bill) {
    switch (bill.frequency) {
      case 'weekly':
        return bill.amount * 4.33; // Average weeks per month
      case 'monthly':
        return bill.amount;
      case 'quarterly':
        return bill.amount / 3;
      case 'yearly':
        return bill.amount / 12;
      default:
        return bill.amount;
    }
  }

  static List<Map<String, dynamic>> _identifySpendingPatterns(
    List<Transaction> transactions,
  ) {
    final patterns = <Map<String, dynamic>>[];

    // Pattern 1: Weekend vs Weekday spending
    final weekendSpending = transactions
        .where((t) => t.transactionDate.weekday >= 6)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final weekdaySpending = transactions
        .where((t) => t.transactionDate.weekday < 6)
        .fold<double>(0, (sum, t) => sum + t.amount);

    if (weekendSpending > weekdaySpending * 1.2) {
      patterns.add({
        'type': 'weekend_spender',
        'description': 'Chi tiêu nhiều vào cuối tuần',
        'monthly_impact': weekendSpending * 0.1, // Estimate monthly impact
        'confidence': 0.7,
      });
    }

    // Pattern 2: Paycheck-related spending spikes
    final spendingByDay = <int, double>{};
    for (final transaction in transactions) {
      final day = transaction.transactionDate.day;
      spendingByDay[day] = (spendingByDay[day] ?? 0) + transaction.amount;
    }

    final maxSpendingDay = spendingByDay.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    if (maxSpendingDay.value >
        spendingByDay.values.reduce((a, b) => a + b) /
            spendingByDay.length *
            2) {
      patterns.add({
        'type': 'paycheck_spike',
        'description': 'Chi tiêu tăng đột biến ngày ${maxSpendingDay.key}',
        'monthly_impact': maxSpendingDay.value * 0.05,
        'confidence': 0.6,
      });
    }

    return patterns;
  }

  static double _calculateConfidenceScore(
    List<Transaction> transactions,
    List<Map<String, dynamic>> predictions,
  ) {
    if (transactions.length < 10) return 0.3;
    if (transactions.length < 30) return 0.5;
    if (transactions.length < 100) return 0.7;
    return 0.9;
  }

  static double _calculateSeasonalConfidence(Map<int, double> seasonalFactors) {
    if (seasonalFactors.length < 12) return 0.5;

    // Calculate variance in seasonal factors
    final values = seasonalFactors.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) /
        values.length;

    // Lower variance = higher confidence
    return (1 - variance).clamp(0.3, 0.9);
  }

  static double _calculateTrendConfidence(List<double> movingAverages) {
    if (movingAverages.length < 3) return 0.4;

    // Calculate consistency of trend
    final differences = <double>[];
    for (int i = 1; i < movingAverages.length; i++) {
      differences.add(movingAverages[i] - movingAverages[i - 1]);
    }

    final mean = differences.reduce((a, b) => a + b) / differences.length;
    final variance =
        differences.map((d) => math.pow(d - mean, 2)).reduce((a, b) => a + b) /
        differences.length;

    // Lower variance in differences = more consistent trend = higher confidence
    return (1 / (1 + variance / 1000000)).clamp(0.3, 0.8);
  }

  static double _calculatePatternConfidence(
    List<Map<String, dynamic>> patterns,
  ) {
    if (patterns.isEmpty) return 0.3;

    // Average confidence of all patterns
    final avgConfidence =
        patterns.map((p) => p['confidence'] as double).reduce((a, b) => a + b) /
        patterns.length;

    return avgConfidence;
  }

  static double _calculatePredictionVariance(
    List<Map<String, dynamic>> methodPredictions,
    int index,
  ) {
    final amounts = <double>[];

    for (final methodData in methodPredictions) {
      final prediction = methodData['prediction'] as List<Map<String, dynamic>>;
      if (index < prediction.length) {
        amounts.add(prediction[index]['amount'] as double);
      }
    }

    if (amounts.length < 2) return 0;

    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final variance =
        amounts.map((a) => math.pow(a - mean, 2)).reduce((a, b) => a + b) /
        amounts.length;

    return math.sqrt(variance);
  }

  static List<Map<String, dynamic>> _generatePredictionInsights(
    List<Transaction> transactions,
    List<Map<String, dynamic>> predictions,
    List<Bill> bills,
    List<SalaryRecord> salaryRecords,
  ) {
    final insights = <Map<String, dynamic>>[];

    if (predictions.isNotEmpty) {
      final firstPrediction = predictions.first;
      final lastPrediction = predictions.last;
      final trend =
          (lastPrediction['amount'] as double) -
          (firstPrediction['amount'] as double);

      if (trend > 0) {
        insights.add({
          'type': 'trend_warning',
          'title': 'Chi tiêu có xu hướng tăng',
          'description':
              'Chi tiêu dự kiến tăng ${(trend / 1000000).toStringAsFixed(1)}M trong ${predictions.length} tháng tới',
          'severity': trend > 5000000 ? 'high' : 'medium',
        });
      } else if (trend < -1000000) {
        insights.add({
          'type': 'trend_positive',
          'title': 'Chi tiêu có xu hướng giảm',
          'description':
              'Chi tiêu dự kiến giảm ${(trend.abs() / 1000000).toStringAsFixed(1)}M trong ${predictions.length} tháng tới',
          'severity': 'low',
        });
      }

      // Budget recommendations
      final avgPrediction =
          predictions
              .map((p) => p['amount'] as double)
              .reduce((a, b) => a + b) /
          predictions.length;

      insights.add({
        'type': 'budget_recommendation',
        'title': 'Gợi ý ngân sách',
        'description':
            'Nên đặt ngân sách khoảng ${(avgPrediction / 1000000).toStringAsFixed(1)}M/tháng',
        'severity': 'info',
      });

      // Seasonal insights
      final highestMonth = predictions.reduce(
        (a, b) => (a['amount'] as double) > (b['amount'] as double) ? a : b,
      );
      final monthName = _getVietnameseMonthName(
        (highestMonth['date'] as DateTime).month,
      );

      insights.add({
        'type': 'seasonal_insight',
        'title': 'Dự báo mùa vụ',
        'description':
            'Tháng $monthName dự kiến chi tiêu cao nhất: ${((highestMonth['amount'] as double) / 1000000).toStringAsFixed(1)}M',
        'severity': 'info',
      });
    }

    return insights;
  }

  static String _getVietnameseMonthName(int month) {
    const monthNames = [
      '',
      'Một',
      'Hai',
      'Ba',
      'Tư',
      'Năm',
      'Sáu',
      'Bảy',
      'Tám',
      'Chín',
      'Mười',
      'Mười một',
      'Mười hai',
    ];
    return monthNames[month];
  }

  // Advanced analytics methods

  static Map<String, dynamic> analyzeSpendingVolatility(
    List<Transaction> transactions,
  ) {
    final monthlyData = _groupTransactionsByMonth(transactions);
    final amounts = monthlyData.values.toList();

    if (amounts.length < 3) {
      return {'volatility': 0, 'risk_level': 'unknown'};
    }

    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final variance =
        amounts.map((a) => math.pow(a - mean, 2)).reduce((a, b) => a + b) /
        amounts.length;
    final standardDeviation = math.sqrt(variance);
    final volatility = standardDeviation / mean;

    String riskLevel;
    if (volatility < 0.2) {
      riskLevel = 'low';
    } else if (volatility < 0.4) {
      riskLevel = 'medium';
    } else {
      riskLevel = 'high';
    }

    return {
      'volatility': volatility,
      'risk_level': riskLevel,
      'standard_deviation': standardDeviation,
      'mean_spending': mean,
    };
  }

  static Map<String, dynamic> predictCashFlow({
    required List<Transaction> transactions,
    required List<SalaryRecord> salaryRecords,
    required List<Bill> bills,
    int monthsToPredict = 3,
  }) {
    final expensePredictions = predictFutureSpending(
      transactions: transactions,
      bills: bills,
      salaryRecords: salaryRecords,
      incomeSources: [],
      monthsToPredict: monthsToPredict,
    );

    // Simple income prediction based on salary records
    final incomeForecasts = <Map<String, dynamic>>[];
    if (salaryRecords.isNotEmpty) {
      final avgIncome =
          salaryRecords.map((s) => s.netAmount).reduce((a, b) => a + b) /
          salaryRecords.length;

      final now = DateTime.now();
      for (int i = 1; i <= monthsToPredict; i++) {
        incomeForecasts.add({
          'date': DateTime(now.year, now.month + i, 1),
          'amount': avgIncome,
          'confidence': 0.8,
        });
      }
    }

    // Calculate net cash flow
    final cashFlowForecasts = <Map<String, dynamic>>[];
    final expensePreds =
        expensePredictions['predictions'] as List<Map<String, dynamic>>;

    for (
      int i = 0;
      i < expensePreds.length && i < incomeForecasts.length;
      i++
    ) {
      final expense = expensePreds[i]['amount'] as double;
      final income = incomeForecasts[i]['amount'] as double;
      final netCashFlow = income - expense;

      cashFlowForecasts.add({
        'date': expensePreds[i]['date'],
        'income': income,
        'expense': expense,
        'net_cash_flow': netCashFlow,
        'confidence': math.min(
          expensePreds[i]['confidence'] as double,
          incomeForecasts[i]['confidence'] as double,
        ),
      });
    }

    return {
      'cash_flow_forecasts': cashFlowForecasts,
      'income_forecasts': incomeForecasts,
      'expense_forecasts': expensePreds,
    };
  }
}

