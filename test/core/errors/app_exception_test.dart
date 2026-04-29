// test/core/errors/app_exception_test.dart

import 'package:controle_financeiro/core/errors/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── AppException hierarchy ─────────────────────────────────────────────────
  group('AppException — hierarquia e tipos', () {
    test('AuthException é AppException e Exception', () {
      const e = AuthException('token expirado');
      expect(e, isA<AppException>());
      expect(e, isA<Exception>());
      expect(e.message, 'token expirado');
    });

    test('NetworkException mensagem padrão', () {
      const e = NetworkException();
      expect(e.message, 'Sem conexão com a internet.');
    });

    test('UnexpectedException mensagem padrão', () {
      const e = UnexpectedException();
      expect(e.message, 'Ocorreu um erro inesperado.');
    });

    test('CancelledException mensagem padrão', () {
      const e = CancelledException();
      expect(e.message, 'Operação cancelada.');
    });

    test('NotFoundException preserva mensagem', () {
      const e = NotFoundException('usuário não encontrado');
      expect(e.message, 'usuário não encontrado');
    });

    test('ValidationException preserva mensagem', () {
      const e = ValidationException('campo obrigatório');
      expect(e.message, 'campo obrigatório');
    });

    test('ConflictException preserva mensagem', () {
      const e = ConflictException('nome já existe');
      expect(e.message, 'nome já existe');
    });

    test('StorageException preserva mensagem', () {
      const e = StorageException('upload falhou');
      expect(e.message, 'upload falhou');
    });
  });

  // ── toString ──────────────────────────────────────────────────────────────
  group('AppException.toString', () {
    test('inclui runtimeType e mensagem', () {
      const e = AuthException('sessão inválida');
      expect(e.toString(), 'AuthException: sessão inválida');
    });

    test('NetworkException toString', () {
      const e = NetworkException('offline');
      expect(e.toString(), 'NetworkException: offline');
    });
  });

  // ── pode ser capturada como Exception ────────────────────────────────────
  group('AppException — pode ser capturada', () {
    test('AuthException é capturada pelo tipo AppException', () {
      expect(
        () => throw const AuthException('teste'),
        throwsA(isA<AppException>()),
      );
    });

    test('NetworkException é capturada pelo tipo Exception', () {
      expect(
        () => throw const NetworkException(),
        throwsA(isA<Exception>()),
      );
    });

    test('CancelledException é capturada pelo tipo AppException', () {
      expect(
        () => throw const CancelledException(),
        throwsA(isA<AppException>()),
      );
    });
  });
}
