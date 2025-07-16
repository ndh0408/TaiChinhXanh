import 'package:flutter/foundation.dart';
import '../models/bill.dart';
import '../models/bill_payment.dart';
import '../services/bill_service.dart';

class BillProvider with ChangeNotifier {
  List<Bill> _bills = [];
  List<BillPayment> _payments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Bill> get bills => _bills;
  List<Bill> get activeBills => _bills.where((bill) => bill.isActive).toList();
  List<Bill> get overdueBills =>
      _bills.where((bill) => bill.isOverdue()).toList();
  List<Bill> get dueSoonBills =>
      _bills.where((bill) => bill.isDueSoon()).toList();
  List<BillPayment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics
  double get totalMonthlyAmount {
    return _bills.where((bill) => bill.isActive).fold<double>(0, (sum, bill) {
      switch (bill.frequency) {
        case 'weekly':
          return sum + (bill.amount * 4.33); // Average weeks per month
        case 'monthly':
          return sum + bill.amount;
        case 'quarterly':
          return sum + (bill.amount / 3);
        case 'yearly':
          return sum + (bill.amount / 12);
        default:
          return sum + bill.amount; // Default to monthly
      }
    });
  }

  double get totalPaidThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _payments
        .where(
          (payment) =>
              payment.paidDate.isAfter(startOfMonth) &&
              payment.paidDate.isBefore(endOfMonth),
        )
        .fold<double>(0, (sum, payment) => sum + payment.getTotalAmountPaid());
  }

  int get totalActiveBills => activeBills.length;
  int get totalOverdueBills => overdueBills.length;
  int get totalDueSoonBills => dueSoonBills.length;

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final bill in activeBills) {
      final monthlyAmount = _getMonthlyAmount(bill);
      totals[bill.category] = (totals[bill.category] ?? 0) + monthlyAmount;
    }
    return totals;
  }

  // Initialize data
  Future<void> initialize() async {
    await loadBills();
    await loadPayments();
  }

  // Load bills
  Future<void> loadBills() async {
    try {
      _setLoading(true);
      _bills = await BillService.getAll();
      await _updateBillStatuses();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load bills: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load payments
  Future<void> loadPayments() async {
    try {
      _payments = await BillService.getAllPayments();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load payments: $e');
    }
  }

  // Add bill
  Future<void> addBill(Bill bill) async {
    try {
      _setLoading(true);
      final id = await BillService.insert(bill);
      _bills.insert(0, bill.copyWith(id: id));
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add bill: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update bill
  Future<void> updateBill(Bill bill) async {
    try {
      _setLoading(true);
      await BillService.update(bill);
      final index = _bills.indexWhere((b) => b.id == bill.id);
      if (index >= 0) {
        _bills[index] = bill;
      }
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update bill: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete bill
  Future<void> deleteBill(int billId) async {
    try {
      _setLoading(true);
      await BillService.delete(billId);
      _bills.removeWhere((bill) => bill.id == billId);
      _payments.removeWhere((payment) => payment.billId == billId);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete bill: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle bill active status
  Future<void> toggleBillActive(int billId, bool isActive) async {
    try {
      await BillService.toggleActive(billId, isActive);
      final index = _bills.indexWhere((bill) => bill.id == billId);
      if (index >= 0) {
        _bills[index] = _bills[index].copyWith(isActive: isActive);
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle bill status: $e');
    }
  }

  // Mark bill as paid
  Future<void> markBillAsPaid(
    int billId,
    double amountPaid, {
    String paymentMethod = 'cash',
    String? transactionId,
    String? confirmationNumber,
    String? notes,
    double? lateFee,
  }) async {
    try {
      _setLoading(true);
      final updatedBill = await BillService.markAsPaid(
        billId,
        amountPaid,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        confirmationNumber: confirmationNumber,
        notes: notes,
        lateFee: lateFee,
      );

      // Update bill in list
      final index = _bills.indexWhere((bill) => bill.id == billId);
      if (index >= 0) {
        _bills[index] = updatedBill;
      }

      // Reload payments to include the new payment
      await loadPayments();

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark bill as paid: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get bills by category
  List<Bill> getBillsByCategory(String category) {
    return _bills
        .where((bill) => bill.category == category && bill.isActive)
        .toList();
  }

  // Get bills due in specific number of days
  List<Bill> getBillsDueInDays(int days) {
    final targetDate = DateTime.now().add(Duration(days: days));
    return _bills.where((bill) {
      if (!bill.isActive) return false;
      final dueDate = bill.nextDueDate ?? bill.dueDate;
      return dueDate.year == targetDate.year &&
          dueDate.month == targetDate.month &&
          dueDate.day == targetDate.day;
    }).toList();
  }

  // Get payment history for a specific bill
  List<BillPayment> getPaymentsForBill(int billId) {
    return _payments.where((payment) => payment.billId == billId).toList();
  }

  // Get upcoming bills (next 30 days)
  List<Bill> getUpcomingBills() {
    final now = DateTime.now();
    final future = now.add(const Duration(days: 30));

    return _bills.where((bill) {
      if (!bill.isActive) return false;
      final dueDate = bill.nextDueDate ?? bill.dueDate;
      return dueDate.isAfter(now) && dueDate.isBefore(future);
    }).toList();
  }

  // Search bills
  List<Bill> searchBills(String query) {
    if (query.isEmpty) return _bills;

    final lowercaseQuery = query.toLowerCase();
    return _bills
        .where(
          (bill) =>
              bill.name.toLowerCase().contains(lowercaseQuery) ||
              bill.description.toLowerCase().contains(lowercaseQuery) ||
              bill.getCategoryDisplayText().toLowerCase().contains(
                lowercaseQuery,
              ),
        )
        .toList();
  }

  // Get bills needing reminders
  List<Bill> getBillsNeedingReminders() {
    return _bills
        .where(
          (bill) => bill.isActive && (bill.isDueSoon() || bill.isOverdue()),
        )
        .toList();
  }

  // Analytics methods
  Future<Map<String, dynamic>> getBillStatistics() async {
    try {
      return await BillService.getBillStatistics();
    } catch (e) {
      _setError('Failed to get bill statistics: $e');
      return {};
    }
  }

  Future<Map<String, double>> getCategoryTotalsFromService() async {
    try {
      return await BillService.getCategoryTotals();
    } catch (e) {
      _setError('Failed to get category totals: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyPaymentTrends(int months) async {
    try {
      return await BillService.getMonthlyPaymentTrends(months);
    } catch (e) {
      _setError('Failed to get payment trends: $e');
      return [];
    }
  }

  // Notification methods
  int getNotificationCount() {
    return overdueBills.length + dueSoonBills.length;
  }

  String getNotificationMessage() {
    final overdueCount = overdueBills.length;
    final dueSoonCount = dueSoonBills.length;

    if (overdueCount > 0 && dueSoonCount > 0) {
      return '$overdueCount hÃ³a Ä‘Æ¡n quÃ¡ háº¡n, $dueSoonCount sáº¯p Ä‘áº¿n háº¡n';
    } else if (overdueCount > 0) {
      return '$overdueCount hÃ³a Ä‘Æ¡n quÃ¡ háº¡n';
    } else if (dueSoonCount > 0) {
      return '$dueSoonCount hÃ³a Ä‘Æ¡n sáº¯p Ä‘áº¿n háº¡n';
    } else {
      return 'Táº¥t cáº£ hÃ³a Ä‘Æ¡n Ä‘Ã£ Ä‘Æ°á»£c thanh toÃ¡n';
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    debugPrint('BillProvider Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _updateBillStatuses() async {
    try {
      await BillService.updateBillStatuses();
      // Reload bills to get updated statuses
      _bills = await BillService.getAll();
    } catch (e) {
      debugPrint('Failed to update bill statuses: $e');
    }
  }

  double _getMonthlyAmount(Bill bill) {
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
        return bill.amount; // Default to monthly
    }
  }

  // Bulk operations
  Future<void> markMultipleBillsAsPaid(List<int> billIds) async {
    for (final billId in billIds) {
      final bill = _bills.firstWhere((b) => b.id == billId);
      await markBillAsPaid(billId, bill.amount);
    }
  }

  Future<void> pauseMultipleBills(List<int> billIds) async {
    for (final billId in billIds) {
      await toggleBillActive(billId, false);
    }
  }

  Future<void> resumeMultipleBills(List<int> billIds) async {
    for (final billId in billIds) {
      await toggleBillActive(billId, true);
    }
  }

  // Export/Import functionality (placeholder)
  Map<String, dynamic> exportBillsData() {
    return {
      'bills': _bills.map((bill) => bill.toMap()).toList(),
      'payments': _payments.map((payment) => payment.toMap()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importBillsData(Map<String, dynamic> data) async {
    try {
      _setLoading(true);

      // This would handle importing bills from exported data
      // For now, we'll just reload the current data
      await loadBills();
      await loadPayments();

      _clearError();
    } catch (e) {
      _setError('Failed to import bills data: $e');
    } finally {
      _setLoading(false);
    }
  }
}

