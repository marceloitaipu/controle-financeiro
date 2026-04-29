// lib/features/reports/presentation/pages/reports_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/report_providers.dart';
import '../widgets/category_rank_list.dart';
import '../widgets/report_bar_chart.dart';
import '../widgets/report_line_chart.dart';
import '../widgets/report_pie_chart.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          if (filter.period != ReportPeriod.thisMonth ||
              filter.categoryId != null ||
              filter.accountId != null)
            TextButton(
              onPressed: () => ref.read(reportFilterProvider.notifier).reset(),
              child: const Text('Limpar'),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Seletor de período ────────────────────────────────────────
          _PeriodSelector(filter: filter),
          // ── Conteúdo ──────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: AppSpacing.pagePadding,
              children: const [
                _SummarySection(),
                SizedBox(height: AppSpacing.xl),
                _EvolutionSection(),
                SizedBox(height: AppSpacing.xl),
                _CategorySection(),
                SizedBox(height: AppSpacing.xl),
                _BalanceSection(),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seletor de período ────────────────────────────────────────────────────────

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.filter});
  final ReportFilterState filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: ReportPeriod.values.map((period) {
          final selected = filter.period == period;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(period.label),
              selected: selected,
              onSelected: (_) {
                if (period == ReportPeriod.custom) {
                  _pickCustomRange(context, ref);
                } else {
                  ref.read(reportFilterProvider.notifier).setPeriod(period);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month),
        end: now,
      ),
    );
    if (range != null) {
      ref.read(reportFilterProvider.notifier).setCustomRange(
            range.start,
            DateTimeRange(start: range.start, end: range.end).end,
          );
    }
  }
}

// ── Resumo consolidado ────────────────────────────────────────────────────────

class _SummarySection extends ConsumerWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);

    return _SectionCard(
      title: 'Resumo do período',
      icon: Icons.summarize_outlined,
      child: summaryAsync.when(
        loading: () => _shimmerSummary(),
        error: (e, _) => _ErrorText(message: e.toString()),
        data: (s) => _SummaryContent(summary: s),
      ),
    );
  }

  Widget _shimmerSummary() => Column(
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _ShimmerBox(height: 20, width: double.infinity),
          ),
        ),
      );
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});
  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Receitas',
                value: CurrencyFormatter.format(summary.totalIncome),
                color: AppColors.income,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _KpiTile(
                label: 'Despesas',
                value: CurrencyFormatter.format(summary.totalExpense),
                color: AppColors.expense,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Saldo',
                value: CurrencyFormatter.format(summary.balance),
                color: summary.balance >= 0
                    ? AppColors.income
                    : AppColors.expense,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _KpiTile(
                label: 'Transações',
                value: '${summary.transactionCount}',
                color: AppColors.info,
                icon: Icons.receipt_long_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Gasto médio/dia',
                value: CurrencyFormatter.format(summary.avgExpensePerDay),
                color: AppColors.warning,
                icon: Icons.today_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _KpiTile(
                label: 'Maior despesa',
                value: CurrencyFormatter.format(summary.biggestExpense),
                color: AppColors.danger,
                icon: Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Evolução mensal ───────────────────────────────────────────────────────────

class _EvolutionSection extends ConsumerWidget {
  const _EvolutionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evolutionAsync = ref.watch(reportEvolutionProvider);

    return _SectionCard(
      title: 'Evolução mensal',
      icon: Icons.bar_chart_rounded,
      child: evolutionAsync.when(
        loading: () => const _ShimmerBox(height: 200, width: double.infinity),
        error: (e, _) => _ErrorText(message: e.toString()),
        data: (evolution) => ReportBarChart(data: evolution),
      ),
    );
  }
}

// ── Despesas por categoria ────────────────────────────────────────────────────

class _CategorySection extends ConsumerWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byCategoryAsync = ref.watch(reportByCategoryProvider);

    return _SectionCard(
      title: 'Despesas por categoria',
      icon: Icons.donut_large_rounded,
      child: byCategoryAsync.when(
        loading: () => const _ShimmerBox(height: 200, width: double.infinity),
        error: (e, _) => _ErrorText(message: e.toString()),
        data: (cats) => Column(
          children: [
            // Pizza
            SizedBox(
              height: 200,
              child: ReportPieChart(data: cats),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Ranking
            CategoryRankList(data: cats),
          ],
        ),
      ),
    );
  }
}

// ── Saldo acumulado ───────────────────────────────────────────────────────────

class _BalanceSection extends ConsumerWidget {
  const _BalanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evolutionAsync = ref.watch(reportEvolutionProvider);

    return _SectionCard(
      title: 'Saldo acumulado',
      icon: Icons.show_chart_rounded,
      child: evolutionAsync.when(
        loading: () => const _ShimmerBox(height: 200, width: double.infinity),
        error: (e, _) => _ErrorText(message: e.toString()),
        data: (evolution) => ReportLineChart(data: evolution),
      ),
    );
  }
}

// ── Componentes utilitários ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 18,
                    color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.inputRadius,
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
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Erro: $message',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.height, required this.width});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: AppRadius.inputRadius,
        ),
      ),
    );
  }
}
