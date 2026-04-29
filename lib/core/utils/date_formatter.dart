// lib/core/utils/date_formatter.dart

import 'package:intl/intl.dart';

/// Utilitário de formatação de datas para exibição no app.
abstract final class DateFormatter {
  /// "abril 2025"
  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', 'pt_BR').format(date);

  /// "Abr/25"
  static String shortMonthYear(DateTime date) =>
      DateFormat('MMM/yy', 'pt_BR').format(date);

  /// "28/04/2025"
  static String shortDate(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(date);

  /// "28 abr"
  static String dayMonth(DateTime date) =>
      DateFormat('dd MMM', 'pt_BR').format(date);

  /// "28 abr 2025"
  static String fullDate(DateTime date) =>
      DateFormat('dd MMM yyyy', 'pt_BR').format(date);

  /// "14:30"
  static String time(DateTime date) =>
      DateFormat('HH:mm', 'pt_BR').format(date);

  /// "Hoje", "Ontem" ou "28/04/2025"
  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateDay).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    return shortDate(date);
  }

  /// "Hoje às 14:30", "Ontem às 09:00", "28/04/2025 às 14:30"
  static String relativeWithTime(DateTime date) {
    final relativeDate = relative(date);
    final timeStr = time(date);
    return '$relativeDate às $timeStr';
  }
}
