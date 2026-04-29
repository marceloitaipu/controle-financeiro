// test/features/credit_cards/domain/invoice_entity_test.dart

import 'package:controle_financeiro/features/credit_cards/domain/entities/invoice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 1, 1);

  Invoice makeInvoice({
    String id = 'inv-1',
    String userId = 'user-1',
    String creditCardId = 'card-1',
    String yearMonth = '2026-04',
    int totalAmount = 25000, // R$ 250,00
    InvoiceStatus status = InvoiceStatus.open,
    DateTime? closingDate,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Invoice(
      id: id,
      userId: userId,
      creditCardId: creditCardId,
      yearMonth: yearMonth,
      closingDate: closingDate ?? DateTime(2026, 4, 15),
      dueDate: dueDate ?? DateTime(2026, 4, 22),
      totalAmount: totalAmount,
      status: status,
      createdAt: createdAt ?? baseDate,
    );
  }

  // ── totalAmountInReais ────────────────────────────────────────────────────
  group('Invoice.totalAmountInReais', () {
    test('converte centavos para reais corretamente', () {
      expect(makeInvoice(totalAmount: 25000).totalAmountInReais, 250.0);
    });

    test('1 centavo → R\$ 0,01', () {
      expect(
        makeInvoice(totalAmount: 1).totalAmountInReais,
        closeTo(0.01, 0.001),
      );
    });

    test('0 centavos → R\$ 0,00', () {
      expect(makeInvoice(totalAmount: 0).totalAmountInReais, 0.0);
    });

    test('valor alto — R\$ 10.000,00', () {
      expect(makeInvoice(totalAmount: 1000000).totalAmountInReais, 10000.0);
    });
  });

  // ── InvoiceStatus.label ───────────────────────────────────────────────────
  group('InvoiceStatus.label', () {
    test('open retorna "Aberta"', () {
      expect(InvoiceStatus.open.label, 'Aberta');
    });

    test('closed retorna "Fechada"', () {
      expect(InvoiceStatus.closed.label, 'Fechada');
    });

    test('paid retorna "Paga"', () {
      expect(InvoiceStatus.paid.label, 'Paga');
    });

    test('todos os valores têm label', () {
      for (final status in InvoiceStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('Invoice — igualdade (Equatable)', () {
    test('mesmos campos são iguais', () {
      expect(makeInvoice(), equals(makeInvoice()));
    });

    test('id diferente → diferentes', () {
      expect(makeInvoice(id: 'i1'), isNot(equals(makeInvoice(id: 'i2'))));
    });

    test('status diferente → diferentes', () {
      expect(
        makeInvoice(status: InvoiceStatus.open),
        isNot(equals(makeInvoice(status: InvoiceStatus.paid))),
      );
    });

    test('yearMonth diferente → diferentes', () {
      expect(
        makeInvoice(yearMonth: '2026-03'),
        isNot(equals(makeInvoice(yearMonth: '2026-04'))),
      );
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('Invoice.copyWith', () {
    test('altera status e mantém demais campos', () {
      final original = makeInvoice(status: InvoiceStatus.open);
      final copy = original.copyWith(status: InvoiceStatus.paid);
      expect(copy.status, InvoiceStatus.paid);
      expect(copy.id, original.id);
      expect(copy.totalAmount, original.totalAmount);
    });

    test('sem argumentos retorna objeto equivalente', () {
      expect(makeInvoice().copyWith(), equals(makeInvoice()));
    });

    test('altera totalAmount', () {
      final copy = makeInvoice().copyWith(totalAmount: 99900);
      expect(copy.totalAmount, 99900);
    });
  });
}
