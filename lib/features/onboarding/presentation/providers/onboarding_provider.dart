// lib/features/onboarding/presentation/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../categories/data/datasources/category_remote_datasource.dart';
import '../../data/datasources/onboarding_remote_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/repositories/onboarding_repository.dart';

part 'onboarding_provider.g.dart';

// ── Infra ──────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
CategoryRemoteDataSource categoryRemoteDataSource(Ref ref) {
  return CategoryRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@Riverpod(keepAlive: true)
OnboardingRemoteDataSource onboardingRemoteDataSource(Ref ref) {
  return OnboardingRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    categoryDataSource: ref.watch(categoryRemoteDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepositoryImpl(
    ref.watch(onboardingRemoteDataSourceProvider),
  );
}

// ── Status de onboarding (FutureProvider) ─────────────────────────────────

/// Carrega o status de onboarding do usuário atual.
/// Retorna null se não houver usuário autenticado.
@Riverpod(keepAlive: true)
Future<OnboardingStatus?> onboardingStatus(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final result =
      await ref.watch(onboardingRepositoryProvider).getStatus(user.id);

  return result.fold((_) => null, (status) => status);
}

// ── Notifier de ações ──────────────────────────────────────────────────────

/// Estado do onboarding durante as ações (loading, error, data).
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  String get _userId {
    final user = ref.read(currentUserProvider);
    if (user == null) throw StateError('Usuário não autenticado.');
    return user.id;
  }

  /// Salva progresso parcial (chamado a cada step do onboarding).
  Future<void> savePartialProgress({
    String? displayName,
    String? preferredCurrency,
  }) async {
    final result = await _repo.savePartialProgress(
      userId: _userId,
      displayName: displayName,
      preferredCurrency: preferredCurrency,
    );
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) {},
    );
  }

  /// Finaliza o onboarding: salva perfil, cria categorias seed.
  /// Após concluir, invalida o cache — o GoRouter redireciona para /home.
  Future<void> completeOnboarding({
    required String displayName,
    required String preferredCurrency,
  }) async {
    state = const AsyncLoading();
    final result = await _repo.completeOnboarding(
      userId: _userId,
      displayName: displayName,
      preferredCurrency: preferredCurrency,
    );
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) {
        // Invalida o cache do status para forçar re-avaliação do redirect
        ref.invalidate(onboardingStatusProvider);
        state = const AsyncData(null);
      },
    );
  }

  void resetState() => state = const AsyncData(null);
}
