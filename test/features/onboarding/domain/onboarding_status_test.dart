// test/features/onboarding/domain/onboarding_status_test.dart

import 'package:controle_financeiro/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 1, 1);

  OnboardingStatus makeStatus({
    String userId = 'user-1',
    bool isCompleted = false,
    DateTime? completedAt,
    String preferredCurrency = 'BRL',
    String? displayName,
  }) {
    return OnboardingStatus(
      userId: userId,
      isCompleted: isCompleted,
      completedAt: completedAt,
      preferredCurrency: preferredCurrency,
      displayName: displayName,
    );
  }

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('OnboardingStatus — igualdade (Equatable)', () {
    test('mesmos campos são iguais', () {
      expect(makeStatus(), equals(makeStatus()));
    });

    test('userId diferente → diferentes', () {
      expect(
        makeStatus(userId: 'u1'),
        isNot(equals(makeStatus(userId: 'u2'))),
      );
    });

    test('isCompleted diferente → diferentes', () {
      expect(
        makeStatus(isCompleted: true),
        isNot(equals(makeStatus(isCompleted: false))),
      );
    });

    test('completedAt diferente → diferentes', () {
      expect(
        makeStatus(completedAt: DateTime(2026, 1, 1)),
        isNot(equals(makeStatus(completedAt: DateTime(2026, 2, 1)))),
      );
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('OnboardingStatus.copyWith', () {
    test('altera isCompleted e mantém demais campos', () {
      final original = makeStatus(isCompleted: false);
      final copy = original.copyWith(isCompleted: true);
      expect(copy.isCompleted, true);
      expect(copy.userId, original.userId);
      expect(copy.preferredCurrency, original.preferredCurrency);
    });

    test('sem argumentos retorna objeto equivalente', () {
      expect(makeStatus().copyWith(), equals(makeStatus()));
    });

    test('altera preferredCurrency', () {
      final copy = makeStatus().copyWith(preferredCurrency: 'USD');
      expect(copy.preferredCurrency, 'USD');
    });

    test('altera completedAt de null para valor', () {
      final copy = makeStatus(completedAt: null).copyWith(
        completedAt: baseDate,
      );
      expect(copy.completedAt, baseDate);
    });

    test('altera displayName', () {
      final copy = makeStatus().copyWith(displayName: 'Marcelo');
      expect(copy.displayName, 'Marcelo');
    });
  });

  // ── campos padrão ─────────────────────────────────────────────────────────
  group('OnboardingStatus — valores padrão', () {
    test('preferredCurrency padrão pode ser definida', () {
      final status = makeStatus(preferredCurrency: 'BRL');
      expect(status.preferredCurrency, 'BRL');
    });

    test('completedAt inicia como null quando não completado', () {
      expect(makeStatus(isCompleted: false).completedAt, isNull);
    });
  });
}
