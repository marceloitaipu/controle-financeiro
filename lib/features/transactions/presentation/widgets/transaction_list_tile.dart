// lib/features/transactions/presentation/widgets/transaction_list_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/transaction.dart';

/// Tile de transação reutilizável para listas e grids.
///
/// Exibe: ícone de tipo / categoria, descrição, data e valor com sinal.
/// Indicador de status pendente (ícone de relógio) quando aplicável.
class TransactionListTile extends ConsumerWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = true,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  /// Se false, omite a data/hora — use quando um header de data agrupa os itens.
  final bool showDate;

  Color get _amountColor => switch (transaction.type) {
        TransactionType.income => AppColors.income,
        TransactionType.expense => AppColors.expense,
        TransactionType.transfer => AppColors.transfer,
      };

  IconData get _typeIcon => switch (transaction.type) {
        TransactionType.income => Icons.arrow_circle_up_outlined,
        TransactionType.expense => Icons.arrow_circle_down_outlined,
        TransactionType.transfer => Icons.swap_horiz_outlined,
      };

  String get _amountPrefix => switch (transaction.type) {
        TransactionType.income => '+',
        TransactionType.expense => '-',
        TransactionType.transfer => '',
      };

  bool get _isPending =>
      transaction.status == TransactionStatus.pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(watchCategoriesProvider(null));
    final category = categoriesAsync.valueOrNull
        ?.where((c) => c.id == transaction.categoryId)
        .firstOrNull;

    final iconColor =
        category != null ? category.color : _amountColor;
    final iconData =
        category != null ? category.icon : _typeIcon;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardRadius,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: _isPending
              ? colorScheme.surface.withValues(alpha: 0.7)
              : colorScheme.surface,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.sm,
          border: Border.all(
            color: _isPending
                ? AppColors.warning.withValues(alpha: 0.4)
                : colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            // ── Ícone ──────────────────────────────────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: AppRadius.chipRadius,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Conteúdo ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _isPending
                                ? colorScheme.onSurface.withValues(alpha: 0.6)
                                : colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isPending) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.schedule_outlined,
                          size: 13,
                          color: AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (category != null) ...[
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: Text(
                              '·',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                      if (showDate)
                        Text(
                          DateFormatter.relative(transaction.date),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Valor ──────────────────────────────────────────────────────
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$_amountPrefix${CurrencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isPending
                    ? _amountColor.withValues(alpha: 0.6)
                    : _amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
