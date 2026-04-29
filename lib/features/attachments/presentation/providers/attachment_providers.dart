// lib/features/attachments/presentation/providers/attachment_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/repositories/attachment_repository_impl.dart';
import '../../domain/repositories/attachment_repository.dart';

part 'attachment_providers.g.dart';

/// Provider do repositório de anexos — singleton durante o ciclo de vida do app.
@Riverpod(keepAlive: true)
AttachmentRepository attachmentRepository(Ref ref) {
  return AttachmentRepositoryImpl(
    storage: ref.watch(firebaseStorageProvider),
  );
}
