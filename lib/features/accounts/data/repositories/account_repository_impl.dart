// lib/features/accounts/data/repositories/account_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/firestore_helper.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';
import '../models/account_model.dart';

final class AccountRepositoryImpl
    with FirestoreExceptionMapper
    implements AccountRepository {
  AccountRepositoryImpl(this._ds, this._userId);

  final AccountRemoteDataSource _ds;
  final String _userId;

  @override
  Stream<List<Account>> watchAccounts() {
    return _ds
        .watchAccounts(_userId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Account>> getAccountById(String id) async {
    try {
      return Right((await _ds.getAccountById(_userId, id)).toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AccountRepo.getById'));
    }
  }

  @override
  Future<Either<Failure, Account>> createAccount(Account account) async {
    try {
      final model =
          await _ds.createAccount(AccountModel.fromEntity(account));
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AccountRepo.create'));
    }
  }

  @override
  Future<Either<Failure, Account>> updateAccount(Account account) async {
    try {
      final model =
          await _ds.updateAccount(AccountModel.fromEntity(account));
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AccountRepo.update'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await _ds.deleteAccount(_userId, id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AccountRepo.delete'));
    }
  }

  @override
  Future<Either<Failure, void>> adjustBalance(
    String accountId,
    int delta,
  ) async {
    try {
      await _ds.adjustBalance(_userId, accountId, delta);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AccountRepo.adjustBalance'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalBalance() async {
    try {
      return Right(await _ds.getTotalBalance(_userId));
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AccountRepo.getTotalBalance'));
    }
  }
}
