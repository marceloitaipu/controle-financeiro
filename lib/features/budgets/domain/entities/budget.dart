// lib/features/budgets/domain/entities/budget.dart

import 'package:equatable/equatable.dart';

/// Período de vigência do orçamento.
enum BudgetPeriod { monthly, weekly, yearly, custom }

extension BudgetPeriodLabel on BudgetPeriod {
  String get label => switch (this) {
        BudgetPeriod.monthly => 'Mensal',
        BudgetPeriod.weekly => 'Semanal',
        BudgetPeriod.yearly => 'Anual',
        BudgetPeriod.custom => 'Personalizado',
      };
}

/// Entidade imutável de domínio para orçamentos por categoria.
final class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    this.alertThreshold = 0.8,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;

  /// Categoria à qual o orçamento se aplica.
  final String categoryId;

  /// Valor limite em centavos.
  final int amount;

  final BudgetPeriod period;
  final DateTime startDate;

  /// Apenas para [BudgetPeriod.custom].
  final DateTime? endDate;

  /// Percentual do orçamento que dispara alerta (0.0–1.0). Padrão: 80%.
  final double alertThreshold;

  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  double get amountInReais => amount / 100;

  Budget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    int? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, categoryId, amount, period, startDate,
        endDate, alertThreshold, isActive, createdAt, updatedAt,
      ];
}
