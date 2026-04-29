// test/core/extensions/string_extensions_test.dart

import 'package:controle_financeiro/core/extensions/string_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── nullIfEmpty ───────────────────────────────────────────────────────────
  group('StringExtensions.nullIfEmpty', () {
    test('string não vazia retorna ela mesma', () {
      expect('hello'.nullIfEmpty, 'hello');
    });

    test('string vazia retorna null', () {
      expect(''.nullIfEmpty, isNull);
    });
  });

  // ── capitalize ────────────────────────────────────────────────────────────
  group('StringExtensions.capitalize', () {
    test('primeira letra maiúscula, resto minúsculo', () {
      expect('hello'.capitalize, 'Hello');
      expect('WORLD'.capitalize, 'World');
    });

    test('string vazia retorna vazia', () {
      expect(''.capitalize, '');
    });

    test('uma letra é capitalizada', () {
      expect('a'.capitalize, 'A');
    });
  });

  // ── titleCase ─────────────────────────────────────────────────────────────
  group('StringExtensions.titleCase', () {
    test('capitaliza cada palavra', () {
      expect('hello world'.titleCase, 'Hello World');
    });

    test('string com uma palavra', () {
      expect('flutter'.titleCase, 'Flutter');
    });

    test('string vazia retorna vazia', () {
      expect(''.titleCase, '');
    });
  });

  // ── onlyNumbers ──────────────────────────────────────────────────────────
  group('StringExtensions.onlyNumbers', () {
    test('remove letras e pontuação', () {
      expect('abc123def456'.onlyNumbers, '123456');
    });

    test('string só com números retorna mesma', () {
      expect('12345'.onlyNumbers, '12345');
    });

    test('string sem números retorna vazia', () {
      expect('abcdef'.onlyNumbers, '');
    });

    test('formatos de moeda ficam só com dígitos', () {
      expect('R\$ 1.234,56'.onlyNumbers, '123456');
    });
  });

  // ── isValidEmail ─────────────────────────────────────────────────────────
  group('StringExtensions.isValidEmail', () {
    test('e-mail válido retorna true', () {
      expect('user@example.com'.isValidEmail, isTrue);
    });

    test('e-mail sem @ retorna false', () {
      expect('invalidemail'.isValidEmail, isFalse);
    });

    test('e-mail sem domínio retorna false', () {
      expect('user@'.isValidEmail, isFalse);
    });
  });

  // ── isStrongPassword ─────────────────────────────────────────────────────
  group('StringExtensions.isStrongPassword', () {
    test('senha forte retorna true', () {
      expect('Senha123'.isStrongPassword, isTrue);
    });

    test('senha curta retorna false', () {
      expect('abc1'.isStrongPassword, isFalse);
    });

    test('senha só com letras retorna false', () {
      expect('abcdefgh'.isStrongPassword, isFalse);
    });

    test('senha só com números retorna false', () {
      expect('12345678'.isStrongPassword, isFalse);
    });
  });

  // ── truncate ─────────────────────────────────────────────────────────────
  group('StringExtensions.truncate', () {
    test('string menor que maxLength não é truncada', () {
      expect('hello'.truncate(10), 'hello');
    });

    test('string igual a maxLength não é truncada', () {
      expect('hello'.truncate(5), 'hello');
    });

    test('string maior é truncada com reticências', () {
      final result = 'hello world'.truncate(5);
      expect(result.length, lessThanOrEqualTo(6)); // 5 + reticências
      expect(result, contains('…'));
    });
  });

  // ── NullableStringExtensions ─────────────────────────────────────────────
  group('NullableStringExtensions', () {
    test('isNullOrEmpty é true para null', () {
      String? s;
      expect(s.isNullOrEmpty, isTrue);
    });

    test('isNullOrEmpty é true para string vazia', () {
      const String s = '';
      expect(s.isNullOrEmpty, isTrue);
    });

    test('isNullOrEmpty é false para string com conteúdo', () {
      const String s = 'hello';
      expect(s.isNullOrEmpty, isFalse);
    });

    test('orDefault retorna fallback para null', () {
      String? s;
      expect(s.orDefault('fallback'), 'fallback');
    });

    test('orDefault retorna a própria string quando não vazia', () {
      const String s = 'value';
      expect(s.orDefault('fallback'), 'value');
    });
  });
}
