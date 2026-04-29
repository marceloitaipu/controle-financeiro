// lib/features/accounts/domain/repositories/account_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/account.dart';

abstract interface class AccountRepository {
  /// Stream de todas as contas do usuário, ordenadas por nome.
  Stream<List<Account>> watchAccounts();

  /// Retorna uma conta pelo ID.
  Future<Either<Failure, Account>> getAccountById(String id);

  /// Cria uma nova conta.
  Future<Either<Failure, Account>> createAccount(Account account);

  /// Atualiza uma conta existente.
  Future<Either<Failure, Account>> updateAccount(Account account);

  /// Remove uma conta e todas as transações vinculadas.
  Future<Either<Failure, void>> deleteAccount(String id);

  /// Atualiza o saldo de uma conta de forma atômica (incremento/decremento).
  /// [delta] em centavos — positivo para crédito, negativo para débito.
  Future<Either<Failure, void>> adjustBalance(String accountId, int delta);

  /// Saldo total de todas as contas com [includeInTotal] == true.
  Future<Either<Failure, int>> getTotalBalance();
}
