// lib/features/transactions/presentation/providers/transaction_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_providers.g.dart';

// ── Infra (keepAlive) ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
TransactionRemoteDataSource transactionRemoteDataSource(Ref ref) {
  return TransactionRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepositoryImpl(
    ref.watch(transactionRemoteDataSourceProvider),
    ref.watch(currentUserIdProvider),
  );
}

// ── Streams ───────────────────────────────────────────────────────────────────

/// Últimas 10 transações do usuário, ordenadas por data desc.
@riverpod
Stream<List<Transaction>> watchRecentTransactions(Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchTransactions(
        filter: const TransactionFilter(limit: 10),
      );
}

// ── Totais mensais ────────────────────────────────────────────────────────────

/// Total de receitas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
@riverpod
Future<int> monthlyIncome(Ref ref, DateTime month) async {
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  final result = await ref
      .watch(transactionRepositoryProvider)
      .getTotalIncome(startDate: start, endDate: end);
  return result.fold((_) => 0, (v) => v);
}

/// Total de despesas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
@riverpod
Future<int> monthlyExpense(Ref ref, DateTime month) async {
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  final result = await ref
      .watch(transactionRepositoryProvider)
      .getTotalExpense(startDate: start, endDate: end);
  return result.fold((_) => 0, (v) => v);
}

// ── Resumo dos últimos 6 meses (para gráfico) ─────────────────────────────────

/// Resumo mensal de receitas e despesas para um único mês.
final class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;

  /// Receitas do mês em centavos.
  final int income;

  /// Despesas do mês em centavos.
  final int expense;

  /// Resultado do mês (receitas − despesas) em centavos.
  int get result => income - expense;
}

/// Retorna o resumo dos últimos 6 meses para exibição em gráfico.
@riverpod
Future<List<MonthlySummary>> monthlySummaryList(Ref ref) async {
  final now = DateTime.now();
  final repo = ref.watch(transactionRepositoryProvider);
  final summaries = <MonthlySummary>[];

  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final incomeResult =
        await repo.getTotalIncome(startDate: start, endDate: end);
    final expenseResult =
        await repo.getTotalExpense(startDate: start, endDate: end);

    summaries.add(MonthlySummary(
      month: month,
      income: incomeResult.fold((_) => 0, (v) => v),
      expense: expenseResult.fold((_) => 0, (v) => v),
    ));
  }

  return summaries;
}

// ── Filtro de transações ──────────────────────────────────────────────────────

/// Estado imutável dos filtros da tela de transações.
final class TransactionFilterState {
  const TransactionFilterState({
    this.type,
    this.startDate,
    this.endDate,
    this.accountId,
    this.categoryId,
  });

  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? accountId;
  final String? categoryId;

  bool get hasActiveFilters =>
      type != null ||
      startDate != null ||
      endDate != null ||
      accountId != null ||
      categoryId != null;

  int get activeFilterCount => [
        type,
        startDate ?? endDate,
        accountId,
        categoryId,
      ].where((e) => e != null).length;

  TransactionFilter toFilter({int limit = 100}) => TransactionFilter(
        type: type,
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        categoryId: categoryId,
        limit: limit,
      );

  TransactionFilterState withType(TransactionType? t) => TransactionFilterState(
        type: t,
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        categoryId: categoryId,
      );

  TransactionFilterState withDateRange(DateTime? start, DateTime? end) =>
      TransactionFilterState(
        type: type,
        startDate: start,
        endDate: end,
        accountId: accountId,
        categoryId: categoryId,
      );

  TransactionFilterState withAccount(String? id) => TransactionFilterState(
        type: type,
        startDate: startDate,
        endDate: endDate,
        accountId: id,
        categoryId: categoryId,
      );

  TransactionFilterState withCategory(String? id) => TransactionFilterState(
        type: type,
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
        categoryId: id,
      );
}

/// Notifier do estado de filtros da tela de transações.
@riverpod
class TransactionFilterNotifier extends _$TransactionFilterNotifier {
  @override
  TransactionFilterState build() => const TransactionFilterState();

  void setType(TransactionType? type) => state = state.withType(type);
  void setDateRange(DateTime? start, DateTime? end) =>
      state = state.withDateRange(start, end);
  void setAccount(String? accountId) => state = state.withAccount(accountId);
  void setCategory(String? categoryId) =>
      state = state.withCategory(categoryId);
  void reset() => state = const TransactionFilterState();
}

/// Stream de transações com filtros dinâmicos aplicados.
@riverpod
Stream<List<Transaction>> watchFilteredTransactions(Ref ref) {
  final filterState = ref.watch(transactionFilterNotifierProvider);
  return ref
      .watch(transactionRepositoryProvider)
      .watchTransactions(filter: filterState.toFilter());
}

// ── CRUD de transações ────────────────────────────────────────────────────────

/// Notifier para operações de criação, edição e exclusão de transações.
///
/// Estado: [AsyncValue<void>] — AsyncData = idle/success, AsyncLoading = em progresso,
/// AsyncError = falha com mensagem.
@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createTransaction(Transaction transaction) async {
    state = const AsyncLoading();
    final result = await ref
        .read(transactionRepositoryProvider)
        .createTransaction(transaction);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> updateTransaction(
    Transaction transaction,
    Transaction oldTransaction,
  ) async {
    state = const AsyncLoading();
    final result = await ref
        .read(transactionRepositoryProvider)
        .updateTransaction(transaction, oldTransaction);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> deleteTransaction(Transaction transaction) async {
    state = const AsyncLoading();
    final result = await ref
        .read(transactionRepositoryProvider)
        .deleteTransaction(transaction);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

// ── Transação por ID ──────────────────────────────────────────────────────────

/// Carrega uma transação específica por ID (para tela de detalhe).
@riverpod
Future<Transaction?> transactionById(Ref ref, String id) async {
  final result =
      await ref.read(transactionRepositoryProvider).getTransactionById(id);
  return result.fold((_) => null, (tx) => tx);
}

// ── Transações por conta ──────────────────────────────────────────────────────

/// Stream das últimas 30 transações de uma conta específica.
///
/// Usado na tela de detalhe da conta para exibir o extrato.
@riverpod
Stream<List<Transaction>> watchAccountTransactions(
  Ref ref,
  String accountId,
) {
  return ref.watch(transactionRepositoryProvider).watchTransactions(
        filter: TransactionFilter(accountId: accountId, limit: 30),
      );
}

// ── Transações por cartão de crédito ──────────────────────────────────────────

/// Stream das transações de um cartão de crédito para um período de fatura.
///
/// [yearMonth] no formato 'YYYY-MM'. Filtra um intervalo amplo que cobre o
/// ciclo de cobrança típico (mês anterior + mês atual).
@riverpod
Stream<List<Transaction>> watchCreditCardTransactions(
  Ref ref,
  String cardId,
  String yearMonth,
) {
  final parts = yearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  // Abrange do início do mês anterior até o fim do mês atual para capturar
  // qualquer ciclo de cobrança independente do dia de fechamento.
  final startDate = DateTime(year, month - 1, 1);
  final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

  return ref.watch(transactionRepositoryProvider).watchTransactions(
        filter: TransactionFilter(
          creditCardId: cardId,
          startDate: startDate,
          endDate: endDate,
          limit: 200,
        ),
      );
}
