// lib/features/budgets/data/datasources/budget_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/budget_model.dart';

abstract interface class BudgetRemoteDataSource {
  Stream<List<BudgetModel>> watchBudgets(
    String userId, {
    bool onlyActive = true,
  });
  Future<BudgetModel> getBudgetById(String userId, String id);
  Future<BudgetModel> createBudget(BudgetModel model);
  Future<BudgetModel> updateBudget(BudgetModel model);
  Future<void> deleteBudget(String userId, String id);
}

final class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  BudgetRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      firestore.collection('users').doc(userId).collection('budgets');

  @override
  Stream<List<BudgetModel>> watchBudgets(
    String userId, {
    bool onlyActive = true,
  }) {
    Query<Map<String, dynamic>> q = _col(userId);
    if (onlyActive) q = q.where('isActive', isEqualTo: true);
    return q.snapshots().map(
          (s) => s.docs.map(BudgetModel.fromFirestore).toList(),
        );
  }

  @override
  Future<BudgetModel> getBudgetById(String userId, String id) async {
    try {
      final doc = await _col(userId).doc(id).get();
      if (!doc.exists) throw const NotFoundException('Orçamento não encontrado.');
      return BudgetModel.fromFirestore(doc);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('BudgetDS.getById', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<BudgetModel> createBudget(BudgetModel model) async {
    try {
      final ref = model.id.isEmpty
          ? _col(model.userId).doc()
          : _col(model.userId).doc(model.id);
      final toSave = model.id.isEmpty
          ? BudgetModel.fromEntity(model.toEntity().copyWith(id: ref.id))
          : model;
      await ref.set(toSave.toFirestore());
      return toSave;
    } catch (e, st) {
      AppLogger.error('BudgetDS.create', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<BudgetModel> updateBudget(BudgetModel model) async {
    try {
      await _col(model.userId).doc(model.id).update(model.toFirestore());
      return model;
    } catch (e, st) {
      AppLogger.error('BudgetDS.update', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> deleteBudget(String userId, String id) async {
    try {
      await _col(userId).doc(id).update({'isActive': false});
    } catch (e, st) {
      AppLogger.error('BudgetDS.delete', e, st);
      throw const UnexpectedException();
    }
  }
}
