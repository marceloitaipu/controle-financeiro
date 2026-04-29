// lib/shared/widgets/info_card.dart

import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Card de métrica com valor, label e indicador de tendência opcional.
///
/// Uso:
/// ```dart
/// InfoCard(
///   label: 'Saldo total',
///   value: 'R$ 4.250,00',
///   trend: InfoCardTrend.up,
///   trendLabel: '+12%',
/// )
/// ```
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendLabel,
    this.isLoading = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final InfoCardTrend? trend;
  final String? trendLabel;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardRadius,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header: ícone + label ──────────────────────────────────────
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: iconColor ?? colorScheme.onSurfaceVariant,
                  ),
                  AppSpacing.hXs,
                ],
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // ── Valor ─────────────────────────────────────────────────────
            if (isLoading)
              Container(
                height: 22,
                width: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            // ── Tendência ─────────────────────────────────────────────────
            if (trend != null && trendLabel != null) ...[
              AppSpacing.vXs,
              _TrendBadge(trend: trend!, label: trendLabel!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Direção da tendência para [InfoCard].
enum InfoCardTrend { up, down, neutral }

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend, required this.label});

  final InfoCardTrend trend;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      InfoCardTrend.up => (Icons.trending_up_rounded, const Color(0xFF1B5E20)),
      InfoCardTrend.down => (Icons.trending_down_rounded, const Color(0xFFB71C1C)),
      InfoCardTrend.neutral => (Icons.trending_flat_rounded, Theme.of(context).colorScheme.onSurfaceVariant),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
