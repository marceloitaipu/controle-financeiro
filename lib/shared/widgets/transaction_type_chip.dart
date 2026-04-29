// lib/shared/widgets/transaction_type_chip.dart

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Tipo de transação.
enum TransactionType { income, expense, transfer }

extension TransactionTypeLabel on TransactionType {
  String get label => switch (this) {
        TransactionType.income => 'Receita',
        TransactionType.expense => 'Despesa',
        TransactionType.transfer => 'Transferência',
      };

  IconData get icon => switch (this) {
        TransactionType.income => Icons.arrow_downward_rounded,
        TransactionType.expense => Icons.arrow_upward_rounded,
        TransactionType.transfer => Icons.swap_horiz_rounded,
      };

  Color get color => switch (this) {
        TransactionType.income => AppColors.income,
        TransactionType.expense => AppColors.expense,
        TransactionType.transfer => AppColors.transfer,
      };
}

/// Seletor de tipo de transação em chips horizontais.
///
/// Uso:
/// ```dart
/// TransactionTypeChip(
///   value: _type,
///   onChanged: (type) => setState(() => _type = type),
/// )
/// ```
class TransactionTypeChip extends StatelessWidget {
  const TransactionTypeChip({
    super.key,
    required this.value,
    required this.onChanged,
    this.types = TransactionType.values,
  });

  /// Tipo selecionado atualmente.
  final TransactionType value;

  /// Callback ao selecionar um tipo diferente.
  final ValueChanged<TransactionType> onChanged;

  /// Tipos exibidos (padrão: todos os 3).
  final List<TransactionType> types;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: types.map((type) {
        final isSelected = type == value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onChanged(type),
            avatar: Icon(
              type.icon,
              size: 18,
              color: isSelected ? colorScheme.onPrimary : type.color,
            ),
            label: Text(type.label),
            selectedColor: type.color,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            side: BorderSide(
              color: isSelected ? type.color : colorScheme.outlineVariant,
            ),
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }
}
