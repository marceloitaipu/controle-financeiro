// test/core/utils/currency_formatter_test.dart

import 'package:controle_financeiro/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formata zero corretamente', () {
      expect(CurrencyFormatter.format(0), 'R\$\u00a00,00');
    });

    test('formata centavos menores que 1 real', () {
      expect(CurrencyFormatter.format(99), 'R\$\u00a00,99');
    });

    test('formata exatamente 1 real', () {
      expect(CurrencyFormatter.format(100), 'R\$\u00a01,00');
    });

    test('formata valor com centavos', () {
      expect(CurrencyFormatter.format(123456), 'R\$\u00a01.234,56');
    });

    test('formata valor grande', () {
      expect(CurrencyFormatter.format(100000000), 'R\$\u00a01.000.000,00');
    });

    test('formata valor negativo', () {
      expect(CurrencyFormatter.format(-5050), '-R\$\u00a050,50');
    });
  });

  group('CurrencyFormatter.formatDouble', () {
    test('formata double com 2 casas', () {
      expect(CurrencyFormatter.formatDouble(1234.56), 'R\$\u00a01.234,56');
    });

    test('formata zero double', () {
      expect(CurrencyFormatter.formatDouble(0.0), 'R\$\u00a00,00');
    });
  });

  group('CurrencyFormatter.formatSigned', () {
    test('valor positivo recebe sinal +', () {
      final result = CurrencyFormatter.formatSigned(5000);
      expect(result.startsWith('+'), isTrue);
    });

    test('valor negativo recebe sinal -', () {
      final result = CurrencyFormatter.formatSigned(-5000);
      expect(result.startsWith('-'), isTrue);
    });

    test('zero recebe sinal +', () {
      final result = CurrencyFormatter.formatSigned(0);
      expect(result.startsWith('+'), isTrue);
    });

    test('o valor absoluto é formatado corretamente', () {
      final result = CurrencyFormatter.formatSigned(-5050);
      expect(result, '-R\$\u00a050,50');
    });
  });

  group('CurrencyFormatter.formatCompact', () {
    test('valor menor que 10.000 é formatado por extenso', () {
      expect(CurrencyFormatter.formatCompact(999900), 'R\$\u00a09.999,00');
    });

    test('valor maior ou igual a 10.000 é compactado', () {
      final result = CurrencyFormatter.formatCompact(1000000); // R$ 10.000
      expect(result, contains('R\$'));
    });

    test('zero é formatado por extenso', () {
      expect(CurrencyFormatter.formatCompact(0), 'R\$\u00a00,00');
    });
  });
}
