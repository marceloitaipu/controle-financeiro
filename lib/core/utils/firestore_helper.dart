// lib/core/utils/firestore_helper.dart

import '../errors/app_exception.dart';
import '../errors/failure.dart';
import 'app_logger.dart';

/// Mixin utilitário para mapeamento de [AppException] → [Failure].
/// Inclua nos Repositories: `with FirestoreExceptionMapper`.
mixin FirestoreExceptionMapper {
  Failure mapException(AppException e) => switch (e) {
        AuthException() => AuthFailure(e.message),
        NotFoundException() => NotFoundFailure(e.message),
        NetworkException() => NetworkFailure(e.message),
        ValidationException() => ValidationFailure(e.message),
        ConflictException() => ConflictFailure(e.message),
        StorageException() => StorageFailure(e.message),
        CancelledException() => CancelledFailure(e.message),
        UnexpectedException() => UnexpectedFailure(e.message),
      };

  /// Loga e retorna [UnexpectedFailure] para erros não mapeados.
  Failure mapUnexpected(Object e, StackTrace st, String context) {
    AppLogger.error(context, e, st);
    return const UnexpectedFailure();
  }
}
