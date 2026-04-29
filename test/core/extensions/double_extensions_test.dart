// test/core/extensions/double_extensions_test.dart

import 'package:controle_financeiro/core/extensions/double_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── toBRL ─────────────────────────────────────────────────────────────────
  group('DoubleExtensions.toBRL', () {
    test('formata valor em BRL', () {
      expect((1234.56).toBRL, contains('1.234,56'));
    });

    test('inclui símbolo R\$', () {
      expect((100.0).toBRL, contains('R\$'));
    });

    test('zero formatado', () {
      expect((0.0).toBRL, contains('0,00'));
    });
  });

  // ── toBRLNoSymbol ─────────────────────────────────────────────────────────
  group('DoubleExtensions.toBRLNoSymbol', () {
    test('não contém símbolo R\$', () {
      expect((1234.56).toBRLNoSymbol, isNot(contains('R\$')));
    });

    test('mantém formatação numérica', () {
      expect((1234.56).toBRLNoSymbol, contains('1.234,56'));
    });
  });

  // ── toCompact ─────────────────────────────────────────────────────────────
  group('DoubleExtensions.toCompact', () {
    test('valor < 1000 retorna sem sufixo', () {
      final result = (999.0).toCompact;
      expect(result, isNot(contains('K')));
      expect(result, isNot(contains('M')));
    });

    test('valor >= 1000 retorna com K', () {
      expect((1500.0).toCompact, contains('K'));
    });

    test('valor >= 1.000.000 retorna com M', () {
      expect((1500000.0).toCompact, contains('M'));
    });
  });

  // ── toPercent ─────────────────────────────────────────────────────────────
  group('DoubleExtensions.toPercent', () {
    test('formata porcentagem', () {
      final result = (73.5).toPercent;
      expect(result, contains('%'));
    });

    test('valor zero formatado', () {
      expect((0.0).toPercent, contains('%'));
    });
  });

  // ── isPositive / isNegative / isZero ─────────────────────────────────────
  group('DoubleExtensions — comparações', () {
    test('isPositive é true para > 0', () {
      expect((1.0).isPositive, isTrue);
    });

    test('isPositive é false para 0', () {
      expect((0.0).isPositive, isFalse);
    });

    test('isNegative é true para < 0', () {
      expect((-1.0).isNegative, isTrue);
    });

    test('isZero é true para 0', () {
      expect((0.0).isZero, isTrue);
    });
  });

  // ── rounded ──────────────────────────────────────────────────────────────
  group('DoubleExtensions.rounded', () {
    test('arredonda para 2 casas decimais', () {
      expect((1.2345).rounded, 1.23);
    });

    test('valor exato não é alterado', () {
      expect((10.50).rounded, 10.50);
    });
  });

  // ── NullableDoubleExtensions ──────────────────────────────────────────────
  group('NullableDoubleExtensions', () {
    test('null retorna R\$ 0,00', () {
      double? d;
      expect(d.toBRLOrZero, contains('0,00'));
    });

    test('orZero retorna 0.0 para null', () {
      double? d;
      expect(d.orZero, 0.0);
    });

    test('orZero retorna o próprio valor quando não null', () {
      const double d = 5.5;
      expect(d.orZero, 5.5);
    });
  });
}
