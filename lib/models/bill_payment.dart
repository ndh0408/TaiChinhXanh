class BillPayment {
  final int? id;
  final int billId;
  final double amountPaid;
  final double? lateFee;
  final DateTime paidDate;
  final DateTime dueDateWhenPaid;
  final String paymentMethod;
  final String? transactionId;
  final String? confirmationNumber;
  final String? notes;
  final bool isLate;
  final bool isPartialPayment;
  final DateTime createdAt;

  BillPayment({
    this.id,
    required this.billId,
    required this.amountPaid,
    this.lateFee,
    required this.paidDate,
    required this.dueDateWhenPaid,
    required this.paymentMethod,
    this.transactionId,
    this.confirmationNumber,
    this.notes,
    this.isLate = false,
    this.isPartialPayment = false,
    required this.createdAt,
  });

  factory BillPayment.fromMap(Map<String, dynamic> map) {
    return BillPayment(
      id: map['id'],
      billId: map['bill_id'],
      amountPaid: map['amount_paid'],
      lateFee: map['late_fee'],
      paidDate: DateTime.parse(map['paid_date']),
      dueDateWhenPaid: DateTime.parse(map['due_date_when_paid']),
      paymentMethod: map['payment_method'],
      transactionId: map['transaction_id'],
      confirmationNumber: map['confirmation_number'],
      notes: map['notes'],
      isLate: map['is_late'] == 1,
      isPartialPayment: map['is_partial_payment'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'amount_paid': amountPaid,
      'late_fee': lateFee,
      'paid_date': paidDate.toIso8601String(),
      'due_date_when_paid': dueDateWhenPaid.toIso8601String(),
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'confirmation_number': confirmationNumber,
      'notes': notes,
      'is_late': isLate ? 1 : 0,
      'is_partial_payment': isPartialPayment ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BillPayment copyWith({
    int? id,
    int? billId,
    double? amountPaid,
    double? lateFee,
    DateTime? paidDate,
    DateTime? dueDateWhenPaid,
    String? paymentMethod,
    String? transactionId,
    String? confirmationNumber,
    String? notes,
    bool? isLate,
    bool? isPartialPayment,
    DateTime? createdAt,
  }) {
    return BillPayment(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      amountPaid: amountPaid ?? this.amountPaid,
      lateFee: lateFee ?? this.lateFee,
      paidDate: paidDate ?? this.paidDate,
      dueDateWhenPaid: dueDateWhenPaid ?? this.dueDateWhenPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      confirmationNumber: confirmationNumber ?? this.confirmationNumber,
      notes: notes ?? this.notes,
      isLate: isLate ?? this.isLate,
      isPartialPayment: isPartialPayment ?? this.isPartialPayment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  double getTotalAmountPaid() {
    return amountPaid + (lateFee ?? 0.0);
  }

  int getDaysLate() {
    if (!isLate) return 0;
    return paidDate.difference(dueDateWhenPaid).inDays;
  }

  String getPaymentMethodDisplayText() {
    switch (paymentMethod) {
      case 'cash':
        return 'Tiền mặt';
      case 'bank_transfer':
        return 'Chuyển khoản';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'debit_card':
        return 'Thẻ ghi nợ';
      case 'e_wallet':
        return 'Ví điện tử';
      case 'auto_pay':
        return 'Tự động';
      case 'check':
        return 'Séc';
      case 'other':
        return 'Khác';
      default:
        return 'Khác';
    }
  }

  String getStatusDisplayText() {
    if (isPartialPayment) {
      return 'Thanh toán một phần';
    } else if (isLate) {
      return 'Thanh toán trễ ${getDaysLate()} ngày';
    } else {
      return 'Thanh toán đúng hạn';
    }
  }
}

