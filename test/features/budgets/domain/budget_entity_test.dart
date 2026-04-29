// test/features/budgets/domain/budget_entity_test.dart

import 'package:controle_financeiro/features/budgets/domain/entities/budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 4, 1);

  Budget makeBudget({
    int amount = 50000,
    BudgetPeriod period = BudgetPeriod.monthly,
    double alertThreshold = 0.8,
    bool isActive = true,
  }) {
    return Budget(
      id: 'budget-1',
      userId: 'user-1',
      categoryId: 'cat-1',
      amount: amount,
      period: period,
      startDate: baseDate,
      alertThreshold: alertThreshold,
      isActive: isActive,
      createdAt: baseDate,
    );
  }

  // ── amountInReais ─────────────────────────────────────────────────────────
  group('Budget.amountInReais', () {
    test('converte centavos para reais', () {
      expect(makeBudget(amount: 50000).amountInReais, closeTo(500.0, 0.001));
    });

    test('zero centavos = zero reais', () {
      expect(makeBudget(amount: 0).amountInReais, 0.0);
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('Budget — igualdade', () {
    test('mesmos campos são iguais', () {
      expect(makeBudget(), equals(makeBudget()));
    });

    test('amount diferente → diferentes', () {
      expect(makeBudget(amount: 1000), isNot(equals(makeBudget(amount: 2000))));
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('Budget.copyWith', () {
    test('altera isActive sem alterar outros campos', () {
      final original = makeBudget(isActive: true);
      final copy = original.copyWith(isActive: false);
      expect(copy.isActive, isFalse);
      expect(copy.id, original.id);
      expect(copy.amount, original.amount);
    });
  });

  // ── BudgetPeriod.label ────────────────────────────────────────────────────
  group('BudgetPeriod.label', () {
    test('monthly → Mensal', () {
      expect(BudgetPeriod.monthly.label, 'Mensal');
    });

    test('weekly → Semanal', () {
      expect(BudgetPeriod.weekly.label, 'Semanal');
    });

    test('yearly → Anual', () {
      expect(BudgetPeriod.yearly.label, 'Anual');
    });

    test('custom → Personalizado', () {
      expect(BudgetPeriod.custom.label, 'Personalizado');
    });
  });

  // ── Defaults ─────────────────────────────────────────────────────────────
  group('Budget — valores padrão', () {
    test('alertThreshold padrão é 0.8', () {
      expect(makeBudget().alertThreshold, 0.8);
    });

    test('isActive padrão é true', () {
      expect(makeBudget().isActive, isTrue);
    });
  });
}
