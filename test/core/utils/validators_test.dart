// test/core/utils/validators_test.dart

import 'package:controle_financeiro/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── required ─────────────────────────────────────────────────────────────
  group('Validators.required', () {
    final validator = Validators.required('Nome');

    test('retorna null para valor válido', () {
      expect(validator('João'), isNull);
    });

    test('retorna erro para string vazia', () {
      expect(validator(''), isNotNull);
      expect(validator(''), contains('obrigatório'));
    });

    test('retorna erro para string só com espaços', () {
      expect(validator('   '), isNotNull);
    });

    test('retorna erro para null', () {
      expect(validator(null), isNotNull);
    });
  });

  // ── email ─────────────────────────────────────────────────────────────────
  group('Validators.email', () {
    test('aceita e-mail válido', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('aceita e-mail com subdomínio', () {
      expect(Validators.email('user@mail.company.com'), isNull);
    });

    test('rejeita e-mail sem @', () {
      expect(Validators.email('invalidemail.com'), isNotNull);
    });

    test('rejeita e-mail sem domínio', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('rejeita string vazia', () {
      expect(Validators.email(''), isNotNull);
    });

    test('rejeita null', () {
      expect(Validators.email(null), isNotNull);
    });
  });

  // ── password ──────────────────────────────────────────────────────────────
  group('Validators.password', () {
    test('aceita senha válida', () {
      expect(Validators.password('Senha123'), isNull);
    });

    test('rejeita senha curta (< 8 chars)', () {
      expect(Validators.password('abc123'), isNotNull);
    });

    test('rejeita senha só com letras', () {
      expect(Validators.password('senhasemnum'), isNotNull);
    });

    test('rejeita senha só com números', () {
      expect(Validators.password('12345678'), isNotNull);
    });

    test('rejeita vazia', () {
      expect(Validators.password(''), isNotNull);
    });

    test('rejeita null', () {
      expect(Validators.password(null), isNotNull);
    });
  });

  // ── confirmPassword ───────────────────────────────────────────────────────
  group('Validators.confirmPassword', () {
    test('aceita confirmação correta', () {
      final v = Validators.confirmPassword('Senha123');
      expect(v('Senha123'), isNull);
    });

    test('rejeita confirmação diferente', () {
      final v = Validators.confirmPassword('Senha123');
      expect(v('Senha999'), isNotNull);
      expect(v('Senha999'), contains('coincidem'));
    });

    test('rejeita confirmação vazia', () {
      final v = Validators.confirmPassword('Senha123');
      expect(v(''), isNotNull);
    });
  });

  // ── name ─────────────────────────────────────────────────────────────────
  group('Validators.name', () {
    test('aceita nome válido', () {
      expect(Validators.name('João'), isNull);
    });

    test('rejeita nome curto (< 3 chars)', () {
      expect(Validators.name('Jo'), isNotNull);
    });

    test('rejeita nome vazio', () {
      expect(Validators.name(''), isNotNull);
    });

    test('rejeita null', () {
      expect(Validators.name(null), isNotNull);
    });
  });

  // ── amount ───────────────────────────────────────────────────────────────
  group('Validators.amount', () {
    test('aceita valor positivo com vírgula', () {
      expect(Validators.amount('100,00'), isNull);
    });

    test('aceita valor positivo com ponto', () {
      expect(Validators.amount('100.50'), isNull);
    });

    test('rejeita zero', () {
      expect(Validators.amount('0,00'), isNotNull);
    });

    test('rejeita valor negativo', () {
      expect(Validators.amount('-10'), isNotNull);
    });

    test('rejeita string vazia', () {
      expect(Validators.amount(''), isNotNull);
    });

    test('rejeita null', () {
      expect(Validators.amount(null), isNotNull);
    });

    test('rejeita valor acima do limite', () {
      expect(Validators.amount('10000000'), isNotNull);
    });

    test('aceita valor no limite máximo', () {
      expect(Validators.amount('9999999.99'), isNull);
    });

    test('rejeita texto não numérico', () {
      expect(Validators.amount('abc'), isNotNull);
    });
  });

  // ── minLength ─────────────────────────────────────────────────────────────
  group('Validators.minLength', () {
    test('aceita texto com comprimento suficiente', () {
      final v = Validators.minLength(5);
      expect(v('Hello'), isNull);
      expect(v('Hello World'), isNull);
    });

    test('rejeita texto curto demais', () {
      final v = Validators.minLength(5);
      expect(v('Hi'), isNotNull);
    });

    test('rejeita vazio', () {
      final v = Validators.minLength(3);
      expect(v(''), isNotNull);
    });

    test('mensagem de erro inclui nome do campo quando fornecido', () {
      final v = Validators.minLength(5, 'Título');
      final error = v('Hi');
      expect(error, contains('Título'));
    });
  });

  // ── maxLength ─────────────────────────────────────────────────────────────
  group('Validators.maxLength', () {
    test('aceita texto dentro do limite', () {
      final v = Validators.maxLength(10);
      expect(v('Hello'), isNull);
    });

    test('rejeita texto longo demais', () {
      final v = Validators.maxLength(5);
      expect(v('Hello World'), isNotNull);
    });

    test('aceita null sem erro', () {
      final v = Validators.maxLength(10);
      expect(v(null), isNull);
    });

    test('aceita exatamente no limite', () {
      final v = Validators.maxLength(5);
      expect(v('Hello'), isNull);
    });
  });

  // ── positiveInt ───────────────────────────────────────────────────────────
  group('Validators.positiveInt', () {
    test('aceita número positivo', () {
      expect(Validators.positiveInt('5'), isNull);
    });

    test('rejeita zero', () {
      expect(Validators.positiveInt('0'), isNotNull);
    });

    test('rejeita negativo', () {
      expect(Validators.positiveInt('-1'), isNotNull);
    });

    test('rejeita não-inteiro', () {
      expect(Validators.positiveInt('1.5'), isNotNull);
    });

    test('rejeita vazio', () {
      expect(Validators.positiveInt(''), isNotNull);
    });
  });

  // ── intRange ──────────────────────────────────────────────────────────────
  group('Validators.intRange', () {
    final v = Validators.intRange(1, 12, 'Mês');

    test('aceita valor no intervalo', () {
      expect(v('6'), isNull);
    });

    test('aceita valor no limite inferior', () {
      expect(v('1'), isNull);
    });

    test('aceita valor no limite superior', () {
      expect(v('12'), isNull);
    });

    test('rejeita valor abaixo do mínimo', () {
      expect(v('0'), isNotNull);
    });

    test('rejeita valor acima do máximo', () {
      expect(v('13'), isNotNull);
    });

    test('rejeita vazio', () {
      expect(v(''), isNotNull);
    });

    test('rejeita não-inteiro', () {
      expect(v('abc'), isNotNull);
    });
  });

  // ── compose ───────────────────────────────────────────────────────────────
  group('Validators.compose', () {
    test('retorna null quando todos passam', () {
      final v = Validators.compose([
        Validators.required('Campo'),
        Validators.minLength(3),
      ]);
      expect(v('João'), isNull);
    });

    test('retorna erro do primeiro validador que falhar', () {
      final v = Validators.compose([
        Validators.required('Campo'),
        Validators.minLength(10),
      ]);
      expect(v('Hi'), isNotNull);
    });

    test('retorna erro de required antes de minLength', () {
      final v = Validators.compose([
        Validators.required('Campo'),
        Validators.minLength(3),
      ]);
      expect(v(''), contains('obrigatório'));
    });
  });
}
