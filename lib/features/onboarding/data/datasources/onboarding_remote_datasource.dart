// lib/features/onboarding/data/datasources/onboarding_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../categories/data/datasources/category_remote_datasource.dart';
import '../models/onboarding_status_model.dart';

abstract interface class OnboardingRemoteDataSource {
  Future<OnboardingStatusModel> getStatus(String userId);

  Future<void> completeOnboarding({
    required String userId,
    required String displayName,
    required String preferredCurrency,
  });

  Future<void> savePartialProgress({
    required String userId,
    String? displayName,
    String? preferredCurrency,
  });
}

final class OnboardingRemoteDataSourceImpl
    implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.categoryDataSource,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final CategoryRemoteDataSource categoryDataSource;

  DocumentReference<Map<String, dynamic>> _onboardingRef(String userId) =>
      firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('onboarding');

  @override
  Future<OnboardingStatusModel> getStatus(String userId) async {
    try {
      final doc = await _onboardingRef(userId).get();
      if (!doc.exists) return OnboardingStatusModel.notStarted(userId);
      return OnboardingStatusModel.fromFirestore(doc);
    } catch (e, st) {
      AppLogger.error('Erro ao buscar status de onboarding', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> completeOnboarding({
    required String userId,
    required String displayName,
    required String preferredCurrency,
  }) async {
    try {
      // 1. Atualiza displayName no Firebase Auth
      final user = firebaseAuth.currentUser;
      if (user != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }

      // 2. Salva status do onboarding no Firestore (batch atômico)
      final batch = firestore.batch();

      final model = OnboardingStatusModel(
        userId: userId,
        isCompleted: true,
        preferredCurrency: preferredCurrency,
        displayName: displayName.trim(),
      );
      batch.set(
        _onboardingRef(userId),
        model.toFirestore(completed: true),
        SetOptions(merge: true),
      );

      // Atualiza displayName e preferências no documento do usuário.
      // Inclui email e createdAt para garantir que o documento seja criado
      // corretamente caso ainda não exista (ex: usuário criado via console).
      final firebaseUser = firebaseAuth.currentUser;
      batch.set(
        firestore.collection('users').doc(userId),
        {
          if (firebaseUser?.email != null) 'email': firebaseUser!.email!,
          if (firebaseUser?.metadata.creationTime != null)
            'createdAt':
                Timestamp.fromDate(firebaseUser!.metadata.creationTime!),
          'displayName': displayName.trim(),
          'preferredCurrency': preferredCurrency,
          'onboardingCompletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      // 3. Seed de categorias padrão (fora da batch — operação separada)
      await categoryDataSource.seedDefaultCategories(userId);

      AppLogger.info('Onboarding concluído para $userId');
    } catch (e, st) {
      AppLogger.error('Erro ao concluir onboarding', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> savePartialProgress({
    required String userId,
    String? displayName,
    String? preferredCurrency,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        if (displayName != null) 'displayName': displayName.trim(),
        if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
      };
      await _onboardingRef(userId).set(data, SetOptions(merge: true));
    } catch (e, st) {
      AppLogger.error('Erro ao salvar progresso do onboarding', e, st);
      throw const UnexpectedException();
    }
  }
}
