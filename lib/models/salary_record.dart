class SalaryRecord {
  final int? id;
  final int incomeSourceId;
  final double grossAmount;
  final double netAmount;
  final double bonusAmount;
  final double deductionsAmount;
  final DateTime receivedDate;
  final int workingDays;
  final String? notes;

  SalaryRecord({
    this.id,
    required this.incomeSourceId,
    required this.grossAmount,
    required this.netAmount,
    required this.bonusAmount,
    required this.deductionsAmount,
    required this.receivedDate,
    required this.workingDays,
    this.notes,
  });

  // Thêm getters để tương thích với code khác
  double get amount => netAmount; // Alias cho netAmount
  DateTime get date => receivedDate; // Alias cho receivedDate

  factory SalaryRecord.fromMap(Map<String, dynamic> map) {
    return SalaryRecord(
      id: map['id'],
      incomeSourceId: map['income_source_id'],
      grossAmount: map['gross_amount'],
      netAmount: map['net_amount'],
      bonusAmount: map['bonus_amount'],
      deductionsAmount: map['deductions_amount'],
      receivedDate: DateTime.parse(map['received_date']),
      workingDays: map['working_days'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'income_source_id': incomeSourceId,
      'gross_amount': grossAmount,
      'net_amount': netAmount,
      'bonus_amount': bonusAmount,
      'deductions_amount': deductionsAmount,
      'received_date': receivedDate.toIso8601String(),
      'working_days': workingDays,
      'notes': notes,
    };
  }
}

