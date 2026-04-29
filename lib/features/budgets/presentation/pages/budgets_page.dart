// lib/features/budgets/presentation/pages/budgets_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';
import '../widgets/budget_form_sheet.dart';
import '../widgets/budget_progress_card.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        actions: [
          // Selector de mês
          _MonthSelector(month: selectedMonth),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBudgetForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo orçamento'),
      ),
      body: _BudgetsBody(month: selectedMonth),
    );
  }
}

// ── Seletor de mês compacto ───────────────────────────────────────────────────

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.month});
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(selectedMonthNotifierProvider.notifier);
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: notifier.selectPrevious,
          tooltip: 'Mês anterior',
        ),
        GestureDetector(
          onTap: notifier.resetToCurrentMonth,
          child: Text(
            '${months[month.month - 1]} ${month.year}',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed:
              ref.watch(selectedMonthNotifierProvider.notifier).isCurrentMonth
                  ? null
                  : notifier.selectNext,
          tooltip: 'Próximo mês',
        ),
      ],
    );
  }
}

// ── Corpo principal ───────────────────────────────────────────────────────────

class _BudgetsBody extends ConsumerWidget {
  const _BudgetsBody({required this.month});
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(budgetProgressListProvider(month));

    return progressAsync.when(
      loading: () => const _LoadingShimmer(),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (list) {
        if (list.isEmpty) {
          return const _EmptyState();
        }
        return _ProgressList(items: list, month: month);
      },
    );
  }
}

// ── Lista de progresso ────────────────────────────────────────────────────────

class _ProgressList extends ConsumerWidget {
  const _ProgressList({required this.items, required this.month});
  final List<BudgetProgress> items;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync =
        ref.watch(watchCategoriesProvider(CategoryType.expense));

    return categoriesAsync.when(
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        final catMap = {for (final c in categories) c.id: c};

        // Separar alertas dos normais
        final alerts = items
            .where((p) => p.isOverBudget || p.isAlert)
            .toList();
        final normal = items
            .where((p) => !p.isOverBudget && !p.isAlert)
            .toList();

        return CustomScrollView(
          slivers: [
            // ── Resumo do mês ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _MonthlySummary(items: items, month: month),
            ),

            // ── Alertas ───────────────────────────────────────────────
            if (alerts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Atenção (${alerts.length})',
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) => AppSpacing.vSm,
                  itemBuilder: (context, i) => _BudgetTile(
                    progress: alerts[i],
                    category: catMap[alerts[i].budget.categoryId],
                    ref: ref,
                  ),
                ),
              ),
            ],

            // ── Normais ───────────────────────────────────────────────
            if (normal.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Em dia (${normal.length})',
                    style:
                        Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.income,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: normal.length,
                  separatorBuilder: (_, __) => AppSpacing.vSm,
                  itemBuilder: (context, i) => _BudgetTile(
                    progress: normal[i],
                    category: catMap[normal[i].budget.categoryId],
                    ref: ref,
                  ),
                ),
              ),
            ],

            // Espaço para o FAB
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 88),
            ),
          ],
        );
      },
    );
  }
}

// ── Tile individual ───────────────────────────────────────────────────────────

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.progress,
    required this.category,
    required this.ref,
  });

  final BudgetProgress progress;
  final Category? category;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final cat = category;
    return BudgetProgressCard(
      progress: progress,
      categoryName: cat?.name ?? 'Sem categoria',
      categoryColor: cat?.color ?? AppColors.categoryOther,
      categoryIcon: cat?.icon ?? Icons.category_rounded,
      onLongPress: () => _showOptions(context),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _BudgetOptionsSheet(
        progress: progress,
        category: category,
        refContext: context,
        widgetRef: ref,
      ),
    );
  }
}

// ── Sheet de opções (editar / excluir) ────────────────────────────────────────

class _BudgetOptionsSheet extends StatelessWidget {
  const _BudgetOptionsSheet({
    required this.progress,
    required this.category,
    required this.refContext,
    required this.widgetRef,
  });

  final BudgetProgress progress;
  final Category? category;
  final BuildContext refContext;
  final WidgetRef widgetRef;

  @override
  Widget build(BuildContext context) {
    final cat = category;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: cat != null
                ? CircleAvatar(
                    backgroundColor: cat.color.withValues(alpha: 0.15),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  )
                : const CircleAvatar(child: Icon(Icons.category_rounded)),
            title: Text(
              cat?.name ?? 'Sem categoria',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${CurrencyFormatter.format(progress.budget.amount)} / ${progress.budget.period.label}',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Editar orçamento'),
            onTap: () async {
              Navigator.of(context).pop();
              await showBudgetForm(
                refContext,
                widgetRef,
                budget: progress.budget,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_rounded,
                color: Theme.of(context).colorScheme.error),
            title: Text(
              'Excluir orçamento',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _confirmDelete(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: refContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir orçamento'),
        content: Text(
          'Deseja excluir o orçamento de "${category?.name ?? 'Sem categoria'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widgetRef
                  .read(budgetNotifierProvider.notifier)
                  .deleteBudget(progress.budget.id);
              if (refContext.mounted) {
                ScaffoldMessenger.of(refContext).showSnackBar(
                  const SnackBar(
                      content: Text('Orçamento excluído.')),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// ── Resumo mensal ─────────────────────────────────────────────────────────────

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.items, required this.month});
  final List<BudgetProgress> items;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];

    final totalBudget = items.fold(0, (s, p) => s + p.budget.amount);
    final totalSpent = items.fold(0, (s, p) => s + p.spentAmount);
    final overCount =
        items.where((p) => p.isOverBudget).length;
    final alertCount =
        items.where((p) => p.isAlert && !p.isOverBudget).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
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
            '${months[month.month - 1]} ${month.year}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Total orçado',
                  value: CurrencyFormatter.format(totalBudget),
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Total gasto',
                  value: CurrencyFormatter.format(totalSpent),
                  color: totalSpent > totalBudget
                      ? AppColors.danger
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          if (overCount > 0 || alertCount > 0) ...[
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (overCount > 0)
                  _Badge(
                    label:
                        '$overCount ${overCount == 1 ? 'estourado' : 'estourados'}',
                    color: AppColors.danger,
                  ),
                if (alertCount > 0)
                  _Badge(
                    label:
                        '$alertCount em alerta',
                    color: AppColors.warning,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Estado vazio ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 80,
              color: theme.colorScheme.outlineVariant,
            ),
            AppSpacing.vLg,
            Text(
              'Nenhum orçamento cadastrado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSm,
            Text(
              'Crie orçamentos por categoria para controlar seus gastos mensais.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estado de erro ────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error),
            AppSpacing.vMd,
            const Text('Erro ao carregar orçamentos.'),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer de carregamento ───────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        padding: AppSpacing.pagePadding,
        itemCount: 4,
        separatorBuilder: (_, __) => AppSpacing.vSm,
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.cardRadius,
          ),
        ),
      ),
    );
  }
}

