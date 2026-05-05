// test/features/budgets/presentation/budget_progress_test.dart

import 'package:controle_financeiro/features/budgets/domain/entities/budget.dart';
import 'package:controle_financeiro/features/budgets/presentation/providers/budget_providers.dart';
import 'package:flutter_test/flutter_test.dart';

Budget makeBudget({
  int amount = 100000, // R$ 1000,00
  BudgetPeriod period = BudgetPeriod.monthly,
  double alertThreshold = 0.8,
  DateTime? startDate,
}) {
  final base = DateTime(2026, 5, 1);
  return Budget(
    id: 'b-1',
    userId: 'u-1',
    categoryId: 'cat-1',
    amount: amount,
    period: period,
    alertThreshold: alertThreshold,
    startDate: startDate ?? base,
    createdAt: base,
  );
}

BudgetProgress makeProgress(int spentAmount, {int budgetAmount = 100000}) =>
    BudgetProgress(budget: makeBudget(amount: budgetAmount), spentAmount: spentAmount);

void main() {
  // ── BudgetProgress.percentage ──────────────────────────────────────────────
  group('BudgetProgress.percentage', () {
    test('50% de R\$1000 gasto', () {
      expect(makeProgress(50000).percentage, closeTo(0.5, 0.001));
    });

    test('100% exato', () {
      expect(makeProgress(100000).percentage, 1.0);
    });

    test('ultrapassa 1.0 quando estourado', () {
      expect(makeProgress(120000).percentage, closeTo(1.2, 0.001));
    });

    test('0% quando nada gasto', () {
      expect(makeProgress(0).percentage, 0.0);
    });

    test('budget zero retorna 0 sem divisão por zero', () {
      expect(makeProgress(0, budgetAmount: 0).percentage, 0.0);
    });
  });

  // ── BudgetProgress.remaining ───────────────────────────────────────────────
  group('BudgetProgress.remaining', () {
    test('retorna diferença positiva quando dentro do orçamento', () {
      expect(makeProgress(30000).remaining, 70000);
    });

    test('retorna zero quando exatamente no limite', () {
      expect(makeProgress(100000).remaining, 0);
    });

    test('retorna valor negativo quando estourado', () {
      expect(makeProgress(110000).remaining, -10000);
    });
  });

  // ── BudgetProgress.isAlert ─────────────────────────────────────────────────
  group('BudgetProgress.isAlert', () {
    test('false quando abaixo do limiar', () {
      // threshold 0.8, spent 79% → não alerta
      expect(makeProgress(79000).isAlert, isFalse);
    });

    test('true exatamente no limiar', () {
      expect(makeProgress(80000).isAlert, isTrue);
    });

    test('true quando estourado', () {
      expect(makeProgress(120000).isAlert, isTrue);
    });
  });

  // ── BudgetProgress.isOverBudget ────────────────────────────────────────────
  group('BudgetProgress.isOverBudget', () {
    test('false quando dentro do orçamento', () {
      expect(makeProgress(99999).isOverBudget, isFalse);
    });

    test('false quando exatamente no limite', () {
      expect(makeProgress(100000).isOverBudget, isFalse);
    });

    test('true quando ultrapassa', () {
      expect(makeProgress(100001).isOverBudget, isTrue);
    });
  });

  // ── budgetDateRange ────────────────────────────────────────────────────────
  group('budgetDateRange', () {
    final month = DateTime(2026, 5, 15);

    test('monthly: começa em 01/05 e termina no último segundo de 31/05', () {
      final b = makeBudget(period: BudgetPeriod.monthly);
      final (start, end) = budgetDateRange(b, month);
      expect(start, DateTime(2026, 5, 1));
      expect(end, DateTime(2026, 5, 31, 23, 59, 59));
    });

    test('yearly: cobre de 01/01 ao último segundo de 31/12', () {
      final b = makeBudget(period: BudgetPeriod.yearly);
      final (start, end) = budgetDateRange(b, month);
      expect(start, DateTime(2026, 1, 1));
      expect(end, DateTime(2026, 12, 31, 23, 59, 59));
    });

    test('weekly: começa na segunda-feira da semana de 15/05/2026 (que é sexta)', () {
      // 15/05/2026 é sexta (weekday=5), então segunda é 11/05
      final b = makeBudget(period: BudgetPeriod.weekly);
      final (start, end) = budgetDateRange(b, month);
      expect(start, DateTime(2026, 5, 11));
      expect(end.difference(start).inDays, 6);
    });

    test('custom: usa startDate do budget e fim do mês de referência', () {
      final customStart = DateTime(2026, 4, 10);
      final b = makeBudget(period: BudgetPeriod.custom, startDate: customStart);
      final (start, end) = budgetDateRange(b, month);
      expect(start, customStart);
      expect(end, DateTime(2026, 5, 31, 23, 59, 59));
    });
  });
}
