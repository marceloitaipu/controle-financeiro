// lib/features/budgets/data/repositories/budget_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/firestore_helper.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_datasource.dart';
import '../models/budget_model.dart';

final class BudgetRepositoryImpl
    with FirestoreExceptionMapper
    implements BudgetRepository {
  BudgetRepositoryImpl(this._ds, this._userId, this._firestore);

  final BudgetRemoteDataSource _ds;
  final String _userId;
  final FirebaseFirestore _firestore;

  @override
  Stream<List<Budget>> watchBudgets({bool onlyActive = true}) {
    return _ds
        .watchBudgets(_userId, onlyActive: onlyActive)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Budget>> getBudgetById(String id) async {
    try {
      return Right((await _ds.getBudgetById(_userId, id)).toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'BudgetRepo.getById'));
    }
  }

  @override
  Future<Either<Failure, Budget>> createBudget(Budget budget) async {
    try {
      final model =
          await _ds.createBudget(BudgetModel.fromEntity(budget));
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'BudgetRepo.create'));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      final model =
          await _ds.updateBudget(BudgetModel.fromEntity(budget));
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'BudgetRepo.update'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await _ds.deleteBudget(_userId, id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'BudgetRepo.delete'));
    }
  }

  @override
  Future<Either<Failure, int>> getSpentAmount({
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .where('categoryId', isEqualTo: categoryId)
          .where('type', isEqualTo: 'expense')
          .where('status', isEqualTo: 'completed')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final total = snap.docs
          .map((d) => d.data()['amount'] as int? ?? 0)
          .fold(0, (s, a) => s + a);
      return Right(total);
    } catch (e, st) {
      AppLogger.error('BudgetRepo.getSpentAmount', e, st);
      return Left(mapUnexpected(e, st, 'BudgetRepo.getSpentAmount'));
    }
  }
}
