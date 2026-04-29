// lib/features/transactions/domain/repositories/transaction_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/transaction.dart';

/// Filtros para consultas de transações.
final class TransactionFilter {
  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.type,
    this.accountId,
    this.categoryId,
    this.status,
    this.creditCardId,
    this.limit = 50,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;
  final String? accountId;
  final String? categoryId;
  final TransactionStatus? status;

  /// Filtra transações de um cartão de crédito específico.
  final String? creditCardId;

  final int limit;
}

abstract interface class TransactionRepository {
  /// Stream de transações com filtros opcionais, ordenadas por data desc.
  Stream<List<Transaction>> watchTransactions({TransactionFilter? filter});

  /// Retorna uma transação pelo ID.
  Future<Either<Failure, Transaction>> getTransactionById(String id);

  /// Cria uma transação e atualiza o saldo da conta de forma atômica.
  Future<Either<Failure, Transaction>> createTransaction(
    Transaction transaction,
  );

  /// Cria múltiplas transações atomicamente (ex: parcelas de cartão).
  Future<Either<Failure, List<Transaction>>> createTransactionsBatch(
    List<Transaction> transactions,
  );

  /// Atualiza uma transação e reajusta o saldo da conta.
  Future<Either<Failure, Transaction>> updateTransaction(
    Transaction transaction,
    Transaction oldTransaction,
  );

  /// Remove uma transação e reverte o efeito no saldo da conta.
  Future<Either<Failure, void>> deleteTransaction(Transaction transaction);

  /// Retorna o total de receitas em um período.
  Future<Either<Failure, int>> getTotalIncome({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Retorna o total de despesas em um período.
  Future<Either<Failure, int>> getTotalExpense({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Retorna o saldo do período (receitas - despesas).
  Future<Either<Failure, int>> getPeriodBalance({
    required DateTime startDate,
    required DateTime endDate,
  });
}
