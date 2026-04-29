// lib/core/extensions/string_extensions.dart

extension StringExtensions on String {
  /// Retorna null se a string for vazia, caso contrário retorna ela mesma.
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Capitaliza a primeira letra.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitaliza cada palavra.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Remove todos os caracteres não numéricos.
  String get onlyNumbers => replaceAll(RegExp(r'[^0-9]'), '');

  /// Verifica se é um e-mail válido.
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Verifica se é uma senha forte (mínimo 8 chars, letras e números).
  bool get isStrongPassword {
    return length >= 8 &&
        contains(RegExp(r'[a-zA-Z]')) &&
        contains(RegExp(r'[0-9]'));
  }

  /// Trunca a string com reticências se ultrapassar [maxLength].
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }
}

extension NullableStringExtensions on String? {
  /// Retorna true se a string for null ou vazia.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Retorna um fallback se a string for null ou vazia.
  String orDefault(String fallback) =>
      isNullOrEmpty ? fallback : this!;
}
