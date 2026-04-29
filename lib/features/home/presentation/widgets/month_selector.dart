// lib/features/home/presentation/widgets/month_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/dashboard_provider.dart';

/// Seletor de mês compacto para o dashboard.
/// Navega entre meses com setas e bloqueia o avanço para meses futuros.
class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(selectedMonthNotifierProvider.notifier);
    final selectedMonth = ref.watch(selectedMonthNotifierProvider);
    final isCurrentMonth = notifier.isCurrentMonth;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowButton(
          icon: Icons.chevron_left,
          onTap: () => notifier.selectPrevious(),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: isCurrentMonth ? null : () => notifier.resetToCurrentMonth(),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isCurrentMonth
                  ? Theme.of(context).colorScheme.onSurface
                  : AppColors.seed,
            ),
            child: Text(
              _capitalizeFirst(DateFormatter.monthYear(selectedMonth)),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ArrowButton(
          icon: Icons.chevron_right,
          onTap: isCurrentMonth ? null : () => notifier.selectNext(),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
