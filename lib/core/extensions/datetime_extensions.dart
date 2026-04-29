// lib/core/extensions/datetime_extensions.dart

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  // ── Formatações ──────────────────────────────────────────────────────────

  /// Ex: "23/04/2026"
  String get formatted => DateFormat('dd/MM/yyyy').format(this);

  /// Ex: "23 de abr. de 2026"
  String get formattedLong =>
      DateFormat("d 'de' MMM 'de' yyyy", 'pt_BR').format(this);

  /// Ex: "abr. 2026"
  String get formattedMonthYear =>
      DateFormat("MMM 'de' yyyy", 'pt_BR').format(this);

  /// Ex: "Abril 2026"
  String get formattedMonthYearFull =>
      DateFormat('MMMM yyyy', 'pt_BR').format(this);

  /// Ex: "23/04"
  String get formattedShort => DateFormat('dd/MM').format(this);

  /// Ex: "23/04/2026 14:30"
  String get formattedWithTime =>
      DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Ex: "202604" — usado como ID de fatura
  String get yearMonthKey => DateFormat('yyyyMM').format(this);

  // ── Comparações ──────────────────────────────────────────────────────────

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear => year == DateTime.now().year;

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  // ── Manipulação ──────────────────────────────────────────────────────────

  /// Início do dia (00:00:00.000).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Fim do dia (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Primeiro dia do mês.
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  /// Último dia do mês.
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  /// Próximo mês.
  DateTime get nextMonth => DateTime(year, month + 1, 1);

  /// Mês anterior.
  DateTime get previousMonth => DateTime(year, month - 1, 1);

  /// Converte para [Timestamp] do Firestore via milissegundos.
  int get toMillis => millisecondsSinceEpoch;
}

extension NullableDateTimeExtensions on DateTime? {
  String get formattedOrEmpty =>
      this == null ? '' : this!.formatted;
}
