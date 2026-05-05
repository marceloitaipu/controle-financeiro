// test/features/goals/presentation/goal_provider_helpers_test.dart

import 'package:controle_financeiro/features/goals/domain/entities/goal.dart';
import 'package:controle_financeiro/features/goals/presentation/providers/goal_providers.dart';
import 'package:flutter_test/flutter_test.dart';

Goal makeGoal({
  int targetAmount = 100000,
  int currentAmount = 0,
  required DateTime deadline,
  GoalStatus status = GoalStatus.active,
  DateTime? createdAt,
}) {
  return Goal(
    id: 'g-1',
    userId: 'u-1',
    name: 'Meta teste',
    targetAmount: targetAmount,
    currentAmount: currentAmount,
    deadline: deadline,
    colorHex: '#1565C0',
    iconCodePoint: 0xe7ef,
    iconFontFamily: 'MaterialIcons',
    status: status,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  // ── daysRemaining ──────────────────────────────────────────────────────────
  group('daysRemaining', () {
    test('retorna dias positivos quando prazo no futuro', () {
      final deadline = DateTime.now().add(const Duration(days: 30));
      final goal = makeGoal(deadline: deadline);
      expect(daysRemaining(goal), closeTo(30, 1));
    });

    test('retorna 0 quando prazo já passou', () {
      final deadline = DateTime.now().subtract(const Duration(days: 5));
      final goal = makeGoal(deadline: deadline);
      expect(daysRemaining(goal), 0);
    });

    test('retorna 0 exatamente no prazo (deadline = now)', () {
      final deadline = DateTime.now();
      final goal = makeGoal(deadline: deadline);
      expect(daysRemaining(goal), 0);
    });
  });

  // ── dailyAmountNeeded ──────────────────────────────────────────────────────
  group('dailyAmountNeeded', () {
    test('calcula valor diário necessário', () {
      final deadline = DateTime.now().add(const Duration(days: 10));
      // remaining = 100000, days = 10 → 10000/dia
      final goal = makeGoal(targetAmount: 100000, currentAmount: 0, deadline: deadline);
      expect(dailyAmountNeeded(goal), closeTo(10000, 100));
    });

    test('retorna 0 quando prazo passou', () {
      final deadline = DateTime.now().subtract(const Duration(days: 1));
      final goal = makeGoal(targetAmount: 100000, currentAmount: 0, deadline: deadline);
      expect(dailyAmountNeeded(goal), 0);
    });

    test('retorna 0 quando meta já concluída', () {
      final deadline = DateTime.now().add(const Duration(days: 30));
      final goal = makeGoal(
        targetAmount: 100000,
        currentAmount: 100000,
        deadline: deadline,
        status: GoalStatus.completed,
      );
      expect(dailyAmountNeeded(goal), 0);
    });

    test('arredonda para cima (ceil) o valor diário', () {
      final deadline = DateTime.now().add(const Duration(days: 3));
      // remaining = 10000, days = 3 → ceil(3333.3) = 3334
      final goal = makeGoal(targetAmount: 10000, currentAmount: 0, deadline: deadline);
      expect(dailyAmountNeeded(goal), greaterThanOrEqualTo(3333));
    });
  });

  // ── projectedCompletionDate ────────────────────────────────────────────────
  group('projectedCompletionDate', () {
    test('retorna null quando meta já concluída', () {
      final goal = makeGoal(
        targetAmount: 100000,
        currentAmount: 100000,
        deadline: DateTime.now().add(const Duration(days: 30)),
        status: GoalStatus.completed,
      );
      expect(projectedCompletionDate(goal), isNull);
    });

    test('retorna null quando currentAmount é zero', () {
      final goal = makeGoal(
        targetAmount: 100000,
        currentAmount: 0,
        deadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(projectedCompletionDate(goal), isNull);
    });

    test('retorna null quando nenhum dia decorrido desde criação', () {
      final goal = makeGoal(
        targetAmount: 100000,
        currentAmount: 50000,
        deadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(), // criado agora → 0 dias decorridos
      );
      expect(projectedCompletionDate(goal), isNull);
    });

    test('retorna data futura quando há progresso', () {
      // Criado há 10 dias, poupou 50% do alvo → taxa = 50000/10 = 5000/dia
      // remaining = 50000, daysNeeded = ceil(50000/5000) = 10
      final goal = makeGoal(
        targetAmount: 100000,
        currentAmount: 50000,
        deadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      final projected = projectedCompletionDate(goal);
      expect(projected, isNotNull);
      expect(projected!.isAfter(DateTime.now()), isTrue);
    });
  });
}
