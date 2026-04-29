// lib/features/attachments/data/repositories/attachment_repository_impl.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/firestore_helper.dart';
import '../../domain/repositories/attachment_repository.dart';

final class AttachmentRepositoryImpl
    with FirestoreExceptionMapper
    implements AttachmentRepository {
  const AttachmentRepositoryImpl({required this.storage});

  final FirebaseStorage storage;

  @override
  Future<Either<Failure, String>> uploadFile({
    required String userId,
    required String transactionId,
    required XFile file,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = _sanitize(file.name);
      final path =
          'users/$userId/transactions/$transactionId/${timestamp}_$safeName';

      final ref = storage.ref(path);
      final uploadTask = await ref.putFile(File(file.path));
      final url = await uploadTask.ref.getDownloadURL();
      return Right(url);
    } on FirebaseException catch (e, st) {
      AppLogger.error('AttachmentRepo.upload', e, st);
      return Left(StorageFailure(e.message ?? 'Erro no upload.'));
    } on AppException catch (e) {
      return Left(mapException(e));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AttachmentRepo.upload'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String storageUrl) async {
    try {
      final ref = storage.refFromURL(storageUrl);
      await ref.delete();
      return const Right(null);
    } on FirebaseException catch (e, st) {
      // Ignora "object not found" — já foi deletado
      if (e.code == 'object-not-found') return const Right(null);
      AppLogger.error('AttachmentRepo.delete', e, st);
      return Left(StorageFailure(e.message ?? 'Erro ao remover arquivo.'));
    } catch (e, st) {
      return Left(mapUnexpected(e, st, 'AttachmentRepo.delete'));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Remove caracteres não-alfanuméricos do nome (exceto ponto e hífen).
  String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[^a-zA-Z0-9._\-]'), '_');
}
