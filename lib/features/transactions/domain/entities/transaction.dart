// lib/features/transactions/domain/entities/transaction.dart

import 'package:equatable/equatable.dart';

/// Tipo de movimento financeiro.
enum TransactionType { income, expense, transfer }

extension TransactionTypeLabel on TransactionType {
  String get label => switch (this) {
        TransactionType.income => 'Receita',
        TransactionType.expense => 'Despesa',
        TransactionType.transfer => 'Transferência',
      };
}

/// Status de uma transação (útil para transações futuras/agendadas).
enum TransactionStatus { pending, completed, cancelled }

extension TransactionStatusLabel on TransactionStatus {
  String get label => switch (this) {
        TransactionStatus.pending => 'Pendente',
        TransactionStatus.completed => 'Concluída',
        TransactionStatus.cancelled => 'Cancelada',
      };
}

/// Recorrência de uma transação.
enum RecurrenceType { none, daily, weekly, monthly, yearly }

extension RecurrenceTypeLabel on RecurrenceType {
  String get label => switch (this) {
        RecurrenceType.none => 'Não repete',
        RecurrenceType.daily => 'Diário',
        RecurrenceType.weekly => 'Semanal',
        RecurrenceType.monthly => 'Mensal',
        RecurrenceType.yearly => 'Anual',
      };
}

/// Entidade imutável de domínio para transações financeiras.
final class Transaction extends Equatable {
  const Transaction({
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
    this.status = TransactionStatus.completed,
    this.recurrence = RecurrenceType.none,
    this.recurrenceGroupId,
    this.isInstallment = false,
    this.installmentNumber,
    this.totalInstallments,
    this.notes,
    this.attachmentUrls = const [],
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final TransactionType type;

  /// Valor em centavos.
  final int amount;

  final DateTime date;
  final String description;

  /// Conta debitada (ou de origem em transferências).
  final String accountId;

  /// Conta de destino (somente para transferências).
  final String? destinationAccountId;

  /// Categoria da transação (null para transferências).
  final String? categoryId;

  /// Cartão de crédito vinculado (quando pago via cartão).
  final String? creditCardId;

  final TransactionStatus status;
  final RecurrenceType recurrence;

  /// ID do grupo de recorrência (todas as repetições compartilham este ID).
  final String? recurrenceGroupId;

  final bool isInstallment;
  final int? installmentNumber;
  final int? totalInstallments;
  final String? notes;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Valor em reais.
  double get amountInReais => amount / 100;

  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    DateTime? date,
    String? description,
    String? accountId,
    String? destinationAccountId,
    String? categoryId,
    String? creditCardId,
    TransactionStatus? status,
    RecurrenceType? recurrence,
    String? recurrenceGroupId,
    bool? isInstallment,
    int? installmentNumber,
    int? totalInstallments,
    String? notes,
    List<String>? attachmentUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      accountId: accountId ?? this.accountId,
      destinationAccountId:
          destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      creditCardId: creditCardId ?? this.creditCardId,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      isInstallment: isInstallment ?? this.isInstallment,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      notes: notes ?? this.notes,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        date,
        description,
        accountId,
        destinationAccountId,
        categoryId,
        creditCardId,
        status,
        recurrence,
        recurrenceGroupId,
        isInstallment,
        installmentNumber,
        totalInstallments,
        notes,
        attachmentUrls,
        createdAt,
        updatedAt,
      ];
}
