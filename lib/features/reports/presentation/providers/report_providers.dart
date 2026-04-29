// lib/features/reports/presentation/providers/report_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

part 'report_providers.g.dart';

// ── Período do relatório ───────────────────────────────────────────────────

enum ReportPeriod { thisMonth, lastMonth, last3Months, last6Months, thisYear, custom }

extension ReportPeriodLabel on ReportPeriod {
  String get label => switch (this) {
        ReportPeriod.thisMonth => 'Este mês',
        ReportPeriod.lastMonth => 'Mês anterior',
        ReportPeriod.last3Months => 'Últimos 3 meses',
        ReportPeriod.last6Months => 'Últimos 6 meses',
        ReportPeriod.thisYear => 'Este ano',
        ReportPeriod.custom => 'Personalizado',
      };

  (DateTime start, DateTime end) dateRange(
      DateTime? customStart, DateTime? customEnd) {
    final now = DateTime.now();
    return switch (this) {
      ReportPeriod.thisMonth => (
          DateTime(now.year, now.month),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        ),
      ReportPeriod.lastMonth => (
          DateTime(now.year, now.month - 1),
          DateTime(now.year, now.month, 0, 23, 59, 59),
        ),
      ReportPeriod.last3Months => (
          DateTime(now.year, now.month - 2),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        ),
      ReportPeriod.last6Months => (
          DateTime(now.year, now.month - 5),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        ),
      ReportPeriod.thisYear => (
          DateTime(now.year),
          DateTime(now.year, 12, 31, 23, 59, 59),
        ),
      ReportPeriod.custom => (
          customStart ?? DateTime(now.year, now.month),
          customEnd ?? DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        ),
    };
  }
}

// ── Estado dos filtros do relatório ───────────────────────────────────────

final class ReportFilterState {
  const ReportFilterState({
    this.period = ReportPeriod.thisMonth,
    this.customStart,
    this.customEnd,
    this.categoryId,
    this.accountId,
  });

  final ReportPeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;
  final String? categoryId;
  final String? accountId;

  (DateTime start, DateTime end) get dateRange =>
      period.dateRange(customStart, customEnd);

  ReportFilterState copyWith({
    ReportPeriod? period,
    DateTime? customStart,
    DateTime? customEnd,
    String? categoryId,
    String? accountId,
    bool clearCategory = false,
    bool clearAccount = false,
  }) =>
      ReportFilterState(
        period: period ?? this.period,
        customStart: customStart ?? this.customStart,
        customEnd: customEnd ?? this.customEnd,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        accountId: clearAccount ? null : (accountId ?? this.accountId),
      );
}

// ── Notifier dos filtros ───────────────────────────────────────────────────

@riverpod
class ReportFilter extends _$ReportFilter {
  @override
  ReportFilterState build() => const ReportFilterState();

  void setPeriod(ReportPeriod period) =>
      state = state.copyWith(period: period);

  void setCustomRange(DateTime start, DateTime end) => state = state.copyWith(
        period: ReportPeriod.custom,
        customStart: start,
        customEnd: end,
      );

  void setCategoryId(String? id) =>
      state = id == null ? state.copyWith(clearCategory: true) : state.copyWith(categoryId: id);

  void setAccountId(String? id) =>
      state = id == null ? state.copyWith(clearAccount: true) : state.copyWith(accountId: id);

  void reset() => state = const ReportFilterState();
}

// ── Modelos de dados ──────────────────────────────────────────────────────

final class CategoryExpense {
  const CategoryExpense({
    required this.categoryId,
    required this.categoryName,
    required this.colorHex,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.total,
    required this.percentage,
    required this.transactionCount,
  });

  final String categoryId;
  final String categoryName;
  final String colorHex;
  final int iconCodePoint;
  final String iconFontFamily;
  final int total; // centavos
  final double percentage;
  final int transactionCount;
}

final class MonthlyEvolution {
  const MonthlyEvolution({
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
  });

  final DateTime month;
  final int income;   // centavos
  final int expense;  // centavos
  final int balance;  // income - expense
}

final class ReportSummary {
  const ReportSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.avgExpensePerDay,
    required this.biggestExpense,
  });

  final int totalIncome;
  final int totalExpense;
  final int balance;
  final int transactionCount;
  final int avgExpensePerDay;
  final int biggestExpense;
}

