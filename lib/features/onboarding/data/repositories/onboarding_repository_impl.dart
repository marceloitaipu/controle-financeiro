// lib/features/onboarding/data/repositories/onboarding_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_datasource.dart';

final class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._dataSource);

  final OnboardingRemoteDataSource _dataSource;

  Failure _mapException(AppException e) => switch (e) {
        AuthException() => AuthFailure(e.message),
        NotFoundException() => NotFoundFailure(e.message),
        NetworkException() => NetworkFailure(e.message),
        ValidationException() => ValidationFailure(e.message),
        ConflictException() => ConflictFailure(e.message),
        StorageException() => StorageFailure(e.message),
        CancelledException() => CancelledFailure(e.message),
        UnexpectedException() => UnexpectedFailure(e.message),
      };

  @override
  Future<Either<Failure, OnboardingStatus>> getStatus(String userId) async {
    try {
      final model = await _dataSource.getStatus(userId);
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('OnboardingRepo.getStatus', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding({
    required String userId,
    required String displayName,
    required String preferredCurrency,
  }) async {
    try {
      await _dataSource.completeOnboarding(
        userId: userId,
        displayName: displayName,
        preferredCurrency: preferredCurrency,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('OnboardingRepo.completeOnboarding', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> savePartialProgress({
    required String userId,
    String? displayName,
    String? preferredCurrency,
  }) async {
    try {
      await _dataSource.savePartialProgress(
        userId: userId,
        displayName: displayName,
        preferredCurrency: preferredCurrency,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('OnboardingRepo.savePartialProgress', e, st);
      return const Left(UnexpectedFailure());
    }
  }
}
