// lib/features/insights/presentation/providers/insight_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

part 'insight_providers.g.dart';

// ── Enums e modelo ─────────────────────────────────────────────────────────

enum InsightType {
  budgetOver,
  budgetAlert,
  goalExpiringSoon,
  goalAtRisk,
  negativeBalance,
  noIncome,
  spendingIncreased,
  spendingDecreased,
  goodSavingsRate,
  topCategory,
}

/// Severidade de um insight — define cor e ordem de exibição.
/// Ordenação descendente por índice: danger(3) > warning(2) > info(1) > success(0).
enum InsightSeverity { success, info, warning, danger }

extension InsightSeverityX on InsightSeverity {
  Color get color => switch (this) {
        InsightSeverity.danger => AppColors.danger,
        InsightSeverity.warning => AppColors.warning,
        InsightSeverity.info => AppColors.info,
        InsightSeverity.success => AppColors.success,
      };

  String get sectionLabel => switch (this) {
        InsightSeverity.danger => 'Atenção',
        InsightSeverity.warning => 'Avisos',
        InsightSeverity.info => 'Informações',
        InsightSeverity.success => 'Conquistas',
      };
}

/// Modelo imutável de um insight financeiro.
final class Insight {
  const Insight({
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.actionRoute,
  });

  final InsightType type;
  final InsightSeverity severity;
  final String title;
  final String description;
  final IconData icon;

  /// Texto do botão de ação (opcional).
  final String? actionLabel;

  /// Rota para navegar ao acionar (opcional).
  final String? actionRoute;
}

// ── Provider auxiliar ──────────────────────────────────────────────────────

/// Stream de transações do mês atual, usadas para apurar a principal categoria.
@riverpod
Stream<List<Transaction>> currentMonthTransactions(Ref ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return ref.watch(transactionRepositoryProvider).watchTransactions(
    filter: TransactionFilter(
      startDate: start,
      endDate: end,
      limit: 300,
    ),
  );
}

// ── Provider principal ─────────────────────────────────────────────────────

