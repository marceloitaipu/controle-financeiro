// test/core/errors/failure_test.dart

import 'package:controle_financeiro/core/errors/failure.dart';
import 'package:controle_financeiro/core/extensions/failure_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Equatable ─────────────────────────────────────────────────────────────
  group('Failure — igualdade (Equatable)', () {
    test('dois AuthFailure com mesma mensagem são iguais', () {
      const a = AuthFailure('Não autorizado.');
      const b = AuthFailure('Não autorizado.');
      expect(a, equals(b));
    });

    test('AuthFailure e NotFoundFailure com mesma mensagem são diferentes', () {
      const a = AuthFailure('msg');
      const b = NotFoundFailure('msg');
      expect(a, isNot(equals(b)));
    });

    test('AuthFailure com mensagens diferentes são diferentes', () {
      const a = AuthFailure('msg1');
      const b = AuthFailure('msg2');
      expect(a, isNot(equals(b)));
    });
  });

  // ── toString ─────────────────────────────────────────────────────────────
  group('Failure.toString', () {
    test('inclui nome do tipo e mensagem', () {
      const f = NetworkFailure();
      expect(f.toString(), contains('NetworkFailure'));
      expect(f.toString(), contains('Sem conexão'));
    });
  });

  // ── Defaults ─────────────────────────────────────────────────────────────
  group('Failures com mensagem padrão', () {
    test('NetworkFailure tem mensagem padrão', () {
      const f = NetworkFailure();
      expect(f.message, isNotEmpty);
    });

    test('UnexpectedFailure tem mensagem padrão', () {
      const f = UnexpectedFailure();
      expect(f.message, isNotEmpty);
    });

    test('CancelledFailure tem mensagem padrão', () {
      const f = CancelledFailure();
      expect(f.message, isNotEmpty);
    });
  });

  // ── FailureX.isSilent ─────────────────────────────────────────────────────
  group('FailureX.isSilent', () {
    test('CancelledFailure é silenciosa', () {
      const f = CancelledFailure();
      expect(f.isSilent, isTrue);
    });

    test('AuthFailure não é silenciosa', () {
      const f = AuthFailure('msg');
      expect(f.isSilent, isFalse);
    });

    test('NetworkFailure não é silenciosa', () {
      const f = NetworkFailure();
      expect(f.isSilent, isFalse);
    });

    test('UnexpectedFailure não é silenciosa', () {
      const f = UnexpectedFailure();
      expect(f.isSilent, isFalse);
    });
  });

  // ── FailureX.userMessage ──────────────────────────────────────────────────
  group('FailureX.userMessage', () {
    test('CancelledFailure retorna string vazia', () {
      const f = CancelledFailure();
      expect(f.userMessage, isEmpty);
    });

    test('NetworkFailure retorna mensagem de rede', () {
      const f = NetworkFailure();
      expect(f.userMessage.toLowerCase(), contains('internet'));
    });

    test('StorageFailure retorna mensagem de arquivo', () {
      const f = StorageFailure('detalhe interno');
      expect(f.userMessage.toLowerCase(), contains('arquivo'));
    });

    test('UnexpectedFailure retorna mensagem genérica', () {
      const f = UnexpectedFailure();
      expect(f.userMessage.toLowerCase(), contains('erro'));
    });

    test('AuthFailure retorna a mensagem do domínio', () {
      const f = AuthFailure('Credenciais inválidas.');
      expect(f.userMessage, 'Credenciais inválidas.');
    });

    test('NotFoundFailure retorna a mensagem do domínio', () {
      const f = NotFoundFailure('Registro não encontrado.');
      expect(f.userMessage, 'Registro não encontrado.');
    });

    test('ValidationFailure retorna a mensagem do domínio', () {
      const f = ValidationFailure('Campo inválido.');
      expect(f.userMessage, 'Campo inválido.');
    });

    test('ConflictFailure retorna a mensagem do domínio', () {
      const f = ConflictFailure('Já existe.');
      expect(f.userMessage, 'Já existe.');
    });
  });

  // ── Todos os subtipos instanciam corretamente ─────────────────────────────
  group('Failure — instanciação de todos os subtipos', () {
    test('AuthFailure', () => expect(const AuthFailure('x'), isA<Failure>()));
    test('NotFoundFailure', () => expect(const NotFoundFailure('x'), isA<Failure>()));
    test('NetworkFailure', () => expect(const NetworkFailure(), isA<Failure>()));
    test('ValidationFailure', () => expect(const ValidationFailure('x'), isA<Failure>()));
    test('ConflictFailure', () => expect(const ConflictFailure('x'), isA<Failure>()));
    test('StorageFailure', () => expect(const StorageFailure('x'), isA<Failure>()));
    test('UnexpectedFailure', () => expect(const UnexpectedFailure(), isA<Failure>()));
    test('CancelledFailure', () => expect(const CancelledFailure(), isA<Failure>()));
  });
}
