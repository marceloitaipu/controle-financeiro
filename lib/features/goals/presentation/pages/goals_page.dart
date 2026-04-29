// lib/features/goals/presentation/pages/goals_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_card.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(watchGoalsProvider(GoalStatus.active));
    final completedAsync =
        ref.watch(watchGoalsProvider(GoalStatus.completed));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Metas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ativas'),
              Tab(text: 'Concluídas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GoalsList(
              goalsAsync: activeAsync,
              emptyMessage: 'Nenhuma meta ativa.\nToque em + para criar.',
              emptyIcon: Icons.flag_outlined,
            ),
            _GoalsList(
              goalsAsync: completedAsync,
              emptyMessage: 'Nenhuma meta concluída ainda.',
              emptyIcon: Icons.emoji_events_outlined,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed(AppRoutes.goalNewName),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}

// ── Lista de metas ────────────────────────────────────────────────────────────

class _GoalsList extends StatelessWidget {
  const _GoalsList({
    required this.goalsAsync,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  final AsyncValue<List<Goal>> goalsAsync;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    return goalsAsync.when(
      loading: () => _Shimmer(),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (goals) {
        if (goals.isEmpty) {
          return _EmptyState(message: emptyMessage, icon: emptyIcon);
        }
        return _GoalsContent(goals: goals);
      },
    );
  }
}

// ── Conteúdo principal ────────────────────────────────────────────────────────

class _GoalsContent extends StatelessWidget {
  const _GoalsContent({required this.goals});
  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    final totalTarget = goals.fold<int>(0, (s, g) => s + g.targetAmount);
    final totalCurrent = goals.fold<int>(0, (s, g) => s + g.currentAmount);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        // Sumário
        if (goals.isNotEmpty) ...[
          _SummaryCard(
            total: goals.length,
            totalTarget: totalTarget,
            totalCurrent: totalCurrent,
          ),
          AppSpacing.vMd,
        ],
        ...goals.map(
          (g) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GoalCard(
              goal: g,
              onTap: () => context.pushNamed(
                AppRoutes.goalDetailName,
                pathParameters: {'goalId': g.id},
                extra: g,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Card de sumário ───────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.totalTarget,
    required this.totalCurrent,
  });

  final int total;
  final int totalTarget;
  final int totalCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress =
        totalTarget == 0 ? 0.0 : (totalCurrent / totalTarget).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$total ${total == 1 ? 'meta' : 'metas'}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            AppSpacing.vXs,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.formatCompact(totalCurrent),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'de ${CurrencyFormatter.formatCompact(totalTarget)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            ClipRRect(
              borderRadius: AppRadius.fullRadius,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.onPrimaryContainer
                    .withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estados ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.icon});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 64, color: theme.colorScheme.outlineVariant),
            AppSpacing.vMd,
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Erro: $message',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;
    return ListView(
      padding: AppSpacing.pagePadding,
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: base,
                borderRadius: AppRadius.cardRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

