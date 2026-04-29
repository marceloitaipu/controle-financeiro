// lib/features/budgets/data/models/budget_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/budget.dart';

final class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.alertThreshold,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String categoryId;
  final int amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final double alertThreshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory BudgetModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return BudgetModel(
      id: doc.id,
      userId: d['userId'] as String,
      categoryId: d['categoryId'] as String,
      amount: d['amount'] as int,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == d['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: (d['startDate'] as Timestamp).toDate(),
      endDate: d['endDate'] != null
          ? (d['endDate'] as Timestamp).toDate()
          : null,
      alertThreshold: (d['alertThreshold'] as num?)?.toDouble() ?? 0.8,
      isActive: d['isActive'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory BudgetModel.fromEntity(Budget e) => BudgetModel(
        id: e.id,
        userId: e.userId,
        categoryId: e.categoryId,
        amount: e.amount,
        period: e.period,
        startDate: e.startDate,
        endDate: e.endDate,
        alertThreshold: e.alertThreshold,
        isActive: e.isActive,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'categoryId': categoryId,
        'amount': amount,
        'period': period.name,
        'startDate': Timestamp.fromDate(startDate),
        if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
        'alertThreshold': alertThreshold,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Budget toEntity() => Budget(
        id: id,
        userId: userId,
        categoryId: categoryId,
        amount: amount,
        period: period,
        startDate: startDate,
        endDate: endDate,
        alertThreshold: alertThreshold,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
