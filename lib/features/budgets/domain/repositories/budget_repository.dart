// lib/features/budgets/domain/repositories/budget_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Stream<List<Budget>> watchBudgets({bool onlyActive = true});
  Future<Either<Failure, Budget>> getBudgetById(String id);
  Future<Either<Failure, Budget>> createBudget(Budget budget);
  Future<Either<Failure, Budget>> updateBudget(Budget budget);
  Future<Either<Failure, void>> deleteBudget(String id);

  /// Retorna o total gasto para uma categoria no período do orçamento.
  Future<Either<Failure, int>> getSpentAmount({
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
