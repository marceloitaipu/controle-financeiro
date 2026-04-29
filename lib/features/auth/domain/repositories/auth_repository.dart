// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_user.dart';

/// Contrato do repositório de autenticação.
/// A implementação fica na camada de dados.
abstract interface class AuthRepository {
  /// Stream do usuário autenticado. Emite null quando deslogado.
  Stream<AppUser?> get authStateChanges;

  /// Usuário atual (pode ser null se não autenticado).
  AppUser? get currentUser;

  /// Login com e-mail e senha.
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Cadastro com e-mail e senha.
  Future<Either<Failure, AppUser>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login com Google.
  Future<Either<Failure, AppUser>> signInWithGoogle();

  /// Envio de e-mail de redefinição de senha.
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Logout.
  Future<Either<Failure, void>> signOut();

  /// Atualiza o perfil do usuário.
  Future<Either<Failure, AppUser>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Deleta a conta do usuário (requer reautenticação).
  Future<Either<Failure, void>> deleteAccount();
}
