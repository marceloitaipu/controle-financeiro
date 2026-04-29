// lib/features/credit_cards/data/models/invoice_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/invoice.dart';

final class InvoiceModel {
  const InvoiceModel({
    required this.id,
    required this.userId,
    required this.creditCardId,
    required this.yearMonth,
    required this.closingDate,
    required this.dueDate,
    required this.totalAmount,
    required this.status,
    this.paidAt,
    this.paymentTransactionId,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String creditCardId;
  final String yearMonth;
  final DateTime closingDate;
  final DateTime dueDate;
  final int totalAmount;
  final InvoiceStatus status;
  final DateTime? paidAt;
  final String? paymentTransactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory InvoiceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return InvoiceModel(
      id: doc.id,
      userId: d['userId'] as String,
      creditCardId: d['creditCardId'] as String,
      yearMonth: d['yearMonth'] as String,
      closingDate: (d['closingDate'] as Timestamp).toDate(),
      dueDate: (d['dueDate'] as Timestamp).toDate(),
      totalAmount: d['totalAmount'] as int? ?? 0,
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == d['status'],
        orElse: () => InvoiceStatus.open,
      ),
      paidAt: d['paidAt'] != null
          ? (d['paidAt'] as Timestamp).toDate()
          : null,
      paymentTransactionId: d['paymentTransactionId'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory InvoiceModel.fromEntity(Invoice e) => InvoiceModel(
        id: e.id,
        userId: e.userId,
        creditCardId: e.creditCardId,
        yearMonth: e.yearMonth,
        closingDate: e.closingDate,
        dueDate: e.dueDate,
        totalAmount: e.totalAmount,
        status: e.status,
        paidAt: e.paidAt,
        paymentTransactionId: e.paymentTransactionId,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'creditCardId': creditCardId,
        'yearMonth': yearMonth,
        'closingDate': Timestamp.fromDate(closingDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'totalAmount': totalAmount,
        'status': status.name,
        if (paidAt != null) 'paidAt': Timestamp.fromDate(paidAt!),
        if (paymentTransactionId != null)
          'paymentTransactionId': paymentTransactionId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Invoice toEntity() => Invoice(
        id: id,
        userId: userId,
        creditCardId: creditCardId,
        yearMonth: yearMonth,
        closingDate: closingDate,
        dueDate: dueDate,
        totalAmount: totalAmount,
        status: status,
        paidAt: paidAt,
        paymentTransactionId: paymentTransactionId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
