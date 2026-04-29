// lib/features/goals/domain/repositories/goal_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/goal.dart';

abstract interface class GoalRepository {
  Stream<List<Goal>> watchGoals({GoalStatus? status});
  Future<Either<Failure, Goal>> getGoalById(String id);
  Future<Either<Failure, Goal>> createGoal(Goal goal);
  Future<Either<Failure, Goal>> updateGoal(Goal goal);
  Future<Either<Failure, void>> deleteGoal(String id);

  /// Adiciona valor ao progresso da meta de forma atômica.
  /// [amount] em centavos. Positivo para depositar, negativo para retirar.
  Future<Either<Failure, void>> addProgress(String goalId, int amount);
}
