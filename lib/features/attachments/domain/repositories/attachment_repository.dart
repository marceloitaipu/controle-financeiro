// lib/features/attachments/domain/repositories/attachment_repository.dart

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failure.dart';

/// Contrato de armazenamento de comprovantes e anexos.
///
/// Implementado via Firebase Storage.
abstract interface class AttachmentRepository {
  /// Faz o upload de um arquivo local para o Storage.
  ///
  /// O arquivo será salvo em:
  /// `users/{userId}/transactions/{transactionId}/{timestamp}_{sanitizedName}`
  ///
  /// Retorna a URL pública de download em caso de sucesso.
  Future<Either<Failure, String>> uploadFile({
    required String userId,
    required String transactionId,
    required XFile file,
  });

  /// Remove um arquivo do Storage a partir da sua URL de download.
  ///
  /// Silencia erros de arquivo inexistente (ex: já removido).
  Future<Either<Failure, void>> deleteFile(String storageUrl);
}
