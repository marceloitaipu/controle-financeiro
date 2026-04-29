// lib/features/goals/data/datasources/goal_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/goal.dart';
import '../models/goal_model.dart';

abstract interface class GoalRemoteDataSource {
  Stream<List<GoalModel>> watchGoals(String userId, {GoalStatus? status});
  Future<GoalModel> getGoalById(String userId, String id);
  Future<GoalModel> createGoal(GoalModel model);
  Future<GoalModel> updateGoal(GoalModel model);
  Future<void> deleteGoal(String userId, String id);
  Future<void> addProgress(String userId, String goalId, int amount);
}

final class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  GoalRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      firestore.collection('users').doc(userId).collection('goals');

  @override
  Stream<List<GoalModel>> watchGoals(
    String userId, {
    GoalStatus? status,
  }) {
    Query<Map<String, dynamic>> q =
        _col(userId).orderBy('deadline');
    if (status != null) {
      q = q.where('status', isEqualTo: status.name);
    }
    return q
        .snapshots()
        .map((s) => s.docs.map(GoalModel.fromFirestore).toList());
  }

  @override
  Future<GoalModel> getGoalById(String userId, String id) async {
    try {
      final doc = await _col(userId).doc(id).get();
      if (!doc.exists) throw const NotFoundException('Meta não encontrada.');
      return GoalModel.fromFirestore(doc);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('GoalDS.getById', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<GoalModel> createGoal(GoalModel model) async {
    try {
      final ref = model.id.isEmpty
          ? _col(model.userId).doc()
          : _col(model.userId).doc(model.id);
      final toSave = model.id.isEmpty
          ? GoalModel.fromEntity(model.toEntity().copyWith(id: ref.id))
          : model;
      await ref.set(toSave.toFirestore());
      return toSave;
    } catch (e, st) {
      AppLogger.error('GoalDS.create', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<GoalModel> updateGoal(GoalModel model) async {
    try {
      await _col(model.userId).doc(model.id).update(model.toFirestore());
      return model;
    } catch (e, st) {
      AppLogger.error('GoalDS.update', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> deleteGoal(String userId, String id) async {
    try {
      await _col(userId)
          .doc(id)
          .update({'status': GoalStatus.cancelled.name});
    } catch (e, st) {
      AppLogger.error('GoalDS.delete', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> addProgress(
    String userId,
    String goalId,
    int amount,
  ) async {
    try {
      final ref = _col(userId).doc(goalId);
      await firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = snap.data()?['currentAmount'] as int? ?? 0;
        final target = snap.data()?['targetAmount'] as int? ?? 0;
        final updated = (current + amount).clamp(0, target * 2);
        final isCompleted = updated >= target;
        tx.update(ref, {
          'currentAmount': updated,
          if (isCompleted) 'status': GoalStatus.completed.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e, st) {
      AppLogger.error('GoalDS.addProgress', e, st);
      throw const UnexpectedException();
    }
  }
}
