// lib/core/utils/validators.dart

/// Validadores de formulário centralizados.
///
/// Retornam `null` se válido, ou uma `String` de erro se inválido.
/// Compatíveis com `TextFormField.validator`.
///
/// Uso:
/// ```dart
/// TextFormField(
///   validator: Validators.required('Nome'),
/// )
/// ```
abstract final class Validators {
  // ── Campo obrigatório ────────────────────────────────────────────────────

  /// Valida que o campo não está vazio.
  static String? Function(String?) required(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName é obrigatório.';
      }
      return null;
    };
  }

  // ── E-mail ───────────────────────────────────────────────────────────────

  /// Valida formato de e-mail.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório.';
    }
    final isValid =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value.trim());
    if (!isValid) return 'Informe um e-mail válido.';
    return null;
  }

  // ── Senha ────────────────────────────────────────────────────────────────

  /// Valida senha com mínimo de 8 caracteres, letras e números.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória.';
    if (value.length < 8) return 'A senha deve ter pelo menos 8 caracteres.';
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'A senha deve conter letras.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'A senha deve conter números.';
    }
    return null;
  }

  /// Valida que a confirmação de senha é igual à senha original.
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Confirmação de senha é obrigatória.';
      }
      if (value != originalPassword) return 'As senhas não coincidem.';
      return null;
    };
  }

  // ── Nome ─────────────────────────────────────────────────────────────────

  /// Valida nome de pessoa com mínimo de 3 caracteres.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nome é obrigatório.';
    if (value.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres.';
    }
    return null;
  }

  // ── Valor monetário ──────────────────────────────────────────────────────

  /// Valida que um valor monetário é maior que zero.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe um valor.';
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('-')) return 'O valor deve ser maior que zero.';
    final numeric = trimmed.replaceAll(RegExp(r'[^0-9,.]'), '').replaceAll(',', '.');
    final parsed = double.tryParse(numeric);
    if (parsed == null) return 'Valor inválido.';
    if (parsed <= 0) return 'O valor deve ser maior que zero.';
    if (parsed > 9999999.99) return 'O valor excede o limite permitido.';
    return null;
  }

  // ── Comprimento ─────────────────────────────────────────────────────────

  /// Valida comprimento mínimo de texto.
  static String? Function(String?) minLength(int min, [String? fieldName]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '${fieldName ?? 'Campo'} é obrigatório.';
      }
      if (value.trim().length < min) {
        return '${fieldName ?? 'Campo'} deve ter pelo menos $min caracteres.';
      }
      return null;
    };
  }

  /// Valida comprimento máximo de texto.
  static String? Function(String?) maxLength(int max, [String? fieldName]) {
    return (value) {
      if (value != null && value.trim().length > max) {
        return '${fieldName ?? 'Campo'} deve ter no máximo $max caracteres.';
      }
      return null;
    };
  }

  // ── Número inteiro ───────────────────────────────────────────────────────

  /// Valida que o valor é um inteiro positivo.
  static String? positiveInt(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Campo'} é obrigatório.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Informe um número inteiro.';
    if (parsed <= 0) return 'O valor deve ser maior que zero.';
    return null;
  }

  /// Valida que o valor está em um intervalo inteiro [min, max].
  static String? Function(String?) intRange(int min, int max, [String? fieldName]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '${fieldName ?? 'Campo'} é obrigatório.';
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null) return 'Informe um número inteiro.';
      if (parsed < min || parsed > max) {
        return '${fieldName ?? 'Valor'} deve estar entre $min e $max.';
      }
      return null;
    };
  }

  // ── Compostos ────────────────────────────────────────────────────────────

  /// Combina múltiplos validadores — aplica todos e retorna o primeiro erro.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
