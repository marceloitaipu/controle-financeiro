// lib/features/accounts/data/datasources/account_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/account_model.dart';

abstract interface class AccountRemoteDataSource {
  Stream<List<AccountModel>> watchAccounts(String userId);
  Future<AccountModel> getAccountById(String userId, String id);
  Future<AccountModel> createAccount(AccountModel model);
  Future<AccountModel> updateAccount(AccountModel model);
  Future<void> deleteAccount(String userId, String id);
  Future<void> adjustBalance(String userId, String accountId, int delta);
  Future<int> getTotalBalance(String userId);
}

final class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  AccountRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      firestore.collection('users').doc(userId).collection('accounts');

  @override
  Stream<List<AccountModel>> watchAccounts(String userId) {
    return _col(userId).orderBy('name').snapshots().map(
          (s) => s.docs.map(AccountModel.fromFirestore).toList(),
        );
  }

  @override
  Future<AccountModel> getAccountById(String userId, String id) async {
    try {
      final doc = await _col(userId).doc(id).get();
      if (!doc.exists) throw const NotFoundException('Conta não encontrada.');
      return AccountModel.fromFirestore(doc);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('AccountDS.getById', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<AccountModel> createAccount(AccountModel model) async {
    try {
      final ref = model.id.isEmpty
          ? _col(model.userId).doc()
          : _col(model.userId).doc(model.id);
      final toSave = model.id.isEmpty
          ? AccountModel.fromEntity(model.toEntity().copyWith(id: ref.id))
          : model;
      await ref.set(toSave.toFirestore());
      return toSave;
    } catch (e, st) {
      AppLogger.error('AccountDS.create', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<AccountModel> updateAccount(AccountModel model) async {
    try {
      await _col(model.userId).doc(model.id).update(model.toFirestore());
      return model;
    } catch (e, st) {
      AppLogger.error('AccountDS.update', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> deleteAccount(String userId, String id) async {
    try {
      await _col(userId).doc(id).delete();
    } catch (e, st) {
      AppLogger.error('AccountDS.delete', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> adjustBalance(
    String userId,
    String accountId,
    int delta,
  ) async {
    try {
      await _col(userId)
          .doc(accountId)
          .update({'balance': FieldValue.increment(delta)});
    } catch (e, st) {
      AppLogger.error('AccountDS.adjustBalance', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<int> getTotalBalance(String userId) async {
    try {
      final snap = await _col(userId)
          .where('includeInTotal', isEqualTo: true)
          .get();
      return snap.docs
          .map((d) => d.data()['balance'] as int? ?? 0)
          .fold<int>(0, (acc, b) => acc + b);
    } catch (e, st) {
      AppLogger.error('AccountDS.getTotalBalance', e, st);
      throw const UnexpectedException();
    }
  }
}
