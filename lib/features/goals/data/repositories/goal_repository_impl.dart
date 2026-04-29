// lib/features/goals/data/repositories/goal_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/firestore_helper.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_remote_datasource.dart';
import '../models/goal_model.dart';

final class GoalRepositoryImpl
    with FirestoreExceptionMapper
    implements GoalRepository {
  GoalRepositoryImpl(this._ds, this._userId);

  final GoalRemoteDataSource _ds;
  final String _userId;

  @override
  Stream<List<Goal>> watchGoals({GoalStatus? status}) {
    return _ds
        .watchGoals(_userId, status: status)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Goal>> getGoalById(String id) async {
    try {
      return Right((await _ds.getGoalById(_userId, id)).toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'GoalRepo.getById'));
    }
  }

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) async {
    try {
      final model = await _ds.createGoal(GoalModel.fromEntity(goal));
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'GoalRepo.create'));
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    try {
      final model = await _ds.updateGoal(GoalModel.fromEntity(goal));
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'GoalRepo.update'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    try {
      await _ds.deleteGoal(_userId, id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'GoalRepo.delete'));
    }
  }

  @override
  Future<Either<Failure, void>> addProgress(
    String goalId,
    int amount,
  ) async {
    try {
      await _ds.addProgress(_userId, goalId, amount);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'GoalRepo.addProgress'));
    }
  }
}
