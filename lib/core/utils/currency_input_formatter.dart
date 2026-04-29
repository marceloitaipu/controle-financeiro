// lib/core/utils/currency_input_formatter.dart

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatador de entrada monetária em tempo real.
///
/// Converte a entrada do usuário em formato BRL: "1234" → "R$ 12,34"
/// (entrada em centavos, acumula da direita para a esquerda).
///
/// Uso:
/// ```dart
/// TextField(
///   inputFormatters: [CurrencyInputFormatter()],
///   keyboardType: TextInputType.number,
/// )
/// ```
class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter({
    this.symbol = 'R\$',
    this.decimalDigits = 2,
    this.locale = 'pt_BR',
    this.maxValue = 9999999.99,
  });

  final String symbol;
  final int decimalDigits;
  final String locale;
  final double maxValue;

  static final _onlyDigitsRegex = RegExp(r'[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove tudo que não é dígito
    String digits = newValue.text.replaceAll(_onlyDigitsRegex, '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Limita a 9 dígitos (9.999.999,99)
    if (digits.length > 9) {
      digits = digits.substring(digits.length - 9);
    }

    // Converte os centavos para double
    final value = double.parse(digits) / _factor;

    // Limita ao valor máximo
    if (value > maxValue) {
      return oldValue;
    }

    final formatted = _format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  double get _factor => _pow10(decimalDigits).toDouble();

  int _pow10(int n) {
    int result = 1;
    for (int i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }

  String _format(double value) {
    return NumberFormat.currency(
      locale: locale,
      symbol: '$symbol ',
      decimalDigits: decimalDigits,
    ).format(value);
  }

  /// Extrai o valor double de um texto formatado pelo formatter.
  /// Ex: "R$ 1.234,56" → 1234.56
  static double extractValue(String formattedText) {
    if (formattedText.isEmpty) return 0.0;
    final digits = formattedText.replaceAll(_onlyDigitsRegex, '');
    if (digits.isEmpty) return 0.0;
    return double.parse(digits) / 100.0;
  }

  /// Formata um valor double para exibição no campo.
  /// Ex: 1234.56 → "R$ 1.234,56"
  String formatValue(double value) => _format(value);
}
