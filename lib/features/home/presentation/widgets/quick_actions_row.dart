// lib/features/home/presentation/widgets/quick_actions_row.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Linha de atalhos rápidos no dashboard.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(
            icon: Icons.add_circle_outline_rounded,
            label: 'Receita',
            color: AppColors.income,
            onTap: () => context.pushNamed(
              AppRoutes.transactionNewName,
              queryParameters: {'type': 'income'},
            ),
          ),
          _QuickAction(
            icon: Icons.remove_circle_outline_rounded,
            label: 'Despesa',
            color: AppColors.expense,
            onTap: () => context.pushNamed(
              AppRoutes.transactionNewName,
              queryParameters: {'type': 'expense'},
            ),
          ),
          _QuickAction(
            icon: Icons.swap_horiz_rounded,
            label: 'Transferir',
            color: AppColors.transfer,
            onTap: () => context.pushNamed(
              AppRoutes.transactionNewName,
              queryParameters: {'type': 'transfer'},
            ),
          ),
          _QuickAction(
            icon: Icons.account_balance_outlined,
            label: 'Contas',
            color: const Color(0xFF6A1B9A),
            onTap: () => context.push(AppRoutes.accounts),
          ),
          _QuickAction(
            icon: Icons.flag_outlined,
            label: 'Metas',
            color: const Color(0xFF2E7D32),
            onTap: () => context.push(AppRoutes.goals),
          ),
          _QuickAction(
            icon: Icons.pie_chart_outline_rounded,
            label: 'Orçamentos',
            color: const Color(0xFFE65100),
            onTap: () => context.push(AppRoutes.budgets),
          ),
          _QuickAction(
            icon: Icons.bar_chart_rounded,
            label: 'Relatórios',
            color: const Color(0xFF00838F),
            onTap: () => context.push(AppRoutes.reports),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
