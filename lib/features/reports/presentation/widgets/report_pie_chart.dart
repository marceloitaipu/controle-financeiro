// lib/features/reports/presentation/widgets/report_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/report_providers.dart';

/// Gráfico de pizza com as despesas por categoria.
class ReportPieChart extends StatefulWidget {
  const ReportPieChart({super.key, required this.data});
  final List<CategoryExpense> data;

  @override
  State<ReportPieChart> createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.data.isEmpty) {
      return const Center(child: Text('Sem despesas por categoria.'));
    }

    // Máximo 8 fatias: agrupa o resto em "Outros"
    final items = widget.data.length > 8
        ? [
            ...widget.data.take(7),
            CategoryExpense(
              categoryId: '_outros',
              categoryName: 'Outros',
              colorHex: '#78909C',
              iconCodePoint: 0xe532,
              iconFontFamily: 'MaterialIcons',
              total: widget.data
                  .skip(7)
                  .fold(0, (s, e) => s + e.total),
              percentage: widget.data
                  .skip(7)
                  .fold(0.0, (s, e) => s + e.percentage),
              transactionCount: widget.data
                  .skip(7)
                  .fold(0, (s, e) => s + e.transactionCount),
            ),
          ]
        : widget.data;

    return Row(
      children: [
        // ── Pizza ──────────────────────────────────────────────────────────
        Expanded(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: List.generate(items.length, (i) {
                  final item = items[i];
                  final touched = i == _touchedIndex;
                  final color = _parseColor(item.colorHex);
                  return PieChartSectionData(
                    value: item.total.toDouble(),
                    color: color,
                    radius: touched ? 72 : 58,
                    title: touched
                        ? '${(item.percentage * 100).toStringAsFixed(1)}%'
                        : '',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }),
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              ),
            ),
          ),
        ),
        // ── Legenda ────────────────────────────────────────────────────────
        Expanded(
          flex: 7,
          child: Padding(
            padding:
                const EdgeInsets.only(left: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final color = _parseColor(item.colorHex);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: AppRadius.fullRadius,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.categoryName,
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatCompact(item.total),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
