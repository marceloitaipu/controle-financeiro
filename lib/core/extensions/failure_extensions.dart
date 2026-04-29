// lib/core/extensions/failure_extensions.dart

import '../errors/failure.dart';

/// Extension em [Failure] que fornece mensagem amigável para o usuário final.
///
/// Use [userMessage] na camada de apresentação — nunca exponha [Failure.message]
/// diretamente na UI quando ele puder conter detalhes técnicos.
///
/// Uso:
/// ```dart
/// ref.listen(someProvider, (_, next) {
///   next.whenOrNull(
///     error: (e, _) {
///       if (e is Failure && !e.isSilent) {
///         AppSnackBar.error(context, e.userMessage);
///       }
///     },
///   );
/// });
/// ```
extension FailureX on Failure {
  /// Mensagem de erro localizada e amigável para o usuário.
  ///
  /// - [CancelledFailure] → string vazia (trate silenciosamente com [isSilent]).
  /// - [NetworkFailure] → mensagem padrão de rede.
  /// - Demais tipos → [Failure.message] do domínio (já user-facing).
  String get userMessage => switch (this) {
        CancelledFailure _ => '',
        NetworkFailure _ =>
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        NotFoundFailure _ => message,
        AuthFailure _ => message,
        ValidationFailure _ => message,
        ConflictFailure _ => message,
        StorageFailure _ =>
          'Erro ao processar o arquivo. Tente novamente.',
        UnexpectedFailure _ =>
          'Ocorreu um erro inesperado. Tente novamente.',
      };

  /// Retorna `true` se a falha deve ser tratada silenciosamente na UI.
  /// Atualmente apenas [CancelledFailure] é silenciosa.
  bool get isSilent => this is CancelledFailure;
}
