class IncomeSource {
  final int? id;
  final String name;
  final String type;
  final double baseAmount;
  final String frequency;
  final double taxRate;
  final bool isActive;
  final DateTime createdAt;

  IncomeSource({
    this.id,
    required this.name,
    required this.type,
    required this.baseAmount,
    required this.frequency,
    required this.taxRate,
    required this.isActive,
    required this.createdAt,
  });

  factory IncomeSource.fromMap(Map<String, dynamic> map) {
    return IncomeSource(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      baseAmount: map['base_amount'],
      frequency: map['frequency'],
      taxRate: map['tax_rate'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'base_amount': baseAmount,
      'frequency': frequency,
      'tax_rate': taxRate,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

