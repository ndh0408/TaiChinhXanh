class FinancialPrediction {
  final int? id;
  final String predictionType; // 'spending', 'income', 'cash_flow'
  final DateTime predictionDate;
  final DateTime targetDate;
  final double predictedAmount;
  final double confidenceScore;
  final String method; // 'ensemble', 'linear_regression', 'seasonal', etc.
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  FinancialPrediction({
    this.id,
    required this.predictionType,
    required this.predictionDate,
    required this.targetDate,
    required this.predictedAmount,
    required this.confidenceScore,
    required this.method,
    this.metadata,
    required this.createdAt,
  });

  factory FinancialPrediction.fromMap(Map<String, dynamic> map) {
    return FinancialPrediction(
      id: map['id'],
      predictionType: map['prediction_type'],
      predictionDate: DateTime.parse(map['prediction_date']),
      targetDate: DateTime.parse(map['target_date']),
      predictedAmount: map['predicted_amount'],
      confidenceScore: map['confidence_score'],
      method: map['method'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prediction_type': predictionType,
      'prediction_date': predictionDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'predicted_amount': predictedAmount,
      'confidence_score': confidenceScore,
      'method': method,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FinancialPrediction copyWith({
    int? id,
    String? predictionType,
    DateTime? predictionDate,
    DateTime? targetDate,
    double? predictedAmount,
    double? confidenceScore,
    String? method,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return FinancialPrediction(
      id: id ?? this.id,
      predictionType: predictionType ?? this.predictionType,
      predictionDate: predictionDate ?? this.predictionDate,
      targetDate: targetDate ?? this.targetDate,
      predictedAmount: predictedAmount ?? this.predictedAmount,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      method: method ?? this.method,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  bool isHighConfidence() => confidenceScore >= 0.7;
  bool isMediumConfidence() => confidenceScore >= 0.5 && confidenceScore < 0.7;
  bool isLowConfidence() => confidenceScore < 0.5;

  String getConfidenceText() {
    if (isHighConfidence()) return 'Cao';
    if (isMediumConfidence()) return 'Trung bình';
    return 'Thấp';
  }

  String getAmountText() {
    if (predictedAmount >= 1000000) {
      return '${(predictedAmount / 1000000).toStringAsFixed(1)}M';
    } else if (predictedAmount >= 1000) {
      return '${(predictedAmount / 1000).toStringAsFixed(0)}K';
    } else {
      return predictedAmount.toStringAsFixed(0);
    }
  }

  String getMethodDisplayText() {
    switch (method) {
      case 'ensemble':
        return 'Tổng hợp AI';
      case 'linear_regression':
        return 'Hồi quy tuyến tính';
      case 'seasonal':
        return 'Phân tích mùa vụ';
      case 'trend_analysis':
        return 'Phân tích xu hướng';
      case 'bill_based':
        return 'Dựa trên hóa đơn';
      case 'pattern_based':
        return 'Nhận dạng mẫu';
      default:
        return 'AI dự đoán';
    }
  }

  int getDaysUntilTarget() {
    return targetDate.difference(DateTime.now()).inDays;
  }

  bool isTargetInPast() {
    return targetDate.isBefore(DateTime.now());
  }
}

