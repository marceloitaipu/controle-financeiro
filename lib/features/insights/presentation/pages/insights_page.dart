// lib/features/insights/presentation/pages/insights_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../providers/insight_providers.dart';
import '../widgets/insight_card.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(currentMonthInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        centerTitle: false,
      ),
      body: insightsAsync.when(
        loading: () => _ShimmerLoading(),
        error: (_, __) => AppErrorWidget(
          message: 'Não foi possível carregar os insights.',
          onRetry: () => ref.invalidate(currentMonthInsightsProvider),
        ),
        data: (insights) => _InsightsContent(insights: insights),
      ),
    );
  }
}

// ── Conteúdo principal ─────────────────────────────────────────────────────

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({required this.insights});

  final List<Insight> insights;

  @override
  Widget build(BuildContext context) {
    final severities = InsightSeverity.values.reversed.toList();

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const _MonthSummaryCard(),
        const SizedBox(height: AppSpacing.xl),
        if (insights.isEmpty)
          _EmptyState()
        else
          for (final severity in severities) ...[
            ..._buildSection(context, severity),
          ],
        const SizedBox(height: AppSpacing.xl3),
      ],
    );
  }

  List<Widget> _buildSection(BuildContext context, InsightSeverity severity) {
    final items =
        insights.where((i) => i.severity == severity).toList();
    if (items.isEmpty) return const [];

    return [
      _SectionHeader(severity: severity),
      const SizedBox(height: AppSpacing.sm),
      for (final insight in items) InsightCard(insight: insight),
      const SizedBox(height: AppSpacing.lg),
    ];
  }
}

// ── Resumo do mês ──────────────────────────────────────────────────────────

class _MonthSummaryCard extends ConsumerWidget {
  const _MonthSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryListProvider);
    final theme = Theme.of(context);

    return summaryAsync.when(
      loading: () => _shimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
      data: (summaries) {
        if (summaries.isEmpty) return const SizedBox.shrink();
        final current = summaries.last;
        final balance = current.result;
        final monthLabel = DateFormat('MMMM yyyy', 'pt_BR').format(current.month);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.cardRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _capitalize(monthLabel),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer
                      .withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Resumo do mês',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Receitas',
                      value: current.income,
                      color: AppColors.income,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Despesas',
                      value: current.expense,
                      color: AppColors.expense,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Saldo',
                      value: balance,
                      color: balance >= 0 ? AppColors.income : AppColors.expense,
                      icon: balance >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _shimmerCard() => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 140,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.cardRadius,
          ),
        ),
      );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          CurrencyFormatter.formatCompact(value.abs()),
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Cabeçalho de seção ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.severity});

  final InsightSeverity severity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = severity.color;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          severity.sectionLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Estado vazio ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 36,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Suas finanças estão em dia!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Nenhum alerta ou sugestão por enquanto.\n'
            'Continue registrando suas transações.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer de carregamento ────────────────────────────────────────────────

class _ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _shimmerBox(140),
          const SizedBox(height: AppSpacing.xl),
          _shimmerBox(80),
          const SizedBox(height: AppSpacing.md),
          _shimmerBox(80),
          const SizedBox(height: AppSpacing.xl),
          _shimmerBox(90),
          const SizedBox(height: AppSpacing.md),
          _shimmerBox(70),
          const SizedBox(height: AppSpacing.md),
          _shimmerBox(90),
        ],
      ),
    );
  }

  Widget _shimmerBox(double height) => Container(
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardRadius,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      );
}

