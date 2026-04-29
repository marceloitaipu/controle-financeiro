// test/features/accounts/domain/account_entity_test.dart

import 'package:controle_financeiro/features/accounts/domain/entities/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 4, 23);

  Account makeAccount({
    int balance = 100000,
    AccountType type = AccountType.checking,
    bool includeInTotal = true,
  }) {
    return Account(
      id: 'acc-1',
      userId: 'user-1',
      name: 'Conta Corrente',
      type: type,
      balance: balance,
      colorHex: '#2196F3',
      iconCodePoint: 0xe0c5,
      iconFontFamily: 'MaterialIcons',
      includeInTotal: includeInTotal,
      createdAt: baseDate,
    );
  }

  // ── balanceInReais ────────────────────────────────────────────────────────
  group('Account.balanceInReais', () {
    test('converte centavos para reais', () {
      expect(makeAccount(balance: 100000).balanceInReais, closeTo(1000.0, 0.001));
    });

    test('saldo zero', () {
      expect(makeAccount(balance: 0).balanceInReais, 0.0);
    });

    test('saldo negativo', () {
      expect(makeAccount(balance: -5000).balanceInReais, closeTo(-50.0, 0.001));
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('Account — igualdade', () {
    test('mesmos campos são iguais', () {
      expect(makeAccount(), equals(makeAccount()));
    });

    test('balance diferente → diferentes', () {
      expect(makeAccount(balance: 1000), isNot(equals(makeAccount(balance: 2000))));
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('Account.copyWith', () {
    test('altera apenas o campo especificado', () {
      final original = makeAccount(balance: 5000);
      final copy = original.copyWith(balance: 9999);
      expect(copy.balance, 9999);
      expect(copy.id, original.id);
      expect(copy.name, original.name);
    });
  });

  // ── Enum labels ──────────────────────────────────────────────────────────
  group('AccountType.label', () {
    test('checking → Conta Corrente', () {
      expect(AccountType.checking.label, 'Conta Corrente');
    });

    test('savings → Poupança', () {
      expect(AccountType.savings.label, 'Poupança');
    });

    test('wallet → Carteira', () {
      expect(AccountType.wallet.label, 'Carteira');
    });

    test('investment → Investimento', () {
      expect(AccountType.investment.label, 'Investimento');
    });

    test('other → Outro', () {
      expect(AccountType.other.label, 'Outro');
    });
  });

  group('AccountType.iconName', () {
    test('todos os tipos têm iconName não vazio', () {
      for (final type in AccountType.values) {
        expect(type.iconName, isNotEmpty);
      }
    });
  });
}
