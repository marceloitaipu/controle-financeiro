// lib/core/errors/failure.dart

import 'package:equatable/equatable.dart';

/// Falhas da camada de domínio — retornadas via [Either<Failure, T>].
/// Nunca exponha [AppException] direto para a camada de apresentação.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// Falha de autenticação.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Recurso não encontrado.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Sem conexão com a internet.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

/// Erro de validação de entrada.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Conflito de dados.
final class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

/// Erro de armazenamento (Firebase Storage).
final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Falha genérica / inesperada.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocorreu um erro inesperado.']);
}

/// Falha decorrente de operação cancelada pelo usuário (ex: Google Sign-In).
/// Não deve exibir mensagem de erro na UI — trate silenciosamente.
final class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Operação cancelada.']);
}
