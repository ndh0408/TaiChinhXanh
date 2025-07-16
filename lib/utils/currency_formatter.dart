import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _vndFormatter = NumberFormat('#,###', 'vi_VN');

  /// Định dạng số tiền thành chuỗi VND với dấu phân cách
  /// Ví dụ: 1500000 -> "1.500.000đ"
  static String formatVND(double amount) {
    if (amount == 0) return "0đ";

    final formatted = _vndFormatter.format(amount.abs());
    final sign = amount < 0 ? "-" : "";
    return "$sign${formatted}đ";
  }

  /// Định dạng số tiền thành chuỗi VND chi tiết
  /// Ví dụ: 1500000 -> "1.500.000 VND"
  static String formatVNDDetailed(double amount) {
    if (amount == 0) return "0 VND";

    final formatted = _vndFormatter.format(amount.abs());
    final sign = amount < 0 ? "-" : "";
    return "$sign$formatted VND";
  }

  /// Định dạng số tiền ngắn gọn
  /// Ví dụ: 1500000 -> "1,5 triệu", 1000000000 -> "1 tỷ"
  static String formatVNDShort(double amount) {
    if (amount == 0) return "0đ";

    final absAmount = amount.abs();
    final sign = amount < 0 ? "-" : "";

    if (absAmount >= 1000000000) {
      final billions = absAmount / 1000000000;
      return "$sign${billions.toStringAsFixed(billions % 1 == 0 ? 0 : 1)} tỷ";
    } else if (absAmount >= 1000000) {
      final millions = absAmount / 1000000;
      return "$sign${millions.toStringAsFixed(millions % 1 == 0 ? 0 : 1)} triệu";
    } else if (absAmount >= 1000) {
      final thousands = absAmount / 1000;
      return "$sign${thousands.toStringAsFixed(thousands % 1 == 0 ? 0 : 1)}k";
    } else {
      return "$sign${absAmount.toStringAsFixed(0)}đ";
    }
  }

  /// Định dạng phần trăm
  /// Ví dụ: 0.25 -> "25%"
  static String formatPercentage(double value) {
    return "${(value * 100).toStringAsFixed(1)}%";
  }

  /// Định dạng tiền với màu sắc (dương/âm)
  static Map<String, dynamic> formatWithColor(double amount) {
    return {
      'text': formatVND(amount),
      'isPositive': amount >= 0,
      'color': amount >= 0
          ? '#4CAF50'
          : '#F44336', // Green cho dương, Red cho âm
    };
  }

  /// Parse chuỗi tiền tệ thành số
  /// Ví dụ: "1.500.000đ" -> 1500000.0
  static double parseVND(String formattedAmount) {
    try {
      String cleanText = formattedAmount
          .replaceAll('đ', '')
          .replaceAll('VND', '')
          .replaceAll('.', '')
          .replaceAll(',', '')
          .trim();

      return double.parse(cleanText);
    } catch (e) {
      return 0.0;
    }
  }

  /// Định dạng cho input field
  static String formatForInput(String input) {
    if (input.isEmpty) return '';

    // Remove all non-digits
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';

    // Format with dots
    double amount = double.parse(digits);
    return _vndFormatter.format(amount);
  }
}

