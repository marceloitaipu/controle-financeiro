// lib/core/errors/app_exception.dart

/// Hierarquia de exceções da camada de dados.
/// Lançadas pelos DataSources e capturadas nos Repositories.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Falha de autenticação (token inválido, permissão negada, etc.).
final class AuthException extends AppException {
  const AuthException(super.message);
}

/// Recurso não encontrado no Firestore.
final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Erro de rede / sem conexão.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'Sem conexão com a internet.']);
}

/// Erro de validação de dados de entrada.
final class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Erro inesperado / genérico.
final class UnexpectedException extends AppException {
  const UnexpectedException([super.message = 'Ocorreu um erro inesperado.']);
}

/// Conflito de dados (ex: conta com mesmo nome já existe).
final class ConflictException extends AppException {
  const ConflictException(super.message);
}

/// Operação cancelada pelo usuário.
final class CancelledException extends AppException {
  const CancelledException([super.message = 'Operação cancelada.']);
}

/// Cota de armazenamento excedida.
final class StorageException extends AppException {
  const StorageException(super.message);
}
