// lib/features/onboarding/domain/entities/onboarding_status.dart

import 'package:equatable/equatable.dart';

/// Registra o progresso e conclusão do onboarding do usuário.
final class OnboardingStatus extends Equatable {
  const OnboardingStatus({
    required this.userId,
    required this.isCompleted,
    this.completedAt,
    this.preferredCurrency = 'BRL',
    this.displayName,
  });

  final String userId;

  /// true quando o usuário finalizou o fluxo de onboarding.
  final bool isCompleted;

  /// Momento em que o onboarding foi concluído.
  final DateTime? completedAt;

  /// Moeda preferida pelo usuário (ex: 'BRL', 'USD').
  final String preferredCurrency;

  /// Nome de exibição definido durante o onboarding.
  final String? displayName;

  OnboardingStatus copyWith({
    String? userId,
    bool? isCompleted,
    DateTime? completedAt,
    String? preferredCurrency,
    String? displayName,
  }) {
    return OnboardingStatus(
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        isCompleted,
        completedAt,
        preferredCurrency,
        displayName,
      ];
}
