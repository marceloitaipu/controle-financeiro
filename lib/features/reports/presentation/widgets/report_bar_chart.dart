// lib/features/reports/presentation/widgets/report_bar_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/report_providers.dart';

/// Gráfico de barras agrupadas (receita × despesa) para a evolução mensal.
class ReportBarChart extends StatelessWidget {
  const ReportBarChart({super.key, required this.data});

  final List<MonthlyEvolution> data;

  static const _kBarWidth = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return const Center(child: Text('Sem dados para o período.'));
    }

    final maxVal = data.fold<int>(
      0,
      (m, e) => [m, e.income, e.expense].reduce((a, b) => a > b ? a : b),
    );
    final maxY = (maxVal / 100) * 1.2; // 20% de margem

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legenda
        const Row(
          children: [
            _Legend(color: AppColors.income, label: 'Receitas'),
            SizedBox(width: AppSpacing.lg),
            _Legend(color: AppColors.expense, label: 'Despesas'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY == 0 ? 100 : maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY == 0 ? 25 : maxY / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final month = data[index].month;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _shortMonth(month.month),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(data.length, (i) {
                final e = data[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: e.income / 100,
                      color: AppColors.income,
                      width: _kBarWidth,
                      borderRadius: AppRadius.chipRadius,
                    ),
                    BarChartRodData(
                      toY: e.expense / 100,
                      color: AppColors.expense,
                      width: _kBarWidth,
                      borderRadius: AppRadius.chipRadius,
                    ),
                  ],
                  barsSpace: 3,
                );
              }),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      theme.colorScheme.surfaceContainerHighest,
                  getTooltipItem: (group, _, rod, rodIndex) {
                    final label = rodIndex == 0 ? 'Receita' : 'Despesa';
                    final cents = (rod.toY * 100).round();
                    return BarTooltipItem(
                      '$label\n${CurrencyFormatter.formatCompact(cents)}',
                      TextStyle(
                        color: rod.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _shortMonth(int m) => const [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
      ][m - 1];
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
