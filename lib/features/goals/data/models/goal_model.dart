// lib/features/goals/data/models/goal_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/goal.dart';

final class GoalModel {
  const GoalModel({
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
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime deadline;
  final String colorHex;
  final int iconCodePoint;
  final String iconFontFamily;
  final String? linkedAccountId;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory GoalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return GoalModel(
      id: doc.id,
      userId: d['userId'] as String,
      name: d['name'] as String,
      targetAmount: d['targetAmount'] as int,
      currentAmount: d['currentAmount'] as int? ?? 0,
      deadline: (d['deadline'] as Timestamp).toDate(),
      colorHex: d['colorHex'] as String? ?? '#1565C0',
      iconCodePoint: d['iconCodePoint'] as int,
      iconFontFamily: d['iconFontFamily'] as String? ?? 'MaterialIcons',
      linkedAccountId: d['linkedAccountId'] as String?,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == d['status'],
        orElse: () => GoalStatus.active,
      ),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory GoalModel.fromEntity(Goal e) => GoalModel(
        id: e.id,
        userId: e.userId,
        name: e.name,
        targetAmount: e.targetAmount,
        currentAmount: e.currentAmount,
        deadline: e.deadline,
        colorHex: e.colorHex,
        iconCodePoint: e.iconCodePoint,
        iconFontFamily: e.iconFontFamily,
        linkedAccountId: e.linkedAccountId,
        status: e.status,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': Timestamp.fromDate(deadline),
        'colorHex': colorHex,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        if (linkedAccountId != null) 'linkedAccountId': linkedAccountId,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Goal toEntity() => Goal(
        id: id,
        userId: userId,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: deadline,
        colorHex: colorHex,
        iconCodePoint: iconCodePoint,
        iconFontFamily: iconFontFamily,
        linkedAccountId: linkedAccountId,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