/// Gera a lista de insights financeiros para o usuário no mês corrente.
///
/// Agrega dados de orçamentos, metas, resumo mensal e transações para
/// produzir análises automáticas, ordenadas por severidade decrescente.
@riverpod
Future<List<Insight>> currentMonthInsights(Ref ref) async {
  final now = DateTime.now();
  final insights = <Insight>[];

  // ── Resumo mensal (últimos 6 meses via monthlySummaryListProvider) ──────
  final summaries = await ref.watch(monthlySummaryListProvider.future);
  final current = summaries.isNotEmpty ? summaries.last : null;
  final lastMonth =
      summaries.length >= 2 ? summaries[summaries.length - 2] : null;
  final income = current?.income ?? 0;
  final expense = current?.expense ?? 0;

  // ── Categorias (para resolução de nomes nos insights de orçamento) ──────
  final categories = ref
      .watch(watchCategoriesProvider(null))
      .maybeWhen(data: (l) => l, orElse: () => <Category>[]);

  // ── Insights de orçamento ────────────────────────────────────────────────
  final budgetProgress =
      await ref.watch(budgetProgressListProvider(now).future);
  for (final bp in budgetProgress) {
    final cat = categories.cast<Category?>().firstWhere(
          (c) => c?.id == bp.budget.categoryId,
          orElse: () => null,
        );
    final catName = cat?.name ?? 'Categoria';

    if (bp.isOverBudget) {
      insights.add(Insight(
        type: InsightType.budgetOver,
        severity: InsightSeverity.danger,
        title: 'Orçamento estourado',
        description:
            'O orçamento de "$catName" foi ultrapassado em '
            '${CurrencyFormatter.format(bp.spentAmount - bp.budget.amount)}.',
        icon: Icons.money_off_rounded,
        actionLabel: 'Ver orçamentos',
        actionRoute: AppRoutes.budgets,
      ));
    } else if (bp.isAlert) {
      insights.add(Insight(
        type: InsightType.budgetAlert,
        severity: InsightSeverity.warning,
        title: 'Orçamento no limite',
        description:
            '"$catName" usou ${(bp.percentage * 100).toStringAsFixed(0)}% '
            'do orçamento de ${CurrencyFormatter.format(bp.budget.amount)}.',
        icon: Icons.notifications_active_rounded,
        actionLabel: 'Ver orçamentos',
        actionRoute: AppRoutes.budgets,
      ));
    }
  }

  // ── Insights de metas ────────────────────────────────────────────────────
  final goals = ref
      .watch(watchGoalsProvider(GoalStatus.active))
      .maybeWhen(data: (l) => l, orElse: () => <Goal>[]);

  for (final goal in goals) {
    if (goal.isCompleted) continue;
    final days = daysRemaining(goal);

    if (days <= 7 && days > 0) {
      insights.add(Insight(
        type: InsightType.goalExpiringSoon,
        severity: InsightSeverity.danger,
        title: 'Meta expira em breve',
        description:
            '"${goal.name}" vence em $days ${days == 1 ? 'dia' : 'dias'} '
            'com ${(goal.progress * 100).toStringAsFixed(0)}% concluído.',
        icon: Icons.flag_rounded,
        actionLabel: 'Ver metas',
        actionRoute: AppRoutes.goals,
      ));
    } else if (days > 0 && days <= 30 && goal.progress < 0.5) {
      insights.add(Insight(
        type: InsightType.goalAtRisk,
        severity: InsightSeverity.warning,
        title: 'Meta em risco',
        description:
            '"${goal.name}" está com ${(goal.progress * 100).toStringAsFixed(0)}% '
            'de progresso e vence em $days dias.',
        icon: Icons.trending_down_rounded,
        actionLabel: 'Ver metas',
        actionRoute: AppRoutes.goals,
      ));
    }
  }

  // ── Insights de saldo ────────────────────────────────────────────────────
  if (income == 0 && expense > 0) {
    insights.add(const Insight(
      type: InsightType.noIncome,
      severity: InsightSeverity.info,
      title: 'Nenhuma receita este mês',
      description:
          'Você registrou despesas, mas ainda não lançou nenhuma receita. '
          'Adicione suas entradas para acompanhar o saldo real.',
      icon: Icons.account_balance_wallet_outlined,
    ));
  } else if (income > 0 && expense > income) {
    insights.add(Insight(
      type: InsightType.negativeBalance,
      severity: InsightSeverity.danger,
      title: 'Saldo negativo este mês',
      description:
          'Despesas (${CurrencyFormatter.format(expense)}) superaram receitas '
          '(${CurrencyFormatter.format(income)}) em '
          '${CurrencyFormatter.format(expense - income)}.',
      icon: Icons.account_balance_wallet_rounded,
    ));
  } else if (income > 0) {
    final savingsRate = (income - expense) / income;
    if (savingsRate >= 0.2) {
      insights.add(Insight(
        type: InsightType.goodSavingsRate,
        severity: InsightSeverity.success,
        title: 'Boa taxa de poupança',
        description:
            'Você economizou ${(savingsRate * 100).toStringAsFixed(0)}% '
            'da sua renda este mês. Continue assim!',
        icon: Icons.emoji_events_rounded,
      ));
    }
  }

  // ── Comparação com mês anterior ──────────────────────────────────────────
  if (lastMonth != null && lastMonth.expense > 0 && expense > 0) {
    final diff = expense - lastMonth.expense;
    final pct = diff / lastMonth.expense;

    if (pct > 0.15) {
      insights.add(Insight(
        type: InsightType.spendingIncreased,
        severity: InsightSeverity.warning,
        title: 'Gastos ${(pct * 100).toStringAsFixed(0)}% maiores',
        description:
            'Você gastou ${CurrencyFormatter.format(diff)} a mais do que no '
            'mês passado.',
        icon: Icons.trending_up_rounded,
        actionLabel: 'Ver relatórios',
        actionRoute: AppRoutes.reports,
      ));
    } else if (pct < -0.15) {
      insights.add(Insight(
        type: InsightType.spendingDecreased,
        severity: InsightSeverity.success,
        title: 'Gastos ${(pct.abs() * 100).toStringAsFixed(0)}% menores',
        description:
            'Você gastou ${CurrencyFormatter.format(diff.abs())} a menos do '
            'que no mês passado. Ótimo trabalho!',
        icon: Icons.trending_down_rounded,
      ));
    }
  }

  // ── Categoria principal ──────────────────────────────────────────────────
  final transactions = ref
      .watch(currentMonthTransactionsProvider)
      .maybeWhen(data: (l) => l, orElse: () => <Transaction>[]);

  if (transactions.isNotEmpty && expense > 0) {
    final catTotals = <String, int>{};
    for (final t
        in transactions.where((t) => t.type == TransactionType.expense)) {
      final key = t.categoryId ?? '_sem_categoria';
      catTotals[key] = (catTotals[key] ?? 0) + t.amount;
    }

    if (catTotals.isNotEmpty) {
      final topEntry =
          catTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final cat = categories.cast<Category?>().firstWhere(
            (c) => c?.id == topEntry.key,
            orElse: () => null,
          );
      final catName = cat?.name ?? 'Sem categoria';
      final pctOfTotal = topEntry.value / expense;

      if (pctOfTotal >= 0.3) {
        insights.add(Insight(
          type: InsightType.topCategory,
          severity: InsightSeverity.info,
          title: 'Maior gasto: $catName',
          description:
              '"$catName" representa ${(pctOfTotal * 100).toStringAsFixed(0)}% '
              'dos seus gastos (${CurrencyFormatter.format(topEntry.value)}).',
          icon: Icons.donut_large_rounded,
          actionLabel: 'Ver relatórios',
          actionRoute: AppRoutes.reports,
        ));
      }
    }
  }

  // Ordena: danger primeiro, success por último
  insights.sort((a, b) => b.severity.index.compareTo(a.severity.index));
  return insights;
}
