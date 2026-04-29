// lib/features/goals/domain/entities/goal.dart

import 'package:equatable/equatable.dart';

/// Status da meta financeira.
enum GoalStatus { active, completed, cancelled }

extension GoalStatusLabel on GoalStatus {
  String get label => switch (this) {
        GoalStatus.active => 'Ativa',
        GoalStatus.completed => 'Concluída',
        GoalStatus.cancelled => 'Cancelada',
      };
}

/// Entidade imutável de domínio para metas financeiras.
final class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.colorHex,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.linkedAccountId,
    this.status = GoalStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;

  /// Valor alvo em centavos.
  final int targetAmount;

  /// Valor atual acumulado em centavos.
  final int currentAmount;

  final DateTime deadline;
  final String colorHex;
  final int iconCodePoint;
  final String iconFontFamily;

  /// Conta bancária vinculada a esta meta (opcional).
  final String? linkedAccountId;

  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  double get targetInReais => targetAmount / 100;
  double get currentInReais => currentAmount / 100;

  /// Progresso de 0.0 a 1.0.
  double get progress =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  /// Valor restante em centavos.
  int get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, targetAmount);

  bool get isCompleted => currentAmount >= targetAmount;

  Goal copyWith({
    String? id,
    String? userId,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? deadline,
    String? colorHex,
    int? iconCodePoint,
    String? iconFontFamily,
    String? linkedAccountId,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, name, targetAmount, currentAmount, deadline,
        colorHex, iconCodePoint, iconFontFamily, linkedAccountId,
        status, createdAt, updatedAt,
      ];
}
