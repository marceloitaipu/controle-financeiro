// lib/core/extensions/double_extensions.dart

import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

extension DoubleExtensions on double {
  // ── Formatação de moeda ───────────────────────────────────────────────────

  /// Ex: "R$ 1.234,56"
  String get toBRL {
    return NumberFormat.currency(
      locale: AppConstants.defaultLocale,
      symbol: '${AppConstants.defaultCurrencySymbol} ',
      decimalDigits: 2,
    ).format(this);
  }

  /// Ex: "1.234,56" (sem símbolo)
  String get toBRLNoSymbol {
    return NumberFormat.currency(
      locale: AppConstants.defaultLocale,
      symbol: '',
      decimalDigits: 2,
    ).format(this).trim();
  }

  /// Ex: "1,2K" ou "1,5M" para valores grandes
  String get toCompact {
    if (abs() >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (abs() >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toBRLNoSymbol;
  }

  // ── Percentual ────────────────────────────────────────────────────────────

  /// Ex: "73,5%"
  String get toPercent =>
      NumberFormat.decimalPercentPattern(
        locale: AppConstants.defaultLocale,
        decimalDigits: 1,
      ).format(this / 100);

  // ── Comparações ──────────────────────────────────────────────────────────

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;

  /// Arredonda para 2 casas decimais (padrão financeiro).
  double get rounded => double.parse(toStringAsFixed(2));
}

extension NullableDoubleExtensions on double? {
  String get toBRLOrZero => (this ?? 0.0).toBRL;
  double get orZero => this ?? 0.0;
}
