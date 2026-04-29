// test/core/extensions/datetime_extensions_test.dart

import 'package:controle_financeiro/core/extensions/datetime_extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('pt_BR'));

  final date = DateTime(2026, 4, 23, 14, 30);

  // ── Formatações ───────────────────────────────────────────────────────────
  group('DateTimeExtensions — formatações', () {
    test('formatted retorna dd/MM/yyyy', () {
      expect(date.formatted, '23/04/2026');
    });

    test('formattedLong contém o mês e o ano', () {
      final result = date.formattedLong;
      expect(result, contains('2026'));
      expect(result, contains('23'));
    });

    test('formattedMonthYear contém o ano', () {
      expect(date.formattedMonthYear, contains('2026'));
    });

    test('formattedMonthYearFull contém mês e ano por extenso', () {
      final result = date.formattedMonthYearFull.toLowerCase();
      expect(result, contains('abril'));
      expect(result, contains('2026'));
    });

    test('formattedShort retorna dd/MM', () {
      expect(date.formattedShort, '23/04');
    });

    test('formattedWithTime contém data e hora', () {
      expect(date.formattedWithTime, '23/04/2026 14:30');
    });

    test('yearMonthKey retorna yyyyMM', () {
      expect(date.yearMonthKey, '202604');
    });
  });

  // ── Comparações ───────────────────────────────────────────────────────────
  group('DateTimeExtensions — comparações', () {
    test('isToday é true para hoje', () {
      expect(DateTime.now().isToday, isTrue);
    });

    test('isToday é false para ontem', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, isFalse);
    });

    test('isYesterday é true para ontem', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isYesterday, isTrue);
    });

    test('isYesterday é false para hoje', () {
      expect(DateTime.now().isYesterday, isFalse);
    });

    test('isThisMonth é true para o mês atual', () {
      expect(DateTime.now().isThisMonth, isTrue);
    });

    test('isThisYear é true para este ano', () {
      expect(DateTime.now().isThisYear, isTrue);
    });

    test('isSameDay é true para mesmo dia', () {
      final a = DateTime(2026, 4, 23, 8, 0);
      final b = DateTime(2026, 4, 23, 22, 59);
      expect(a.isSameDay(b), isTrue);
    });

    test('isSameDay é false para dias diferentes', () {
      final a = DateTime(2026, 4, 23);
      final b = DateTime(2026, 4, 24);
      expect(a.isSameDay(b), isFalse);
    });

    test('isSameMonth é true para mesmo mês', () {
      final a = DateTime(2026, 4, 1);
      final b = DateTime(2026, 4, 30);
      expect(a.isSameMonth(b), isTrue);
    });

    test('isSameMonth é false para meses diferentes', () {
      final a = DateTime(2026, 4, 1);
      final b = DateTime(2026, 5, 1);
      expect(a.isSameMonth(b), isFalse);
    });
  });

  // ── Manipulação ───────────────────────────────────────────────────────────
  group('DateTimeExtensions — manipulação', () {
    test('startOfDay zera horas', () {
      final result = DateTime(2026, 4, 23, 14, 30).startOfDay;
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('endOfDay seta 23:59:59.999', () {
      final result = DateTime(2026, 4, 23).endOfDay;
      expect(result.hour, 23);
      expect(result.minute, 59);
      expect(result.second, 59);
      expect(result.millisecond, 999);
    });

    test('firstDayOfMonth retorna dia 1', () {
      expect(date.firstDayOfMonth.day, 1);
      expect(date.firstDayOfMonth.month, 4);
    });

    test('lastDayOfMonth retorna último dia do mês', () {
      // Abril tem 30 dias
      expect(date.lastDayOfMonth.day, 30);
      // Fevereiro 2028 (bissexto)
      expect(DateTime(2028, 2, 15).lastDayOfMonth.day, 29);
    });

    test('nextMonth avança um mês', () {
      final next = date.nextMonth;
      expect(next.month, 5);
      expect(next.year, 2026);
    });

    test('nextMonth em dezembro avança para janeiro do próximo ano', () {
      final dec = DateTime(2026, 12, 1);
      expect(dec.nextMonth.month, 1);
      expect(dec.nextMonth.year, 2027);
    });

    test('previousMonth recua um mês', () {
      final prev = date.previousMonth;
      expect(prev.month, 3);
      expect(prev.year, 2026);
    });

    test('previousMonth em janeiro recua para dezembro do ano anterior', () {
      final jan = DateTime(2026, 1, 1);
      expect(jan.previousMonth.month, 12);
      expect(jan.previousMonth.year, 2025);
    });

    test('toMillis retorna millisecondsSinceEpoch', () {
      expect(date.toMillis, date.millisecondsSinceEpoch);
    });
  });

  // ── NullableDateTimeExtensions ────────────────────────────────────────────
  group('NullableDateTimeExtensions', () {
    test('null retorna string vazia', () {
      DateTime? d;
      expect(d.formattedOrEmpty, '');
    });

    test('data válida retorna formatted', () {
      final d = DateTime(2026, 4, 23);
      expect(d.formattedOrEmpty, '23/04/2026');
    });
  });
}
