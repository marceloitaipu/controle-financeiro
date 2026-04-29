// test/features/credit_cards/domain/credit_card_entity_test.dart

import 'package:controle_financeiro/features/credit_cards/domain/entities/credit_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 1, 1);

  CreditCard makeCard({
    String id = 'card-1',
    String userId = 'user-1',
    String name = 'Meu Cartão',
    CardBrand brand = CardBrand.visa,
    String lastFourDigits = '1234',
    int creditLimit = 500000, // R$ 5.000,00
    int closingDay = 15,
    int dueDay = 22,
    String colorHex = '#1565C0',
    bool isActive = true,
    DateTime? createdAt,
  }) {
    return CreditCard(
      id: id,
      userId: userId,
      name: name,
      brand: brand,
      lastFourDigits: lastFourDigits,
      creditLimit: creditLimit,
      closingDay: closingDay,
      dueDay: dueDay,
      colorHex: colorHex,
      isActive: isActive,
      createdAt: createdAt ?? baseDate,
    );
  }

  // ── creditLimitInReais ────────────────────────────────────────────────────
  group('CreditCard.creditLimitInReais', () {
    test('converte centavos para reais corretamente', () {
      expect(makeCard(creditLimit: 500000).creditLimitInReais, 5000.0);
    });

    test('1 centavo → R\$ 0,01', () {
      expect(makeCard(creditLimit: 1).creditLimitInReais, closeTo(0.01, 0.001));
    });

    test('0 centavos → R\$ 0,00', () {
      expect(makeCard(creditLimit: 0).creditLimitInReais, 0.0);
    });

    test('100 centavos → R\$ 1,00', () {
      expect(makeCard(creditLimit: 100).creditLimitInReais, 1.0);
    });
  });

  // ── CardBrand.label ───────────────────────────────────────────────────────
  group('CardBrand.label', () {
    test('visa retorna "Visa"', () {
      expect(CardBrand.visa.label, 'Visa');
    });

    test('mastercard retorna "Mastercard"', () {
      expect(CardBrand.mastercard.label, 'Mastercard');
    });

    test('elo retorna "Elo"', () {
      expect(CardBrand.elo.label, 'Elo');
    });

    test('amex retorna "American Express"', () {
      expect(CardBrand.amex.label, 'American Express');
    });

    test('hipercard retorna "Hipercard"', () {
      expect(CardBrand.hipercard.label, 'Hipercard');
    });

    test('other retorna "Outra"', () {
      expect(CardBrand.other.label, 'Outra');
    });

    test('todos os valores têm label', () {
      for (final brand in CardBrand.values) {
        expect(brand.label, isNotEmpty);
      }
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('CreditCard — igualdade (Equatable)', () {
    test('mesmos campos são iguais', () {
      expect(makeCard(), equals(makeCard()));
    });

    test('id diferente → diferentes', () {
      expect(makeCard(id: 'c1'), isNot(equals(makeCard(id: 'c2'))));
    });

    test('brand diferente → diferentes', () {
      expect(
        makeCard(brand: CardBrand.visa),
        isNot(equals(makeCard(brand: CardBrand.elo))),
      );
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('CreditCard.copyWith', () {
    test('altera creditLimit e mantém demais campos', () {
      final original = makeCard();
      final copy = original.copyWith(creditLimit: 1000000);
      expect(copy.creditLimit, 1000000);
      expect(copy.id, original.id);
      expect(copy.brand, original.brand);
    });

    test('sem argumentos retorna objeto equivalente', () {
      expect(makeCard().copyWith(), equals(makeCard()));
    });

    test('altera isActive', () {
      final copy = makeCard(isActive: true).copyWith(isActive: false);
      expect(copy.isActive, false);
    });

    test('altera lastFourDigits', () {
      final copy = makeCard().copyWith(lastFourDigits: '9999');
      expect(copy.lastFourDigits, '9999');
    });
  });
}
