// lib/features/credit_cards/domain/entities/credit_card.dart

import 'package:equatable/equatable.dart';

/// Bandeira do cartão de crédito.
enum CardBrand { visa, mastercard, elo, amex, hipercard, other }

extension CardBrandLabel on CardBrand {
  String get label => switch (this) {
        CardBrand.visa => 'Visa',
        CardBrand.mastercard => 'Mastercard',
        CardBrand.elo => 'Elo',
        CardBrand.amex => 'American Express',
        CardBrand.hipercard => 'Hipercard',
        CardBrand.other => 'Outra',
      };
}

/// Entidade imutável de domínio para cartões de crédito.
final class CreditCard extends Equatable {
  const CreditCard({
    required this.id,
    required this.userId,
    required this.name,
    required this.brand,
    required this.lastFourDigits,
    required this.creditLimit,
    required this.closingDay,
    required this.dueDay,
    required this.colorHex,
    this.paymentAccountId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final CardBrand brand;

  /// Últimos 4 dígitos do cartão (ex: '1234').
  final String lastFourDigits;

  /// Limite de crédito em centavos.
  final int creditLimit;

  /// Dia do mês em que a fatura fecha (1–28).
  final int closingDay;

  /// Dia do mês em que a fatura vence (1–28).
  final int dueDay;

  final String colorHex;

  /// Conta bancária padrão para pagamento da fatura.
  final String? paymentAccountId;

  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Limite em reais.
  double get creditLimitInReais => creditLimit / 100;

  CreditCard copyWith({
    String? id,
    String? userId,
    String? name,
    CardBrand? brand,
    String? lastFourDigits,
    int? creditLimit,
    int? closingDay,
    int? dueDay,
    String? colorHex,
    String? paymentAccountId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      creditLimit: creditLimit ?? this.creditLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      colorHex: colorHex ?? this.colorHex,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, name, brand, lastFourDigits, creditLimit,
        closingDay, dueDay, colorHex, paymentAccountId, isActive,
        createdAt, updatedAt,
      ];
}
