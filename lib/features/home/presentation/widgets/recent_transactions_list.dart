// lib/features/home/presentation/widgets/recent_transactions_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Lista das últimas transações para o dashboard.
class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(watchRecentTransactionsProvider);

    return transactionsAsync.when(
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (transactions) {
        if (transactions.isEmpty) {
          return _buildEmpty(context);
        }
        return Column(
          children: transactions
              .take(7)
              .map((tx) => _TransactionTile(transaction: tx))
              .toList(),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        5,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: AppRadius.cardRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl2,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nenhuma transação ainda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final Transaction transaction;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.sm,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _amountColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.chipRadius,
            ),
            child: Icon(_typeIcon, color: _amountColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.relative(transaction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$_amountPrefix${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
