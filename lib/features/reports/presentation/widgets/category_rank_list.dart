// lib/features/reports/presentation/widgets/category_rank_list.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/report_providers.dart';

/// Lista ranqueada de despesas por categoria com barra de progresso.
class CategoryRankList extends StatelessWidget {
  const CategoryRankList({super.key, required this.data});
  final List<CategoryExpense> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: Text('Sem despesas no período.')),
      );
    }

    return Column(
      children: List.generate(data.length > 10 ? 10 : data.length, (i) {
        final item = data[i];
        final color = _parseColor(item.colorHex);
        return _CategoryRow(
          rank: i + 1,
          item: item,
          color: color,
          isLast: i == (data.length > 10 ? 9 : data.length - 1),
        );
      }),
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.rank,
    required this.item,
    required this.color,
    required this.isLast,
  });

  final int rank;
  final CategoryExpense item;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        children: [
          // Ícone
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.inputRadius,
            ),
            child: Icon(
              IconData(
                item.iconCodePoint,
                fontFamily: item.iconFontFamily,
              ),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Nome + barra
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.categoryName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.total),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadius.fullRadius,
                        child: LinearProgressIndicator(
                          value: item.percentage,
                          minHeight: 5,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${(item.percentage * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
