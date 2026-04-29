// lib/shared/widgets/amount_field.dart

import 'package:flutter/material.dart';

import '../../core/utils/currency_input_formatter.dart';
import '../../core/utils/validators.dart';

/// Campo monetário com máscara automática R$ 1.234,56.
///
/// Usa [CurrencyInputFormatter] internamente.
/// Para ler o valor numérico, use [CurrencyInputFormatter.extractValue].
///
/// Uso:
/// ```dart
/// final _amountController = TextEditingController();
///
/// AmountField(
///   label: 'Valor',
///   controller: _amountController,
///   validator: Validators.amount,
/// )
///
/// // Para ler o valor:
/// final value = CurrencyInputFormatter.extractValue(_amountController.text);
/// ```
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    this.label = 'Valor',
    this.hint = 'R\$ 0,00',
    this.controller,
    this.focusNode,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Valor inicial em reais (ex: 123.45 → "R$ 123,45").
  final double? initialValue;

  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final effectiveValidator = validator ?? Validators.amount;
    final effectiveController = _buildController();

    return TextFormField(
      controller: effectiveController,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textInputAction: textInputAction ?? TextInputAction.next,
      inputFormatters: [CurrencyInputFormatter()],
      validator: effectiveValidator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      autofocus: autofocus,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.attach_money_rounded),
        // Sem botão de limpar — campo monetário sempre mostra R$ 0,00
      ),
    );
  }

  TextEditingController? _buildController() {
    if (controller != null) return controller;
    if (initialValue != null) {
      final formatter = CurrencyInputFormatter();
      final formatted = formatter.formatValue(initialValue!);
      return TextEditingController(text: formatted);
    }
    return null;
  }
}
