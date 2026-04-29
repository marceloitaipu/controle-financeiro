// test/core/utils/date_formatter_test.dart

import 'package:controle_financeiro/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('pt_BR'));

  final date = DateTime(2026, 4, 23, 14, 30);

  group('DateFormatter.monthYear', () {
    test('retorna mês por extenso e ano', () {
      final result = DateFormatter.monthYear(date);
      expect(result.toLowerCase(), contains('abril'));
      expect(result, contains('2026'));
    });
  });

  group('DateFormatter.shortMonthYear', () {
    test('retorna formato abreviado mês/ano', () {
      final result = DateFormatter.shortMonthYear(date);
      expect(result, contains('26'));
    });
  });

  group('DateFormatter.shortDate', () {
    test('retorna dd/MM/yyyy', () {
      expect(DateFormatter.shortDate(date), '23/04/2026');
    });
  });

  group('DateFormatter.dayMonth', () {
    test('retorna dia e mês abreviado', () {
      final result = DateFormatter.dayMonth(date);
      expect(result, startsWith('23'));
    });
  });

  group('DateFormatter.fullDate', () {
    test('retorna data completa', () {
      final result = DateFormatter.fullDate(date);
      expect(result, contains('23'));
      expect(result, contains('2026'));
    });
  });

  group('DateFormatter.time', () {
    test('retorna HH:mm', () {
      expect(DateFormatter.time(date), '14:30');
    });
  });

  group('DateFormatter.relative', () {
    test('data de hoje retorna Hoje', () {
      final now = DateTime.now();
      expect(DateFormatter.relative(now), 'Hoje');
    });

    test('data de ontem retorna Ontem', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.relative(yesterday), 'Ontem');
    });

    test('data antiga retorna formato dd/MM/yyyy', () {
      final old = DateTime(2024, 1, 15);
      expect(DateFormatter.relative(old), '15/01/2024');
    });
  });

  group('DateFormatter.relativeWithTime', () {
    test('inclui "às" e o horário', () {
      final now = DateTime.now();
      final result = DateFormatter.relativeWithTime(now);
      expect(result, contains('às'));
    });
  });
}
