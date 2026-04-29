// lib/features/onboarding/data/models/onboarding_status_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/onboarding_status.dart';

final class OnboardingStatusModel {
  const OnboardingStatusModel({
    required this.userId,
    required this.isCompleted,
    this.completedAt,
    required this.preferredCurrency,
    this.displayName,
  });

  final String userId;
  final bool isCompleted;
  final DateTime? completedAt;
  final String preferredCurrency;
  final String? displayName;

  factory OnboardingStatusModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return OnboardingStatusModel(
      userId: doc.reference.parent.parent!.id,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      preferredCurrency: data['preferredCurrency'] as String? ?? 'BRL',
      displayName: data['displayName'] as String?,
    );
  }

  factory OnboardingStatusModel.notStarted(String userId) {
    return OnboardingStatusModel(
      userId: userId,
      isCompleted: false,
      preferredCurrency: 'BRL',
    );
  }

  Map<String, dynamic> toFirestore({bool completed = false}) {
    return {
      'isCompleted': isCompleted || completed,
      if (completed) 'completedAt': FieldValue.serverTimestamp(),
      'preferredCurrency': preferredCurrency,
      if (displayName != null) 'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  OnboardingStatus toEntity() {
    return OnboardingStatus(
      userId: userId,
      isCompleted: isCompleted,
      completedAt: completedAt,
      preferredCurrency: preferredCurrency,
      displayName: displayName,
    );
  }
}
