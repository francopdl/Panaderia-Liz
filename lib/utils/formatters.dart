import 'package:intl/intl.dart';

/// Text formatting utilities
class Formatters {
  /// Format currency
  static String currency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format price (currency only)
  static String price(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 2}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Format date
  static String date(DateTime dateTime, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Format date and time
  static String dateTime(DateTime dateTime, {String format = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Format time
  static String time(DateTime dateTime, {String format = 'HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Format time ago (e.g., "hace 2 horas")
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays}d';
    } else {
      return date(dateTime);
    }
  }

  /// Format number with comma separator
  static String number(int value) {
    return NumberFormat('#,##0').format(value);
  }

  /// Format decimal number
  static String decimal(double value, {int decimals = 2}) {
    return NumberFormat('0.${'0' * decimals}').format(value);
  }

  /// Format phone number
  static String phoneNumber(String value) {
    if (value.length != 9) return value;
    return '${value.substring(0, 3)} ${value.substring(3, 6)} ${value.substring(6)}';
  }

  /// Format username (capitalize first letter)
  static String username(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Capitalize first letter
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Format file size
  static String fileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var index = 0;

    while (size >= 1024 && index < suffixes.length - 1) {
      size /= 1024;
      index++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }
}
