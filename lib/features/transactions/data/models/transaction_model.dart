// lib/features/transactions/data/models/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../domain/entities/transaction.dart';

final class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.accountId,
    this.destinationAccountId,
    this.categoryId,
    this.creditCardId,
    required this.status,
    required this.recurrence,
    this.recurrenceGroupId,
    required this.isInstallment,
    this.installmentNumber,
    this.totalInstallments,
    this.notes,
    required this.attachmentUrls,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final DateTime date;
  final String description;
  final String accountId;
  final String? destinationAccountId;
  final String? categoryId;
  final String? creditCardId;
  final TransactionStatus status;
  final RecurrenceType recurrence;
  final String? recurrenceGroupId;
  final bool isInstallment;
  final int? installmentNumber;
  final int? totalInstallments;
  final String? notes;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TransactionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return TransactionModel(
      id: doc.id,
      userId: d['userId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == d['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: d['amount'] as int,
      date: (d['date'] as Timestamp).toDate(),
      description: d['description'] as String,
      accountId: d['accountId'] as String,
      destinationAccountId: d['destinationAccountId'] as String?,
      categoryId: d['categoryId'] as String?,
      creditCardId: d['creditCardId'] as String?,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == d['status'],
        orElse: () => TransactionStatus.completed,
      ),
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.name == d['recurrence'],
        orElse: () => RecurrenceType.none,
      ),
      recurrenceGroupId: d['recurrenceGroupId'] as String?,
      isInstallment: d['isInstallment'] as bool? ?? false,
      installmentNumber: d['installmentNumber'] as int?,
      totalInstallments: d['totalInstallments'] as int?,
      notes: d['notes'] as String?,
      attachmentUrls: List<String>.from(d['attachmentUrls'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory TransactionModel.fromEntity(Transaction e) => TransactionModel(
        id: e.id,
        userId: e.userId,
        type: e.type,
        amount: e.amount,
        date: e.date,
        description: e.description,
        accountId: e.accountId,
        destinationAccountId: e.destinationAccountId,
        categoryId: e.categoryId,
        creditCardId: e.creditCardId,
        status: e.status,
        recurrence: e.recurrence,
        recurrenceGroupId: e.recurrenceGroupId,
        isInstallment: e.isInstallment,
        installmentNumber: e.installmentNumber,
        totalInstallments: e.totalInstallments,
        notes: e.notes,
        attachmentUrls: e.attachmentUrls,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type.name,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'description': description,
        'accountId': accountId,
        if (destinationAccountId != null)
          'destinationAccountId': destinationAccountId,
        if (categoryId != null) 'categoryId': categoryId,
        if (creditCardId != null) 'creditCardId': creditCardId,
        'status': status.name,
        'recurrence': recurrence.name,
        if (recurrenceGroupId != null) 'recurrenceGroupId': recurrenceGroupId,
        'isInstallment': isInstallment,
        if (installmentNumber != null) 'installmentNumber': installmentNumber,
        if (totalInstallments != null) 'totalInstallments': totalInstallments,
        if (notes != null) 'notes': notes,
        'attachmentUrls': attachmentUrls,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Transaction toEntity() => Transaction(
        id: id,
        userId: userId,
        type: type,
        amount: amount,
        date: date,
        description: description,
        accountId: accountId,
        destinationAccountId: destinationAccountId,
        categoryId: categoryId,
        creditCardId: creditCardId,
        status: status,
        recurrence: recurrence,
        recurrenceGroupId: recurrenceGroupId,
        isInstallment: isInstallment,
        installmentNumber: installmentNumber,
        totalInstallments: totalInstallments,
        notes: notes,
        attachmentUrls: attachmentUrls,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
