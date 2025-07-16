class AIAnalytics {
  final int? id;
  final String analysisType;
  final String? inputData;
  final String? resultData;
  final double confidenceScore;
  final DateTime createdAt;

  AIAnalytics({
    this.id,
    required this.analysisType,
    this.inputData,
    this.resultData,
    required this.confidenceScore,
    required this.createdAt,
  });

  factory AIAnalytics.fromMap(Map<String, dynamic> map) {
    return AIAnalytics(
      id: map['id'],
      analysisType: map['analysis_type'],
      inputData: map['input_data'],
      resultData: map['result_data'],
      confidenceScore: map['confidence_score'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'analysis_type': analysisType,
      'input_data': inputData,
      'result_data': resultData,
      'confidence_score': confidenceScore,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

