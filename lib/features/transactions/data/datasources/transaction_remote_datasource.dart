// lib/features/transactions/data/datasources/transaction_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

abstract interface class TransactionRemoteDataSource {
  Stream<List<TransactionModel>> watchTransactions(
    String userId, {
    TransactionFilter? filter,
  });

  Future<TransactionModel> getTransactionById(String userId, String id);

  /// Cria a transação e aplica o delta no saldo da conta — tudo em batch.
  Future<TransactionModel> createTransaction(TransactionModel model);

  /// Cria múltiplas transações atomicamente em um único WriteBatch.
  /// Ideal para parcelas de cartão de crédito — garante que todas ou nenhuma
  /// seja persistida.
  Future<List<TransactionModel>> createTransactionsBatch(
    List<TransactionModel> models,
  );

  /// Atualiza a transação e reajusta saldos — tudo em batch.
  Future<TransactionModel> updateTransaction(
    TransactionModel model,
    TransactionModel oldModel,
  );

  /// Remove a transação e reverte saldo — tudo em batch.
  Future<void> deleteTransaction(TransactionModel model);

  Future<int> sumAmount(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
    required TransactionType type,
  });
}

final class TransactionRemoteDataSourceImpl
    implements TransactionRemoteDataSource {
  TransactionRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _txCol(String userId) =>
      firestore.collection('users').doc(userId).collection('transactions');

  DocumentReference<Map<String, dynamic>> _accountRef(
    String userId,
    String accountId,
  ) =>
      firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(accountId);

  @override
  Stream<List<TransactionModel>> watchTransactions(
    String userId, {
    TransactionFilter? filter,
  }) {
    Query<Map<String, dynamic>> q = _txCol(userId);

    if (filter != null) {
      if (filter.startDate != null) {
        q = q.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(filter.startDate!));
      }
      if (filter.endDate != null) {
        q = q.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(filter.endDate!));
      }
      if (filter.type != null) {
        q = q.where('type', isEqualTo: filter.type!.name);
      }
      if (filter.accountId != null) {
        q = q.where('accountId', isEqualTo: filter.accountId);
      }
      if (filter.categoryId != null) {
        q = q.where('categoryId', isEqualTo: filter.categoryId);
      }
      if (filter.status != null) {
        q = q.where('status', isEqualTo: filter.status!.name);
      }
      if (filter.creditCardId != null) {
        q = q.where('creditCardId', isEqualTo: filter.creditCardId);
      }
    }

    return q
        .orderBy('date', descending: true)
        .limit(filter?.limit ?? 50)
        .snapshots()
        .map((s) => s.docs.map(TransactionModel.fromFirestore).toList());
  }

  @override
  Future<TransactionModel> getTransactionById(
    String userId,
    String id,
  ) async {
    try {
      final doc = await _txCol(userId).doc(id).get();
      if (!doc.exists) {
        throw const NotFoundException('Transação não encontrada.');
      }
      return TransactionModel.fromFirestore(doc);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('TransactionDS.getById', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel model) async {
    try {
      final ref = model.id.isEmpty
          ? _txCol(model.userId).doc()
          : _txCol(model.userId).doc(model.id);
      final toSave = model.id.isEmpty
          ? TransactionModel.fromEntity(model.toEntity().copyWith(id: ref.id))
          : model;

      final batch = firestore.batch();
      batch.set(ref, toSave.toFirestore());

      // Ajusta saldo da conta de forma atômica.
      // Compras no cartão de crédito têm accountId vazio — pula atualização.
      if (toSave.accountId.isNotEmpty) {
        final delta = _balanceDelta(toSave.type, toSave.amount);
        batch.update(
          _accountRef(model.userId, toSave.accountId),
          {'balance': FieldValue.increment(delta)},
        );
        // Transferência: credita na conta de destino
        if (toSave.type == TransactionType.transfer &&
            toSave.destinationAccountId != null) {
          batch.update(
            _accountRef(model.userId, toSave.destinationAccountId!),
            {'balance': FieldValue.increment(toSave.amount)},
          );
        }
      }

      await batch.commit();
      return toSave;
    } catch (e, st) {
      AppLogger.error('TransactionDS.create', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<List<TransactionModel>> createTransactionsBatch(
    List<TransactionModel> models,
  ) async {
    try {
      final batch = firestore.batch();
      final savedModels = <TransactionModel>[];

      for (final model in models) {
        final ref = model.id.isEmpty
            ? _txCol(model.userId).doc()
            : _txCol(model.userId).doc(model.id);
        final toSave = model.id.isEmpty
            ? TransactionModel.fromEntity(
                model.toEntity().copyWith(id: ref.id))
            : model;
        batch.set(ref, toSave.toFirestore());
        // accountId vazio = compra no cartão — sem atualização de saldo
        savedModels.add(toSave);
      }

      await batch.commit();
      return savedModels;
    } catch (e, st) {
      AppLogger.error('TransactionDS.createBatch', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel model,
    TransactionModel oldModel,
  ) async {
    try {
      final batch = firestore.batch();
      batch.update(
        _txCol(model.userId).doc(model.id),
        model.toFirestore(),
      );

      // Reverte saldo anterior e aplica o novo.
      // Compras no cartão de crédito têm accountId vazio — pula atualização.
      final oldDelta = _balanceDelta(oldModel.type, oldModel.amount);
      final newDelta = _balanceDelta(model.type, model.amount);

      // ── Conta de origem ──────────────────────────────────────────────
      if (oldModel.accountId.isEmpty && model.accountId.isEmpty) {
        // Ambas são compras de cartão — sem atualização de conta
      } else if (oldModel.accountId == model.accountId &&
          model.accountId.isNotEmpty) {
        // Mesma conta: ajusta a diferença
        batch.update(
          _accountRef(model.userId, model.accountId),
          {'balance': FieldValue.increment(-oldDelta + newDelta)},
        );
      } else {
        // Conta mudou: reverte na antiga, aplica na nova
        if (oldModel.accountId.isNotEmpty) {
          batch.update(
            _accountRef(model.userId, oldModel.accountId),
            {'balance': FieldValue.increment(-oldDelta)},
          );
        }
        if (model.accountId.isNotEmpty) {
          batch.update(
            _accountRef(model.userId, model.accountId),
            {'balance': FieldValue.increment(newDelta)},
          );
        }
      }

      // ── Conta de destino (transferências) ────────────────────────────
      final oldDest = oldModel.destinationAccountId;
      final newDest = model.destinationAccountId;
      final wasTransfer = oldModel.type == TransactionType.transfer;
      final isTransfer = model.type == TransactionType.transfer;

      if (wasTransfer || isTransfer) {
        if (oldDest == newDest && newDest != null) {
          // Mesma conta de destino: ajusta diferença de valor
          batch.update(
            _accountRef(model.userId, newDest),
            {
              'balance': FieldValue.increment(
                -oldModel.amount + model.amount,
              )
            },
          );
        } else {
          // Conta de destino mudou ou transferência foi criada/removida
          if (oldDest != null) {
            batch.update(
              _accountRef(model.userId, oldDest),
              {'balance': FieldValue.increment(-oldModel.amount)},
            );
          }
          if (newDest != null) {
            batch.update(
              _accountRef(model.userId, newDest),
              {'balance': FieldValue.increment(model.amount)},
            );
          }
        }
      }

      await batch.commit();
      return model;
    } catch (e, st) {
      AppLogger.error('TransactionDS.update', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> deleteTransaction(TransactionModel model) async {
    try {
      final batch = firestore.batch();
      batch.delete(_txCol(model.userId).doc(model.id));

      // Reverte o efeito no saldo da conta.
      // Compras no cartão de crédito têm accountId vazio — pula reversão.
      if (model.accountId.isNotEmpty) {
        final delta = _balanceDelta(model.type, model.amount);
        batch.update(
          _accountRef(model.userId, model.accountId),
          {'balance': FieldValue.increment(-delta)},
        );
        // Transferência: reverte na conta de destino
        if (model.type == TransactionType.transfer &&
            model.destinationAccountId != null) {
          batch.update(
            _accountRef(model.userId, model.destinationAccountId!),
            {'balance': FieldValue.increment(-model.amount)},
          );
        }
      }

      await batch.commit();
    } catch (e, st) {
      AppLogger.error('TransactionDS.delete', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<int> sumAmount(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
    required TransactionType type,
  }) async {
    try {
      final snap = await _txCol(userId)
          .where('type', isEqualTo: type.name)
          .where('status', isEqualTo: TransactionStatus.completed.name)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      return snap.docs
          .map((d) => d.data()['amount'] as int? ?? 0)
          .fold<int>(0, (s, a) => s + a);
    } catch (e, st) {
      AppLogger.error('TransactionDS.sumAmount', e, st);
      throw const UnexpectedException();
    }
  }

  /// +amount para receita/destino de transferência, -amount para despesa/origem.
  int _balanceDelta(TransactionType type, int amount) => switch (type) {
        TransactionType.income => amount,
        TransactionType.expense => -amount,
        TransactionType.transfer => -amount, // origem perde
      };
}
