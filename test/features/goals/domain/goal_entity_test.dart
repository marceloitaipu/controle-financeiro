// test/features/goals/domain/goal_entity_test.dart

import 'package:controle_financeiro/features/goals/domain/entities/goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 4, 23);
  final deadline = DateTime(2027, 12, 31);

  Goal makeGoal({
    int targetAmount = 100000,
    int currentAmount = 0,
    GoalStatus status = GoalStatus.active,
  }) {
    return Goal(
      id: 'goal-1',
      userId: 'user-1',
      name: 'Viagem',
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      colorHex: '#4CAF50',
      iconCodePoint: 0xe7ef,
      iconFontFamily: 'MaterialIcons',
      status: status,
      createdAt: baseDate,
    );
  }

  // ── Conversão ─────────────────────────────────────────────────────────────
  group('Goal — conversão de centavos', () {
    test('targetInReais converte corretamente', () {
      expect(makeGoal(targetAmount: 100000).targetInReais, closeTo(1000.0, 0.001));
    });

    test('currentInReais converte corretamente', () {
      expect(makeGoal(currentAmount: 50000).currentInReais, closeTo(500.0, 0.001));
    });
  });

  // ── progress ─────────────────────────────────────────────────────────────
  group('Goal.progress', () {
    test('0% quando currentAmount é zero', () {
      expect(makeGoal(targetAmount: 100000, currentAmount: 0).progress, 0.0);
    });

    test('50% quando na metade', () {
      expect(
        makeGoal(targetAmount: 100000, currentAmount: 50000).progress,
        closeTo(0.5, 0.001),
      );
    });

    test('100% quando atingido exatamente', () {
      expect(
        makeGoal(targetAmount: 100000, currentAmount: 100000).progress,
        1.0,
      );
    });

    test('clampado em 1.0 quando ultrapassa target', () {
      expect(
        makeGoal(targetAmount: 100000, currentAmount: 200000).progress,
        1.0,
      );
    });

    test('targetAmount zero retorna 0', () {
      expect(makeGoal(targetAmount: 0, currentAmount: 0).progress, 0.0);
    });
  });

  // ── remainingAmount ───────────────────────────────────────────────────────
  group('Goal.remainingAmount', () {
    test('retorna diferença quando currentAmount < targetAmount', () {
      expect(
        makeGoal(targetAmount: 100000, currentAmount: 40000).remainingAmount,
        60000,
      );
    });

    test('retorna zero quando meta atingida', () {
      expect(
        makeGoal(targetAmount: 100000, currentAmount: 100000).remainingAmount,
        0,
      );
    });

    test('retorna zero quando ultrapassa (clamp)', () {
      expect(
        makeGoal(targetAmount: 100000, currentAmount: 150000).remainingAmount,
        0,
      );
    });
  });

  // ── isCompleted ───────────────────────────────────────────────────────────
  group('Goal.isCompleted', () {
    test('false quando currentAmount < targetAmount', () {
      expect(makeGoal(targetAmount: 100000, currentAmount: 99999).isCompleted, isFalse);
    });

    test('true quando currentAmount == targetAmount', () {
      expect(makeGoal(targetAmount: 100000, currentAmount: 100000).isCompleted, isTrue);
    });

    test('true quando currentAmount > targetAmount', () {
      expect(makeGoal(targetAmount: 100000, currentAmount: 150000).isCompleted, isTrue);
    });
  });

  // ── GoalStatus.label ─────────────────────────────────────────────────────
  group('GoalStatus.label', () {
    test('active → Ativa', () {
      expect(GoalStatus.active.label, 'Ativa');
    });

    test('completed → Concluída', () {
      expect(GoalStatus.completed.label, 'Concluída');
    });

    test('cancelled → Cancelada', () {
      expect(GoalStatus.cancelled.label, 'Cancelada');
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('Goal.copyWith', () {
    test('altera apenas currentAmount', () {
      final original = makeGoal(currentAmount: 10000);
      final updated = original.copyWith(currentAmount: 50000);
      expect(updated.currentAmount, 50000);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
    });
  });
}
