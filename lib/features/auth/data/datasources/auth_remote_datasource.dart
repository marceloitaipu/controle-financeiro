// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/app_user_model.dart';

/// DataSource que se comunica diretamente com Firebase Auth e Firestore.
abstract interface class AuthRemoteDataSource {
  Stream<AppUserModel?> get authStateChanges;
  AppUserModel? get currentUser;

  Future<AppUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AppUserModel> signInWithGoogle();
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();

  Future<AppUserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  Future<void> deleteAccount();
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  // ── Helpers ───────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection('users');

  /// Salva ou atualiza o perfil do usuário no Firestore.
  Future<AppUserModel> _upsertUserProfile(AppUserModel model) async {
    await _usersCollection.doc(model.id).set(
          model.toFirestore(),
          SetOptions(merge: true),
        );
    return model;
  }

  /// Mapeia [FirebaseAuthException] para [AppException].
  AppException _mapFirebaseAuthException(FirebaseAuthException e) {
    if (kDebugMode) AppLogger.warning('FirebaseAuthException: ${e.code} — ${e.message}');
    return switch (e.code) {
      'user-not-found' => const AuthException('Usuário não encontrado.'),
      'wrong-password' => const AuthException('Senha incorreta.'),
      'invalid-credential' =>
        const AuthException('E-mail ou senha incorretos.'),
      'email-already-in-use' =>
        const AuthException('Este e-mail já está em uso.'),
      'weak-password' => const AuthException(
          'Senha fraca. Use ao menos 8 caracteres com letras e números.'),
      'user-disabled' => const AuthException('Esta conta foi desativada.'),
      'too-many-requests' => const AuthException(
          'Muitas tentativas. Aguarde alguns minutos e tente novamente.'),
      'network-request-failed' =>
        const NetworkException('Sem conexão com a internet.'),
      'invalid-email' => const ValidationException('E-mail inválido.'),
      _ => UnexpectedException('Erro de autenticação: ${e.message}'),
    };
  }

  // ── Implementações ────────────────────────────────────────────────────────

  @override
  Stream<AppUserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      // Tenta buscar perfil completo do Firestore
      try {
        final doc = await _usersCollection.doc(user.uid).get();
        if (doc.exists) return AppUserModel.fromFirestore(doc);
      } catch (e, st) {
        AppLogger.warning('authStateChanges: falha ao buscar perfil do Firestore', e, st);
      }
      return AppUserModel.fromFirebaseUser(user);
    });
  }

  @override
  AppUserModel? get currentUser {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return AppUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AppUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final model = AppUserModel.fromFirebaseUser(credential.user!);
      return model;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erro inesperado no login', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<AppUserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();

      final model = AppUserModel.fromFirebaseUser(
        firebaseAuth.currentUser!,
      ).copyWith(displayName: displayName.trim());

      return await _upsertUserProfile(model);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erro inesperado no cadastro', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<AppUserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw const CancelledException();

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final model =
          AppUserModel.fromFirebaseUser(userCredential.user!);
      return await _upsertUserProfile(model);
    } on CancelledException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erro no login com Google', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erro ao enviar reset de senha', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        if (await googleSignIn.isSignedIn()) googleSignIn.signOut(),
      ]);
    } catch (e, st) {
      AppLogger.error('Erro no logout', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<AppUserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = firebaseAuth.currentUser!;
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
      await user.reload();

      final model = AppUserModel.fromFirebaseUser(firebaseAuth.currentUser!);
      return await _upsertUserProfile(model);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erro ao atualizar perfil', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser!;
      await _usersCollection.doc(user.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'Para deletar a conta, faça login novamente primeiro.',
        );
      }
      throw _mapFirebaseAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erro ao deletar conta', e, st);
      throw const UnexpectedException();
    }
  }
}
