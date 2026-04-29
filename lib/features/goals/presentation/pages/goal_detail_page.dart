// lib/features/goals/presentation/pages/goal_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';

class GoalDetailPage extends ConsumerWidget {
  const GoalDetailPage({
    super.key,
    required this.goalId,
    this.initialGoal,
  });

  final String goalId;
  final Goal? initialGoal;

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Ouve a lista completa e filtra pelo id para receber atualizações em tempo real
    final goalsAsync = ref.watch(watchGoalsProvider(null));

    return goalsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Meta')),
        body: Center(child: Text('Erro: $e')),
      ),
      data: (goals) {
        final goal = goals.cast<Goal?>().firstWhere(
              (g) => g?.id == goalId,
              orElse: () => initialGoal,
            );

        if (goal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Meta')),
            body: const Center(child: Text('Meta não encontrada.')),
          );
        }

        final color = _parseColor(goal.colorHex);
        final days = daysRemaining(goal);
        final daily = dailyAmountNeeded(goal);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppSpacing.vXl,
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              IconData(goal.iconCodePoint,
                                  fontFamily: goal.iconFontFamily),
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          AppSpacing.vSm,
                          Text(
                            goal.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (goal.status == GoalStatus.active) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: Colors.white,
                      onPressed: () => _openEdit(context, ref, goal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.white,
                      onPressed: () => _confirmDelete(context, ref, goal),
                    ),
                  ],
                ],
              ),

              // ── Conteúdo ────────────────────────────────────────────────
              SliverPadding(
                padding: AppSpacing.pagePadding,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Progresso
                    _ProgressCard(goal: goal, color: color),
                    AppSpacing.vMd,

                    // Resumo
                    _SummaryRow(
                      label: 'Valor atual',
                      value: CurrencyFormatter.format(goal.currentAmount),
                      color: color,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Valor alvo',
                      value: CurrencyFormatter.format(goal.targetAmount),
                      color: theme.colorScheme.onSurface,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Faltam',
                      value: CurrencyFormatter.format(goal.remainingAmount),
                      color: theme.colorScheme.onSurface,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Prazo',
                      value: _formatDate(goal.deadline),
                      color: days == 0 && goal.status == GoalStatus.active
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                    if (goal.status == GoalStatus.active && daily > 0) ...[
                      const Divider(height: 24),
                      _SummaryRow(
                        label: 'Depósito diário sugerido',
                        value: CurrencyFormatter.format(daily),
                        color: AppColors.warning,
                      ),
                    ],
                    AppSpacing.vLg,
                  ]),
                ),
              ),
            ],
          ),
          // FAB para depositar
          floatingActionButton:
              goal.status == GoalStatus.active && !goal.isCompleted
                  ? FloatingActionButton.extended(
                      onPressed: () => _showDepositSheet(context, ref, goal),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Depositar'),
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    )
                  : null,
        );
      },
    );
  }

  // ── Ações ─────────────────────────────────────────────────────────────────

  Future<void> _openEdit(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    await context.pushNamed(
      AppRoutes.goalNewName,
      extra: goal,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar meta'),
        content: Text(
            'Deseja cancelar a meta "${goal.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Cancelar meta'),
          ),
        ],
      ),
    );
    if ((ok ?? false) && context.mounted) {
      final deleted = await ref
          .read(goalNotifierProvider.notifier)
          .deleteGoal(goal.id);
      if (deleted && context.mounted) context.pop();
    }
  }

  void _showDepositSheet(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetRadius,
      ),
      builder: (ctx) => _DepositSheet(goal: goal, ref: ref),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Card de progresso ─────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.goal, required this.color});
  final Goal goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (goal.progress * 100).clamp(0.0, 100.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            ClipRRect(
              borderRadius: AppRadius.fullRadius,
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (goal.status == GoalStatus.completed) ...[
              AppSpacing.vMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Color(0xFFFFA000), size: 20),
                  AppSpacing.hXs,
                  Text(
                    'Meta atingida!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Linha de resumo ───────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Sheet de depósito ─────────────────────────────────────────────────────────

class _DepositSheet extends ConsumerStatefulWidget {
  const _DepositSheet({required this.goal, required this.ref});
  final Goal goal;
  final WidgetRef ref;

  @override
  ConsumerState<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<_DepositSheet> {
  final _ctrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final amount = CurrencyInputFormatter.extractValue(_ctrl.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor maior que zero.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final cents = (amount * 100).round();
    final ok = await ref
        .read(goalNotifierProvider.notifier)
        .addProgress(widget.goal.id, cents);
    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao depositar. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.remainingAmount;
    final daily = dailyAmountNeeded(widget.goal);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
                borderRadius: AppRadius.fullRadius,
              ),
            ),
          ),
          AppSpacing.vMd,
          Text(
            'Depositar na meta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.vXs,
          Text(
            'Faltam ${CurrencyFormatter.format(remaining)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          AppSpacing.vMd,

          // Atalhos de valor
          if (daily > 0)
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                _QuickChip(
                  label: CurrencyFormatter.formatCompact(daily),
                  subtitle: 'diário',
                  onTap: () => _ctrl.text =
                      (daily / 100).toStringAsFixed(2).replaceAll('.', ','),
                ),
                _QuickChip(
                  label: CurrencyFormatter.formatCompact(daily * 7),
                  subtitle: 'semanal',
                  onTap: () => _ctrl.text =
                      ((daily * 7) / 100).toStringAsFixed(2).replaceAll('.', ','),
                ),
              ],
            ),
          AppSpacing.vMd,

          // Campo de valor
          AppTextField(
            label: 'Valor do depósito',
            prefixIcon: Icons.attach_money_rounded,
            controller: _ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [CurrencyInputFormatter()],
            autofocus: true,
          ),
          AppSpacing.vMd,

          // Botão confirmar
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _confirm,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Confirmar depósito'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
      onPressed: onTap,
    );
  }
}
