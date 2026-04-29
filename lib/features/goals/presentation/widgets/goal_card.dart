// lib/features/goals/presentation/widgets/goal_card.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';

/// Card compacto para exibição de uma meta financeira na listagem.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  final Goal goal;
  final VoidCallback? onTap;

  Color get _color {
    final hex = goal.colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get _icon =>
      IconData(goal.iconCodePoint, fontFamily: goal.iconFontFamily);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color;
    final days = daysRemaining(goal);
    final isOverdue = days == 0 && !goal.isCompleted;

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
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              // ── Indicador circular ────────────────────────────────────
              _CircularProgress(
                progress: goal.progress,
                color: color,
                icon: _icon,
                size: 56,
              ),
              AppSpacing.hMd,
              // ── Informações ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusChip(goal: goal, isOverdue: isOverdue),
                      ],
                    ),
                    AppSpacing.vXs,
                    // Barra de progresso linear
                    ClipRRect(
                      borderRadius: AppRadius.fullRadius,
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 5,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    AppSpacing.vXs,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Atual / meta
                        Text(
                          '${CurrencyFormatter.formatCompact(goal.currentAmount)} de ${CurrencyFormatter.formatCompact(goal.targetAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        // Prazo
                        if (goal.status == GoalStatus.active)
                          Text(
                            isOverdue
                                ? 'Prazo vencido'
                                : '$days ${days == 1 ? 'dia' : 'dias'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOverdue
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Indicador circular ────────────────────────────────────────────────────────

class _CircularProgress extends StatelessWidget {
  const _CircularProgress({
    required this.progress,
    required this.color,
    required this.icon,
    required this.size,
  });

  final double progress;
  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: progress,
              color: color,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              strokeWidth: 4,
            ),
          ),
          Container(
            width: size - 14,
            height: size - 14,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: size * 0.38),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    const fullAngle = 2 * math.pi;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullAngle,
      false,
      bgPaint,
    );

    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullAngle * progress.clamp(0.0, 1.0),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Chip de status ────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.goal, required this.isOverdue});
  final Goal goal;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    if (goal.status == GoalStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
          borderRadius: AppRadius.fullRadius,
        ),
        child: const Text(
          '100%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      );
    }
    if (goal.status == GoalStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: AppRadius.fullRadius,
        ),
        child: Text(
          'Cancelada',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    if (isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: AppRadius.fullRadius,
        ),
        child: Text(
          'Atrasada',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      );
    }
    final pct = (goal.progress * 100).round();
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
