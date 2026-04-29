// lib/features/home/presentation/widgets/month_summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Card com resumo financeiro do mês: receitas, despesas e resultado.
class MonthSummaryCard extends ConsumerWidget {
  const MonthSummaryCard({super.key, required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(monthlyIncomeProvider(month));
    final expenseAsync = ref.watch(monthlyExpenseProvider(month));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.sm,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Receitas',
                color: AppColors.income,
                icon: Icons.arrow_upward_rounded,
                valueAsync: incomeAsync,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            Expanded(
              child: _SummaryTile(
                label: 'Despesas',
                color: AppColors.expense,
                icon: Icons.arrow_downward_rounded,
                valueAsync: expenseAsync,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            Expanded(
              child: _ResultTile(
                incomeAsync: incomeAsync,
                expenseAsync: expenseAsync,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.color,
    required this.icon,
    required this.valueAsync,
  });

  final String label;
  final Color color;
  final IconData icon;
  final AsyncValue<int> valueAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          valueAsync.when(
            loading: () => _shimmerValue(),
            error: (_, __) => const Text(
              'Erro',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
            data: (value) => Text(
              CurrencyFormatter.formatCompact(value),
              style: AppTextStyles.currencySmall.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerValue() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 16,
        width: 60,
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: AppRadius.chipRadius,
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.incomeAsync,
    required this.expenseAsync,
  });

  final AsyncValue<int> incomeAsync;
  final AsyncValue<int> expenseAsync;

  @override
  Widget build(BuildContext context) {
    final isLoading = incomeAsync.isLoading || expenseAsync.isLoading;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 16,
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: AppRadius.chipRadius,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final income = incomeAsync.valueOrNull ?? 0;
    final expense = expenseAsync.valueOrNull ?? 0;
    final result = income - expense;
    final isPositive = result >= 0;
    final color = isPositive ? AppColors.income : AppColors.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyFormatter.formatCompact(result.abs()),
            style: AppTextStyles.currencySmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
