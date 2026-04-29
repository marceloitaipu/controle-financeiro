// lib/features/credit_cards/data/datasources/credit_card_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/invoice.dart';
import '../models/credit_card_model.dart';
import '../models/invoice_model.dart';

abstract interface class CreditCardRemoteDataSource {
  Stream<List<CreditCardModel>> watchCreditCards(String userId);
  Future<CreditCardModel> getCreditCardById(String userId, String id);
  Future<CreditCardModel> createCreditCard(CreditCardModel model);
  Future<CreditCardModel> updateCreditCard(CreditCardModel model);
  Future<void> deleteCreditCard(String userId, String id);

  Future<InvoiceModel> getOrCreateInvoice({
    required String userId,
    required String cardId,
    required String yearMonth,
    required DateTime closingDate,
    required DateTime dueDate,
  });

  Stream<List<InvoiceModel>> watchInvoices(String userId, String cardId);

  Future<InvoiceModel?> getInvoiceByYearMonth({
    required String userId,
    required String cardId,
    required String yearMonth,
  });

  Future<void> addToInvoiceTotal({
    required String userId,
    required String cardId,
    required String yearMonth,
    required int amount,
  });

  Future<void> payInvoice({
    required String userId,
    required String cardId,
    required String yearMonth,
    required String paymentTransactionId,
  });
}

final class CreditCardRemoteDataSourceImpl
    implements CreditCardRemoteDataSource {
  CreditCardRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _cardCol(String userId) =>
      firestore.collection('users').doc(userId).collection('credit_cards');

  CollectionReference<Map<String, dynamic>> _invoiceCol(
    String userId,
    String cardId,
  ) =>
      _cardCol(userId).doc(cardId).collection('invoices');

  @override
  Stream<List<CreditCardModel>> watchCreditCards(String userId) {
    return _cardCol(userId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map(CreditCardModel.fromFirestore).toList());
  }

  @override
  Future<CreditCardModel> getCreditCardById(
    String userId,
    String id,
  ) async {
    try {
      final doc = await _cardCol(userId).doc(id).get();
      if (!doc.exists) throw const NotFoundException('Cartão não encontrado.');
      return CreditCardModel.fromFirestore(doc);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('CreditCardDS.getById', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<CreditCardModel> createCreditCard(CreditCardModel model) async {
    try {
      final ref = model.id.isEmpty
          ? _cardCol(model.userId).doc()
          : _cardCol(model.userId).doc(model.id);
      final toSave = model.id.isEmpty
          ? CreditCardModel.fromEntity(
              model.toEntity().copyWith(id: ref.id))
          : model;
      await ref.set(toSave.toFirestore());
      return toSave;
    } catch (e, st) {
      AppLogger.error('CreditCardDS.create', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<CreditCardModel> updateCreditCard(CreditCardModel model) async {
    try {
      await _cardCol(model.userId).doc(model.id).update(model.toFirestore());
      return model;
    } catch (e, st) {
      AppLogger.error('CreditCardDS.update', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> deleteCreditCard(String userId, String id) async {
    try {
      await _cardCol(userId).doc(id).update({'isActive': false});
    } catch (e, st) {
      AppLogger.error('CreditCardDS.delete', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<InvoiceModel> getOrCreateInvoice({
    required String userId,
    required String cardId,
    required String yearMonth,
    required DateTime closingDate,
    required DateTime dueDate,
  }) async {
    try {
      final existing = await getInvoiceByYearMonth(
        userId: userId,
        cardId: cardId,
        yearMonth: yearMonth,
      );
      if (existing != null) return existing;

      final ref = _invoiceCol(userId, cardId).doc(yearMonth);
      final model = InvoiceModel(
        id: yearMonth,
        userId: userId,
        creditCardId: cardId,
        yearMonth: yearMonth,
        closingDate: closingDate,
        dueDate: dueDate,
        totalAmount: 0,
        status: InvoiceStatus.open,
        createdAt: DateTime.now(),
      );
      await ref.set(model.toFirestore());
      return model;
    } catch (e, st) {
      AppLogger.error('CreditCardDS.getOrCreateInvoice', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Stream<List<InvoiceModel>> watchInvoices(
    String userId,
    String cardId,
  ) {
    return _invoiceCol(userId, cardId)
        .orderBy('yearMonth', descending: true)
        .snapshots()
        .map((s) => s.docs.map(InvoiceModel.fromFirestore).toList());
  }

  @override
  Future<InvoiceModel?> getInvoiceByYearMonth({
    required String userId,
    required String cardId,
    required String yearMonth,
  }) async {
    try {
      final doc = await _invoiceCol(userId, cardId).doc(yearMonth).get();
      if (!doc.exists) return null;
      return InvoiceModel.fromFirestore(doc);
    } catch (e, st) {
      AppLogger.error('CreditCardDS.getInvoiceByYearMonth', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> addToInvoiceTotal({
    required String userId,
    required String cardId,
    required String yearMonth,
    required int amount,
  }) async {
    try {
      await _invoiceCol(userId, cardId)
          .doc(yearMonth)
          .update({'totalAmount': FieldValue.increment(amount)});
    } catch (e, st) {
      AppLogger.error('CreditCardDS.addToInvoiceTotal', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> payInvoice({
    required String userId,
    required String cardId,
    required String yearMonth,
    required String paymentTransactionId,
  }) async {
    try {
      await _invoiceCol(userId, cardId).doc(yearMonth).update({
        'status': InvoiceStatus.paid.name,
        'paidAt': FieldValue.serverTimestamp(),
        'paymentTransactionId': paymentTransactionId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      AppLogger.error('CreditCardDS.payInvoice', e, st);
      throw const UnexpectedException();
    }
  }
}
