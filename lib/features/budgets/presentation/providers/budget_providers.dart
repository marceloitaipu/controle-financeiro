// lib/features/budgets/presentation/providers/budget_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/budget_remote_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

part 'budget_providers.g.dart';

// ── Infra ──────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
BudgetRemoteDataSource budgetRemoteDataSource(Ref ref) {
  return BudgetRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  return BudgetRepositoryImpl(
    ref.watch(budgetRemoteDataSourceProvider),
    ref.watch(currentUserIdProvider),
    ref.watch(firebaseFirestoreProvider),
  );
}

// ── Streams ────────────────────────────────────────────────────────────────

/// Stream de orçamentos ativos do usuário.
@riverpod
Stream<List<Budget>> watchBudgets(Ref ref) {
  return ref.watch(budgetRepositoryProvider).watchBudgets();
}

// ── Modelo de progresso ────────────────────────────────────────────────────

/// Progresso calculado de um orçamento para um período específico.
final class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spentAmount,
  });

  final Budget budget;

  /// Total gasto no período (centavos).
  final int spentAmount;

  /// Percentual gasto (0.0 – N). Pode ultrapassar 1.0 se estourado.
  double get percentage =>
      budget.amount == 0 ? 0 : spentAmount / budget.amount;

  /// Quanto ainda resta do orçamento (pode ser negativo se estourado).
  int get remaining => budget.amount - spentAmount;

  /// O gasto atingiu ou ultrapassou o limiar de alerta.
  bool get isAlert => percentage >= budget.alertThreshold;

  /// O orçamento foi estourado.
  bool get isOverBudget => spentAmount > budget.amount;
}

/// Retorna a data de início e fim para um orçamento no mês de referência.
(DateTime start, DateTime end) budgetDateRange(Budget budget, DateTime month) {
  return switch (budget.period) {
    BudgetPeriod.monthly => (
        DateTime(month.year, month.month, 1),
        DateTime(month.year, month.month + 1, 1)
            .subtract(const Duration(seconds: 1)),
      ),
    BudgetPeriod.yearly => (
        DateTime(month.year, 1, 1),
        DateTime(month.year + 1, 1, 1).subtract(const Duration(seconds: 1)),
      ),
    BudgetPeriod.weekly => () {
        // Início da semana atual (segunda-feira ISO)
        final weekday = month.weekday; // 1=Seg … 7=Dom
        final start = DateTime(
          month.year,
          month.month,
          month.day - (weekday - 1),
        );
        final end = start
            .add(const Duration(days: 7))
            .subtract(const Duration(seconds: 1));
        return (start, end);
      }(),
    BudgetPeriod.custom => (
        budget.startDate,
        budget.endDate ??
            DateTime(month.year, month.month + 1, 1)
                .subtract(const Duration(seconds: 1)),
      ),
  };
}

/// Lista de [BudgetProgress] calculada para o mês informado.
///
/// Busca o valor gasto de cada orçamento ativo via [BudgetRepository.getSpentAmount].
@riverpod
Future<List<BudgetProgress>> budgetProgressList(
  Ref ref,
  DateTime month,
) async {
  // Aguarda a lista de orçamentos ativos.
  final budgets = await ref.watch(watchBudgetsProvider.future);
  final repo = ref.watch(budgetRepositoryProvider);

  final results = <BudgetProgress>[];

  for (final budget in budgets) {
    final (start, end) = budgetDateRange(budget, month);
    final spentResult = await repo.getSpentAmount(
      categoryId: budget.categoryId,
      startDate: start,
      endDate: end,
    );
    final spent = spentResult.getOrElse(() => 0);
    results.add(BudgetProgress(budget: budget, spentAmount: spent));
  }

  // Ordena: estourados primeiro, depois por percentual decrescente.
  results.sort((a, b) => b.percentage.compareTo(a.percentage));
  return results;
}

// ── CRUD ───────────────────────────────────────────────────────────────────

/// Notifier responsável por criar, editar e remover orçamentos.
@riverpod
class BudgetNotifier extends _$BudgetNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createBudget(Budget budget) async {
    state = const AsyncLoading();
    final result =
        await ref.read(budgetRepositoryProvider).createBudget(budget);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> updateBudget(Budget budget) async {
    state = const AsyncLoading();
    final result =
        await ref.read(budgetRepositoryProvider).updateBudget(budget);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> deleteBudget(String id) async {
    state = const AsyncLoading();
    final result =
        await ref.read(budgetRepositoryProvider).deleteBudget(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}
