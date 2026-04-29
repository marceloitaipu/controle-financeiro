// test/features/transactions/domain/transaction_entity_test.dart

import 'package:controle_financeiro/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 4, 23);

  Transaction makeTransaction({
    TransactionType type = TransactionType.expense,
    int amount = 5000,
    TransactionStatus status = TransactionStatus.completed,
    RecurrenceType recurrence = RecurrenceType.none,
    bool isInstallment = false,
  }) {
    return Transaction(
      id: 'tx-1',
      userId: 'user-1',
      type: type,
      amount: amount,
      date: baseDate,
      description: 'Teste',
      accountId: 'acc-1',
      status: status,
      recurrence: recurrence,
      isInstallment: isInstallment,
      createdAt: baseDate,
    );
  }

  // ── amountInReais ─────────────────────────────────────────────────────────
  group('Transaction.amountInReais', () {
    test('converte centavos para reais corretamente', () {
      final t = makeTransaction(amount: 123456);
      expect(t.amountInReais, closeTo(1234.56, 0.001));
    });

    test('zero centavos = zero reais', () {
      final t = makeTransaction(amount: 0);
      expect(t.amountInReais, 0.0);
    });

    test('1 centavo = 0.01 reais', () {
      final t = makeTransaction(amount: 1);
      expect(t.amountInReais, closeTo(0.01, 0.0001));
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('Transaction — igualdade (Equatable)', () {
    test('dois objetos com mesmos campos são iguais', () {
      final a = makeTransaction();
      final b = makeTransaction();
      expect(a, equals(b));
    });

    test('objetos com amount diferente são diferentes', () {
      final a = makeTransaction(amount: 1000);
      final b = makeTransaction(amount: 2000);
      expect(a, isNot(equals(b)));
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('Transaction.copyWith', () {
    test('altera apenas o campo especificado', () {
      final original = makeTransaction(amount: 1000);
      final copy = original.copyWith(amount: 9999);
      expect(copy.amount, 9999);
      expect(copy.id, original.id);
      expect(copy.description, original.description);
    });

    test('sem argumentos retorna objeto equivalente', () {
      final original = makeTransaction();
      final copy = original.copyWith();
      expect(copy, equals(original));
    });
  });

  // ── Enums labels ─────────────────────────────────────────────────────────
  group('TransactionType.label', () {
    test('income → Receita', () {
      expect(TransactionType.income.label, 'Receita');
    });

    test('expense → Despesa', () {
      expect(TransactionType.expense.label, 'Despesa');
    });

    test('transfer → Transferência', () {
      expect(TransactionType.transfer.label, 'Transferência');
    });
  });

  group('TransactionStatus.label', () {
    test('pending → Pendente', () {
      expect(TransactionStatus.pending.label, 'Pendente');
    });

    test('completed → Concluída', () {
      expect(TransactionStatus.completed.label, 'Concluída');
    });

    test('cancelled → Cancelada', () {
      expect(TransactionStatus.cancelled.label, 'Cancelada');
    });
  });

  group('RecurrenceType.label', () {
    test('none → Não repete', () {
      expect(RecurrenceType.none.label, 'Não repete');
    });

    test('daily → Diário', () {
      expect(RecurrenceType.daily.label, 'Diário');
    });

    test('weekly → Semanal', () {
      expect(RecurrenceType.weekly.label, 'Semanal');
    });

    test('monthly → Mensal', () {
      expect(RecurrenceType.monthly.label, 'Mensal');
    });

    test('yearly → Anual', () {
      expect(RecurrenceType.yearly.label, 'Anual');
    });
  });

  // ── Defaults ─────────────────────────────────────────────────────────────
  group('Transaction — valores padrão', () {
    test('status padrão é completed', () {
      final t = makeTransaction();
      expect(t.status, TransactionStatus.completed);
    });

    test('recurrence padrão é none', () {
      final t = makeTransaction();
      expect(t.recurrence, RecurrenceType.none);
    });

    test('isInstallment padrão é false', () {
      final t = makeTransaction();
      expect(t.isInstallment, isFalse);
    });

    test('attachmentUrls padrão é lista vazia', () {
      final t = makeTransaction();
      expect(t.attachmentUrls, isEmpty);
    });
  });
}
