// lib/features/goals/presentation/providers/goal_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/goal_remote_datasource.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

part 'goal_providers.g.dart';

// ── Infra ──────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
GoalRemoteDataSource goalRemoteDataSource(Ref ref) {
  return GoalRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) {
  return GoalRepositoryImpl(
    ref.watch(goalRemoteDataSourceProvider),
    ref.watch(currentUserIdProvider),
  );
}

// ── Streams ────────────────────────────────────────────────────────────────

/// Stream de metas com filtro opcional por status.
///
/// Uso:
/// ```dart
/// ref.watch(watchGoalsProvider(null))                 // todas
/// ref.watch(watchGoalsProvider(GoalStatus.active))    // ativas
/// ```
@riverpod
Stream<List<Goal>> watchGoals(Ref ref, GoalStatus? status) {
  return ref.watch(goalRepositoryProvider).watchGoals(status: status);
}

// ── Helpers ────────────────────────────────────────────────────────────────

/// Calcula os dias restantes até o prazo da meta.
/// Retorna 0 se o prazo já passou.
int daysRemaining(Goal goal) {
  final diff = goal.deadline.difference(DateTime.now());
  return diff.inDays.clamp(0, 99999);
}

/// Calcula o valor diário necessário para atingir a meta no prazo.
/// Retorna 0 se já foi atingida ou o prazo passou.
int dailyAmountNeeded(Goal goal) {
  final days = daysRemaining(goal);
  if (days == 0 || goal.isCompleted) return 0;
  final remaining = goal.remainingAmount;
  return (remaining / days).ceil();
}

/// Calcula a data projetada de conclusão com base na taxa de depósito diária
/// dos últimos N dias (aproximado via média simples de currentAmount / dias decorridos).
DateTime? projectedCompletionDate(Goal goal) {
  if (goal.isCompleted) return null;
  final elapsed = DateTime.now().difference(goal.createdAt).inDays;
  if (elapsed == 0 || goal.currentAmount == 0) return null;
  final dailyRate = goal.currentAmount / elapsed;
  if (dailyRate <= 0) return null;
  final daysNeeded = (goal.remainingAmount / dailyRate).ceil();
  return DateTime.now().add(Duration(days: daysNeeded));
}

// ── CRUD ───────────────────────────────────────────────────────────────────

/// Notifier responsável por criar, editar, remover e depositar nas metas.
@riverpod
class GoalNotifier extends _$GoalNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createGoal(Goal goal) async {
    state = const AsyncLoading();
    final result = await ref.read(goalRepositoryProvider).createGoal(goal);
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

  Future<bool> updateGoal(Goal goal) async {
    state = const AsyncLoading();
    final result = await ref.read(goalRepositoryProvider).updateGoal(goal);
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

  Future<bool> deleteGoal(String id) async {
    state = const AsyncLoading();
    final result = await ref.read(goalRepositoryProvider).deleteGoal(id);
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

  /// Deposita (positivo) ou retira (negativo) valor da meta.
  Future<bool> addProgress(String goalId, int amountCents) async {
    state = const AsyncLoading();
    final result =
        await ref.read(goalRepositoryProvider).addProgress(goalId, amountCents);
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
