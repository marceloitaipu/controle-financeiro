// lib/features/credit_cards/domain/entities/invoice.dart

import 'package:equatable/equatable.dart';

enum InvoiceStatus { open, closed, paid }

extension InvoiceStatusLabel on InvoiceStatus {
  String get label => switch (this) {
        InvoiceStatus.open => 'Aberta',
        InvoiceStatus.closed => 'Fechada',
        InvoiceStatus.paid => 'Paga',
      };
}

/// Representa uma fatura mensal de cartão de crédito.
final class Invoice extends Equatable {
  const Invoice({
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

  /// Formato: 'YYYY-MM' (ex: '2026-04')
  final String yearMonth;

  final DateTime closingDate;
  final DateTime dueDate;

  /// Total da fatura em centavos.
  final int totalAmount;

  final InvoiceStatus status;
  final DateTime? paidAt;
  final String? paymentTransactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  double get totalAmountInReais => totalAmount / 100;

  Invoice copyWith({
    String? id,
    String? userId,
    String? creditCardId,
    String? yearMonth,
    DateTime? closingDate,
    DateTime? dueDate,
    int? totalAmount,
    InvoiceStatus? status,
    DateTime? paidAt,
    String? paymentTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      creditCardId: creditCardId ?? this.creditCardId,
      yearMonth: yearMonth ?? this.yearMonth,
      closingDate: closingDate ?? this.closingDate,
      dueDate: dueDate ?? this.dueDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      paymentTransactionId:
          paymentTransactionId ?? this.paymentTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, creditCardId, yearMonth, closingDate, dueDate,
        totalAmount, status, paidAt, paymentTransactionId,
        createdAt, updatedAt,
      ];
}
