// lib/features/transactions/presentation/pages/transactions_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_list_tile.dart';

/// Tela de listagem de transações com filtros, agrupamento por data e
/// indicadores de totais diários.
class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(transactionFilterNotifierProvider);
    final filterCount = filterState.activeFilterCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        actions: [
          // Badge com número de filtros ativos
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_outlined),
                tooltip: 'Filtros',
                onPressed: () => showTransactionFilterSheet(
                  context: context,
                  ref: ref,
                ),
              ),
              if (filterCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.seed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$filterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          // ── Chips de tipo rápido ───────────────────────────────────────────
          _TypeFilterBar(filterState: filterState, ref: ref),

          // ── Banner de período ativo ────────────────────────────────────────
          if (filterState.startDate != null || filterState.endDate != null)
            _ActivePeriodBanner(filterState: filterState, ref: ref),

          // ── Lista de transações ────────────────────────────────────────────
          const Expanded(child: _TransactionsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.transactionNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova transação'),
      ),
    );
  }
}

// ── Barra de filtro por tipo ──────────────────────────────────────────────────

class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({required this.filterState, required this.ref});
  final TransactionFilterState filterState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _QuickTypeChip(
            label: 'Todas',
            isSelected: filterState.type == null,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => ref
                .read(transactionFilterNotifierProvider.notifier)
                .setType(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickTypeChip(
            label: 'Receitas',
            isSelected: filterState.type == TransactionType.income,
            color: AppColors.income,
            onTap: () => ref
                .read(transactionFilterNotifierProvider.notifier)
                .setType(filterState.type == TransactionType.income
                    ? null
                    : TransactionType.income),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickTypeChip(
            label: 'Despesas',
            isSelected: filterState.type == TransactionType.expense,
            color: AppColors.expense,
            onTap: () => ref
                .read(transactionFilterNotifierProvider.notifier)
                .setType(filterState.type == TransactionType.expense
                    ? null
                    : TransactionType.expense),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickTypeChip(
            label: 'Transferências',
            isSelected: filterState.type == TransactionType.transfer,
            color: AppColors.transfer,
            onTap: () => ref
                .read(transactionFilterNotifierProvider.notifier)
                .setType(filterState.type == TransactionType.transfer
                    ? null
                    : TransactionType.transfer),
          ),
        ],
      ),
    );
  }
}

class _QuickTypeChip extends StatelessWidget {
  const _QuickTypeChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Banner de período ativo ───────────────────────────────────────────────────

class _ActivePeriodBanner extends StatelessWidget {
  const _ActivePeriodBanner({required this.filterState, required this.ref});
  final TransactionFilterState filterState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parts = <String>[];
    if (filterState.startDate != null) {
      parts.add('De ${DateFormatter.shortDate(filterState.startDate!)}');
    }
    if (filterState.endDate != null) {
      parts.add('até ${DateFormatter.shortDate(filterState.endDate!)}');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.info.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.date_range_outlined, size: 14, color: AppColors.info),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              parts.join(' '),
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ),
          GestureDetector(
            onTap: () => ref
                .read(transactionFilterNotifierProvider.notifier)
                .setDateRange(null, null),
            child: Icon(Icons.close,
                size: 16, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Lista agrupada por data ───────────────────────────────────────────────────

class _TransactionsList extends ConsumerWidget {
  const _TransactionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(watchFilteredTransactionsProvider);

    return transactionsAsync.when(
      loading: () => _buildShimmer(),
      error: (_, __) => _buildError(context),
      data: (transactions) {
        if (transactions.isEmpty) {
          return _buildEmpty(context, ref);
        }
        return _buildGroupedList(context, ref, transactions);
      },
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
  ) {
    // Agrupa por dia
    final groups = <DateTime, List<Transaction>>{};
    for (final tx in transactions) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groups.putIfAbsent(day, () => []).add(tx);
    }

    final sortedDays = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(watchFilteredTransactionsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: sortedDays.length,
        itemBuilder: (_, index) {
          final day = sortedDays[index];
          final dayTransactions = groups[day]!;
          return _DateGroup(
            date: day,
            transactions: dayTransactions,
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: const BoxDecoration(
            color: Colors.grey,
            borderRadius: AppRadius.cardRadius,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final hasFilters =
        ref.watch(transactionFilterNotifierProvider).hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasFilters
                  ? 'Nenhuma transação com os filtros aplicados.'
                  : 'Nenhuma transação cadastrada.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(transactionFilterNotifierProvider.notifier)
                    .reset(),
                icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                label: const Text('Limpar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Text(
        'Erro ao carregar transações.',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

// ── Grupo de data ─────────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.date,
    required this.transactions,
  });

  final DateTime date;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calcula o resultado do dia
    int dayResult = 0;
    for (final tx in transactions) {
      switch (tx.type) {
        case TransactionType.income:
          dayResult += tx.amount;
        case TransactionType.expense:
          dayResult -= tx.amount;
        case TransactionType.transfer:
          break;
      }
    }

    final resultColor = dayResult >= 0 ? AppColors.income : AppColors.expense;
    final resultPrefix = dayResult >= 0 ? '+' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header do dia ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDayHeader(date),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (dayResult != 0)
                Text(
                  '$resultPrefix${CurrencyFormatter.format(dayResult.abs())}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: resultColor,
                  ),
                ),
            ],
          ),
        ),

        // ── Tiles das transações ─────────────────────────────────────────────
        ...transactions.map(
          (tx) => TransactionListTile(
            transaction: tx,
            showDate: false,
            onTap: () => context.push(
              AppRoutes.transactionDetailPath(tx.id),
              extra: tx,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'HOJE';
    if (d == yesterday) return 'ONTEM';

    return DateFormatter.fullDate(date).toUpperCase();
  }
}
