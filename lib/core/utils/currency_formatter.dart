// lib/core/utils/currency_formatter.dart

import 'package:intl/intl.dart';

/// Utilitário de formatação de valores monetários em BRL.
///
/// Todos os valores internos do app são armazenados em centavos (int).
/// Use esta classe para converter e exibir valores.
abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactBase = NumberFormat.compact(
    locale: 'pt_BR',
  );

  /// Formata centavos para o formato completo: "R$ 1.234,56"
  static String format(int cents) => _formatter.format(cents / 100);

  /// Formata double para o formato completo: "R$ 1.234,56"
  static String formatDouble(double value) => _formatter.format(value);

  /// Formata centavos com sinal: "+R$ 1.234,56" ou "-R$ 1.234,56"
  static String formatSigned(int cents) {
    final formatted = format(cents.abs());
    return cents >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Formata centavos de forma compacta para espaços reduzidos:
  /// valores < 10.000 → "R$ 9.999,99"
  /// valores >= 10.000 → "R$ 10k", "R$ 1,2M"
  static String formatCompact(int cents) {
    final value = cents / 100;
    if (value.abs() < 10000) return _formatter.format(value);
    return 'R\$ ${_compactBase.format(value)}';
  }
}
