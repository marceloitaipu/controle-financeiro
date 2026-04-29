// lib/features/budgets/presentation/widgets/budget_progress_card.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';

/// Card de progresso de orçamento.
///
/// Exibe o nome da categoria, barra de progresso colorida, valor gasto vs. limite
/// e ícone de alerta quando o limiar é atingido.
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.progress,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    this.onTap,
    this.onLongPress,
  });

  final BudgetProgress progress;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  Color _progressColor(BuildContext context) {
    if (progress.isOverBudget) return AppColors.danger;
    if (progress.isAlert) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = progress.percentage.clamp(0.0, 1.0);
    final progressColor = _progressColor(context);
    final budget = progress.budget;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabeçalho ──────────────────────────────────────────────
              Row(
                children: [
                  // Ícone da categoria
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: AppRadius.chipRadius,
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                  AppSpacing.hMd,
                  // Nome + período
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          budget.period.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de alerta ou porcentagem
                  _StatusBadge(progress: progress),
                ],
              ),

              AppSpacing.vMd,

              // ── Barra de progresso ─────────────────────────────────────
              ClipRRect(
                borderRadius: AppRadius.fullRadius,
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),

              AppSpacing.vSm,

              // ── Valores ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gasto
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Gasto: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text: CurrencyFormatter.format(
                              progress.spentAmount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Limite
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Limite: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text: CurrencyFormatter.format(budget.amount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Saldo restante ─────────────────────────────────────────
              if (progress.isOverBudget) ...[
                AppSpacing.vXs,
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.danger,
                    ),
                    AppSpacing.hXs,
                    Text(
                      'Estourado em ${CurrencyFormatter.format(-progress.remaining)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                AppSpacing.vXs,
                Text(
                  'Restam ${CurrencyFormatter.format(progress.remaining)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: progress.isAlert
                        ? AppColors.warning
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge de status ────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress.percentage * 100).round();

    if (progress.isOverBudget) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, size: 12, color: AppColors.danger),
            const SizedBox(width: 4),
            Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      );
    }

    if (progress.isAlert) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Text(
          '$pct%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
      );
    }

    return Text(
      '$pct%',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
