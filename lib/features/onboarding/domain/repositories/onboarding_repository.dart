// lib/features/onboarding/domain/repositories/onboarding_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/onboarding_status.dart';

abstract interface class OnboardingRepository {
  /// Retorna o status atual do onboarding do usuário.
  /// Retorna [OnboardingStatus] com isCompleted=false se ainda não existe.
  Future<Either<Failure, OnboardingStatus>> getStatus(String userId);

  /// Salva preferências e marca o onboarding como concluído.
  Future<Either<Failure, void>> completeOnboarding({
    required String userId,
    required String displayName,
    required String preferredCurrency,
  });

  /// Persiste o progresso parcial (ex: preferências antes de finalizar).
  Future<Either<Failure, void>> savePartialProgress({
    required String userId,
    String? displayName,
    String? preferredCurrency,
  });
}
