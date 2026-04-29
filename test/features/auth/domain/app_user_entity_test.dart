// test/features/auth/domain/app_user_entity_test.dart

import 'package:controle_financeiro/features/auth/domain/entities/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 4, 1);

  AppUser makeUser({
    String id = 'user-1',
    String email = 'joao@example.com',
    String? displayName = 'João Silva',
    String? photoUrl,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: baseDate,
    );
  }

  // ── initials ──────────────────────────────────────────────────────────────
  group('AppUser.initials', () {
    test('duas iniciais do displayName quando tem nome e sobrenome', () {
      expect(makeUser(displayName: 'João Silva').initials, 'JS');
    });

    test('primeiras 2 letras do primeiro nome quando nome único', () {
      expect(makeUser(displayName: 'João').initials, 'JO');
    });

    test('usa email quando displayName é null', () {
      expect(makeUser(displayName: null, email: 'ab@test.com').initials, 'AB');
    });

    test('usa email quando displayName é vazio', () {
      expect(makeUser(displayName: '', email: 'xy@test.com').initials, 'XY');
    });

    test('não lança para email com 1 caractere antes do @', () {
      expect(
        () => makeUser(displayName: null, email: 'a@b.com').initials,
        returnsNormally,
      );
    });

    test('não lança para nome com 1 caractere', () {
      expect(
        () => makeUser(displayName: 'J').initials,
        returnsNormally,
      );
      expect(makeUser(displayName: 'J').initials, 'J');
    });

    test('retorna em maiúsculas', () {
      expect(makeUser(displayName: 'ana maria').initials, 'AM');
    });

    test('ignora espaços extras nas extremidades', () {
      expect(makeUser(displayName: '  João  Silva  ').initials, 'JS');
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('AppUser — igualdade (Equatable)', () {
    test('mesmos campos são iguais', () {
      expect(makeUser(), equals(makeUser()));
    });

    test('id diferente → diferentes', () {
      expect(makeUser(id: 'u1'), isNot(equals(makeUser(id: 'u2'))));
    });

    test('email diferente → diferentes', () {
      expect(
        makeUser(email: 'a@a.com'),
        isNot(equals(makeUser(email: 'b@b.com'))),
      );
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('AppUser.copyWith', () {
    test('altera displayName e mantém demais campos', () {
      final original = makeUser();
      final copy = original.copyWith(displayName: 'Carlos');
      expect(copy.displayName, 'Carlos');
      expect(copy.id, original.id);
      expect(copy.email, original.email);
    });

    test('sem argumentos retorna objeto equivalente', () {
      final original = makeUser();
      expect(original.copyWith(), equals(original));
    });

    test('altera email', () {
      final copy = makeUser().copyWith(email: 'novo@email.com');
      expect(copy.email, 'novo@email.com');
    });

    test('altera photoUrl de null para valor', () {
      final copy = makeUser(photoUrl: null).copyWith(photoUrl: 'https://img.png');
      expect(copy.photoUrl, 'https://img.png');
    });
  });

  // ── props ─────────────────────────────────────────────────────────────────
  group('AppUser — props', () {
    test('props inclui todos os campos relevantes', () {
      final user = makeUser();
      expect(user.props, hasLength(7));
    });

    test('photoUrl null é diferente de photoUrl preenchida', () {
      final a = makeUser(photoUrl: null);
      final b = makeUser(photoUrl: 'https://img.png');
      expect(a, isNot(equals(b)));
    });
  });
}
