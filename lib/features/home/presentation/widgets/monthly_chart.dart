// lib/features/home/presentation/widgets/monthly_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Gráfico de barras agrupadas mostrando receitas e despesas dos últimos 6 meses.
class MonthlyBarChart extends ConsumerWidget {
  const MonthlyBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryListProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.sm,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _Legend(color: AppColors.income, label: 'Receitas'),
              SizedBox(width: AppSpacing.lg),
              _Legend(color: AppColors.expense, label: 'Despesas'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            child: summaryAsync.when(
              loading: () => _buildShimmer(),
              error: (_, __) => const Center(
                child: Text('Erro ao carregar gráfico'),
              ),
              data: (summaries) => _buildChart(context, summaries),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: AppRadius.cardRadius,
        ),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<MonthlySummary> summaries,
  ) {
    if (summaries.isEmpty) {
      return const Center(child: Text('Sem dados para exibir'));
    }

    final maxY = summaries.fold<int>(
          0,
          (max, s) => s.income > max ? s.income : max,
        ) >
        summaries.fold<int>(
          0,
          (max, s) => s.expense > max ? s.expense : max,
        )
        ? summaries.fold<int>(0, (max, s) => s.income > max ? s.income : max)
        : summaries.fold<int>(
            0, (max, s) => s.expense > max ? s.expense : max);

    final chartMaxY = maxY == 0 ? 100.0 : (maxY * 1.2).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final summary = summaries[group.x];
              final isIncome = rodIndex == 0;
              final value = isIncome ? summary.income : summary.expense;
              return BarTooltipItem(
                '${isIncome ? '↑' : '↓'} ${CurrencyFormatter.formatCompact(value)}',
                TextStyle(
                  color: isIncome ? AppColors.income : AppColors.expense,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= summaries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormatter.shortMonthYear(summaries[index].month),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMaxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(summaries.length, (index) {
          final s = summaries[index];
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: s.income.toDouble(),
                color: AppColors.income,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: s.expense.toDouble(),
                color: AppColors.expense,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
