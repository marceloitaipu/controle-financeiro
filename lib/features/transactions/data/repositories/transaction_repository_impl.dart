// lib/features/transactions/data/repositories/transaction_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/firestore_helper.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

final class TransactionRepositoryImpl
    with FirestoreExceptionMapper
    implements TransactionRepository {
  TransactionRepositoryImpl(this._ds, this._userId);

  final TransactionRemoteDataSource _ds;
  final String _userId;

  @override
  Stream<List<Transaction>> watchTransactions({TransactionFilter? filter}) {
    return _ds
        .watchTransactions(_userId, filter: filter)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      return Right(
          (await _ds.getTransactionById(_userId, id)).toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.getById'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    try {
      final model = await _ds
          .createTransaction(TransactionModel.fromEntity(transaction));
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.create'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> createTransactionsBatch(
    List<Transaction> transactions,
  ) async {
    try {
      final models = await _ds.createTransactionsBatch(
        transactions.map(TransactionModel.fromEntity).toList(),
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.createBatch'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    Transaction transaction,
    Transaction oldTransaction,
  ) async {
    try {
      final model = await _ds.updateTransaction(
        TransactionModel.fromEntity(transaction),
        TransactionModel.fromEntity(oldTransaction),
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.update'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    Transaction transaction,
  ) async {
    try {
      await _ds.deleteTransaction(TransactionModel.fromEntity(transaction));
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.delete'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalIncome({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return Right(await _ds.sumAmount(
        _userId,
        startDate: startDate,
        endDate: endDate,
        type: TransactionType.income,
      ));
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.getTotalIncome'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalExpense({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return Right(await _ds.sumAmount(
        _userId,
        startDate: startDate,
        endDate: endDate,
        type: TransactionType.expense,
      ));
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.getTotalExpense'));
    }
  }

  @override
  Future<Either<Failure, int>> getPeriodBalance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final income = await _ds.sumAmount(
        _userId,
        startDate: startDate,
        endDate: endDate,
        type: TransactionType.income,
      );
      final expense = await _ds.sumAmount(
        _userId,
        startDate: startDate,
        endDate: endDate,
        type: TransactionType.expense,
      );
      return Right(income - expense);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'TransactionRepo.getPeriodBalance'));
    }
  }
}