// ── Providers de dados ────────────────────────────────────────────────────

/// Transações no período com filtros aplicados.
@riverpod
Stream<List<Transaction>> reportTransactions(Ref ref) {
  final filter = ref.watch(reportFilterProvider);
  final (start, end) = filter.dateRange;

  return ref.watch(transactionRepositoryProvider).watchTransactions(
        filter: TransactionFilter(
          startDate: start,
          endDate: end,
          categoryId: filter.categoryId,
          accountId: filter.accountId,
          limit: 500,
        ),
      );
}

/// Resumo consolidado do período.
@riverpod
Future<ReportSummary> reportSummary(Ref ref) async {
  final txAsync = await ref.watch(reportTransactionsProvider.future);
  final filter = ref.watch(reportFilterProvider);
  final (start, end) = filter.dateRange;
  final days = end.difference(start).inDays + 1;

  final income = txAsync
      .where((t) => t.type == TransactionType.income)
      .fold(0, (s, t) => s + t.amount);
  final expense = txAsync
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (s, t) => s + t.amount);
  final biggest = txAsync
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (max, t) => t.amount > max ? t.amount : max);

  return ReportSummary(
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
    transactionCount: txAsync.length,
    avgExpensePerDay: days > 0 ? expense ~/ days : 0,
    biggestExpense: biggest,
  );
}

/// Despesas agrupadas por categoria com percentual.
@riverpod
Future<List<CategoryExpense>> reportByCategory(Ref ref) async {
  final transactions =
      await ref.watch(reportTransactionsProvider.future);
  final categoriesAsync =
      ref.watch(watchCategoriesProvider(CategoryType.expense));

  final categories = categoriesAsync.maybeWhen(
    data: (list) => list,
    orElse: () => <Category>[],
  );

  final expenses = transactions
      .where((t) => t.type == TransactionType.expense);

  final Map<String, int> totals = {};
  final Map<String, int> counts = {};
  for (final t in expenses) {
    final key = t.categoryId ?? '_sem_categoria';
    totals[key] = (totals[key] ?? 0) + t.amount;
    counts[key] = (counts[key] ?? 0) + 1;
  }

  if (totals.isEmpty) return [];

  final grandTotal = totals.values.fold(0, (s, v) => s + v);

  final result = <CategoryExpense>[];
  for (final entry in totals.entries) {
    final cat = categories.cast<Category?>().firstWhere(
          (c) => c?.id == entry.key,
          orElse: () => null,
        );
    result.add(CategoryExpense(
      categoryId: entry.key,
      categoryName: cat?.name ?? 'Sem categoria',
      colorHex: cat?.colorHex ?? '#78909C',
      iconCodePoint: cat?.iconCodePoint ?? 0xe532,
      iconFontFamily: cat?.iconFontFamily ?? 'MaterialIcons',
      total: entry.value,
      percentage: grandTotal > 0 ? entry.value / grandTotal : 0,
      transactionCount: counts[entry.key] ?? 0,
    ));
  }

  result.sort((a, b) => b.total.compareTo(a.total));
  return result;
}

/// Evolução mensal no período selecionado (mês a mês).
@riverpod
Future<List<MonthlyEvolution>> reportEvolution(Ref ref) async {
  final filter = ref.watch(reportFilterProvider);
  final (start, end) = filter.dateRange;
  final repo = ref.watch(transactionRepositoryProvider);

  final List<MonthlyEvolution> result = [];
  var cursor = DateTime(start.year, start.month);

  while (!cursor.isAfter(DateTime(end.year, end.month))) {
    final mStart = DateTime(cursor.year, cursor.month);
    final mEnd = DateTime(cursor.year, cursor.month + 1, 0, 23, 59, 59);

    final incR = await repo.getTotalIncome(startDate: mStart, endDate: mEnd);
    final expR = await repo.getTotalExpense(startDate: mStart, endDate: mEnd);
    final inc = incR.fold((_) => 0, (v) => v);
    final exp = expR.fold((_) => 0, (v) => v);

    result.add(MonthlyEvolution(
      month: cursor,
      income: inc,
      expense: exp,
      balance: inc - exp,
    ));
    cursor = DateTime(cursor.year, cursor.month + 1);
  }

  return result;
}
