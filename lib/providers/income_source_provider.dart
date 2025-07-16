import 'package:flutter/foundation.dart';
import '../models/income_source.dart';
import '../models/salary_record.dart';
import '../services/income_source_service.dart';
import '../services/salary_record_service.dart';

class IncomeSourceProvider with ChangeNotifier {
  List<IncomeSource> _incomeSources = [];
  List<SalaryRecord> _salaryRecords = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<IncomeSource> get incomeSources => _incomeSources;
  List<IncomeSource> get activeIncomeSources =>
      _incomeSources.where((source) => source.isActive).toList();
  List<SalaryRecord> get salaryRecords => _salaryRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics
  double get totalMonthlyIncome {
    double total = 0;
    for (final source in activeIncomeSources) {
      switch (source.frequency) {
        case 'monthly':
          total += source.baseAmount;
          break;
        case 'weekly':
          total += source.baseAmount * 4.33; // Average weeks per month
          break;
        case 'daily':
          total += source.baseAmount * 30; // Average days per month
          break;
        case 'quarterly':
          total += source.baseAmount / 3;
          break;
        case 'yearly':
          total += source.baseAmount / 12;
          break;
      }
    }
    return total;
  }

  // Initialize data
  Future<void> initialize() async {
    await loadIncomeSources();
    await loadSalaryRecords();
  }

  // Load income sources
  Future<void> loadIncomeSources() async {
    try {
      _setLoading(true);
      _incomeSources = await IncomeSourceService.getAll();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load income sources: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load salary records
  Future<void> loadSalaryRecords() async {
    try {
      _salaryRecords = await SalaryRecordService.getAll();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load salary records: $e');
    }
  }

  // Add income source
  Future<bool> addIncomeSource(IncomeSource incomeSource) async {
    try {
      _setLoading(true);
      final id = await IncomeSourceService.insert(incomeSource);
      final newIncomeSource = incomeSource.copyWith(id: id);
      _incomeSources.add(newIncomeSource);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add income source: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update income source
  Future<bool> updateIncomeSource(IncomeSource incomeSource) async {
    try {
      _setLoading(true);
      await IncomeSourceService.update(incomeSource);
      final index = _incomeSources.indexWhere(
        (source) => source.id == incomeSource.id,
      );
      if (index != -1) {
        _incomeSources[index] = incomeSource;
      }
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update income source: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete income source
  Future<bool> deleteIncomeSource(int id) async {
    try {
      _setLoading(true);
      await IncomeSourceService.delete(id);
      _incomeSources.removeWhere((source) => source.id == id);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete income source: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add salary record
  Future<bool> addSalaryRecord(SalaryRecord salaryRecord) async {
    try {
      _setLoading(true);
      final id = await SalaryRecordService.insert(salaryRecord);
      final newRecord = salaryRecord.copyWith(id: id);
      _salaryRecords.insert(0, newRecord);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add salary record: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get salary records for specific income source
  List<SalaryRecord> getSalaryRecordsForSource(int incomeSourceId) {
    return _salaryRecords
        .where((record) => record.incomeSourceId == incomeSourceId)
        .toList();
  }

  // Get recent salary records
  List<SalaryRecord> getRecentSalaryRecords([int limit = 10]) {
    final sortedRecords = List<SalaryRecord>.from(_salaryRecords);
    sortedRecords.sort((a, b) => b.receivedDate.compareTo(a.receivedDate));
    return sortedRecords.take(limit).toList();
  }

  // Get salary growth analysis
  Map<String, dynamic> getSalaryGrowthAnalysis(int incomeSourceId) {
    final records = getSalaryRecordsForSource(incomeSourceId);
    if (records.length < 2) {
      return {
        'growth_rate': 0.0,
        'trend': 'insufficient_data',
        'average_net': 0.0,
        'total_records': records.length,
      };
    }

    records.sort((a, b) => a.receivedDate.compareTo(b.receivedDate));

    final firstRecord = records.first;
    final lastRecord = records.last;
    final monthsDiff =
        lastRecord.receivedDate.difference(firstRecord.receivedDate).inDays /
        30.44;

    double growthRate = 0.0;
    if (monthsDiff > 0 && firstRecord.netAmount > 0) {
      growthRate =
          ((lastRecord.netAmount - firstRecord.netAmount) /
              firstRecord.netAmount) /
          monthsDiff *
          100;
    }

    final averageNet =
        records.fold<double>(0, (sum, record) => sum + record.netAmount) /
        records.length;

    String trend = 'stable';
    if (growthRate > 2) {
      trend = 'increasing';
    } else if (growthRate < -2) {
      trend = 'decreasing';
    }

    return {
      'growth_rate': growthRate,
      'trend': trend,
      'average_net': averageNet,
      'total_records': records.length,
      'period_months': monthsDiff,
      'first_amount': firstRecord.netAmount,
      'last_amount': lastRecord.netAmount,
    };
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

// Extension for IncomeSource model
extension IncomeSourceExtension on IncomeSource {
  IncomeSource copyWith({
    int? id,
    String? name,
    String? type,
    double? baseAmount,
    String? frequency,
    double? taxRate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return IncomeSource(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      baseAmount: baseAmount ?? this.baseAmount,
      frequency: frequency ?? this.frequency,
      taxRate: taxRate ?? this.taxRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Extension for SalaryRecord model
extension SalaryRecordExtension on SalaryRecord {
  SalaryRecord copyWith({
    int? id,
    int? incomeSourceId,
    double? grossAmount,
    double? netAmount,
    double? bonusAmount,
    double? deductionsAmount,
    DateTime? receivedDate,
    int? workingDays,
    String? notes,
  }) {
    return SalaryRecord(
      id: id ?? this.id,
      incomeSourceId: incomeSourceId ?? this.incomeSourceId,
      grossAmount: grossAmount ?? this.grossAmount,
      netAmount: netAmount ?? this.netAmount,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      deductionsAmount: deductionsAmount ?? this.deductionsAmount,
      receivedDate: receivedDate ?? this.receivedDate,
      workingDays: workingDays ?? this.workingDays,
      notes: notes ?? this.notes,
    );
  }
}

