// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementação do [AuthRepository].
/// Captura [AppException] e converte em [Failure].
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  /// Mapeia [AppException] → [Failure].
  Failure _mapException(AppException e) {
    return switch (e) {
      AuthException() => AuthFailure(e.message),
      ValidationException() => ValidationFailure(e.message),
      NetworkException() => NetworkFailure(e.message),
      ConflictException() => ConflictFailure(e.message),
      StorageException() => StorageFailure(e.message),
      CancelledException() => CancelledFailure(e.message),
      _ => UnexpectedFailure(e.message),
    };
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _dataSource.authStateChanges.map((model) => model?.toEntity());
  }

  @override
  AppUser? get currentUser => _dataSource.currentUser?.toEntity();

  @override
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('Erro inesperado no repositório auth', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final model = await _dataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('Erro inesperado no repositório auth', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final model = await _dataSource.signInWithGoogle();
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('Erro inesperado no repositório auth', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _dataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('Erro inesperado no repositório auth', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('Erro inesperado no repositório auth', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final model = await _dataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('Erro inesperado no repositório auth', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('Erro inesperado no repositório auth', e, st);
      return const Left(UnexpectedFailure());
    }
  }
}
