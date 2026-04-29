// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// ── Infra providers (keepAlive — usados em toda a sessão) ─────────────────────

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn();

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

// ── Estado de autenticação — stream keepAlive ─────────────────────────────────

/// Stream do usuário autenticado.
/// Null quando deslogado, AsyncLoading no boot inicial.
/// keepAlive: true — usado pelo GoRouter e em toda a sessão.
@Riverpod(keepAlive: true)
Stream<AppUser?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

// ── Usuário atual (snapshot síncrono) ─────────────────────────────────────────

/// Snapshot síncrono do usuário atual.
/// Retorna null enquanto carrega ou quando deslogado.
/// Use para acesso rápido ao user sem await.
@Riverpod(keepAlive: true)
AppUser? currentUser(Ref ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

// ── Notifier de ações de auth ─────────────────────────────────────────────────

/// Gerencia o estado das operações de autenticação (login, cadastro, logout...).
///
/// Padrão de uso nas páginas:
/// ```dart
/// // Listen para erros:
/// ref.listen<AsyncValue<void>>(authNotifierProvider, (prev, next) {
///   next.whenOrNull(error: (e, _) => AppSnackBar.error(context, ...));
/// });
/// ```
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _repo.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    final result = await _repo.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  /// Login com Google. Cancelamento pelo usuário é tratado silenciosamente.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await _repo.signInWithGoogle();
    result.fold(
      (failure) {
        if (failure is CancelledFailure) {
          state = const AsyncData(null);
        } else {
          state = AsyncError(failure, StackTrace.current);
        }
      },
      (_) => state = const AsyncData(null),
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncLoading();
    final result = await _repo.sendPasswordResetEmail(email: email);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await _repo.signOut();
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  /// Atualiza o nome de exibição do perfil do usuário.
  Future<void> updateProfile({required String displayName}) async {
    state = const AsyncLoading();
    final result = await _repo.updateProfile(displayName: displayName);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  /// Exclui permanentemente a conta do usuário.
  /// Pode falhar com [AuthFailure] se o login for muito antigo
  /// (requires-recent-login).
  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    final result = await _repo.deleteAccount();
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  /// Limpa qualquer estado de erro — útil ao retornar para uma tela de auth.
  void resetState() => state = const AsyncData(null);
}