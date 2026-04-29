// lib/features/credit_cards/data/models/credit_card_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/credit_card.dart';

final class CreditCardModel {
  const CreditCardModel({
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
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final CardBrand brand;
  final String lastFourDigits;
  final int creditLimit;
  final int closingDay;
  final int dueDay;
  final String colorHex;
  final String? paymentAccountId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory CreditCardModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return CreditCardModel(
      id: doc.id,
      userId: d['userId'] as String,
      name: d['name'] as String,
      brand: CardBrand.values.firstWhere(
        (e) => e.name == d['brand'],
        orElse: () => CardBrand.other,
      ),
      lastFourDigits: d['lastFourDigits'] as String,
      creditLimit: d['creditLimit'] as int,
      closingDay: d['closingDay'] as int,
      dueDay: d['dueDay'] as int,
      colorHex: d['colorHex'] as String? ?? '#1565C0',
      paymentAccountId: d['paymentAccountId'] as String?,
      isActive: d['isActive'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory CreditCardModel.fromEntity(CreditCard e) => CreditCardModel(
        id: e.id,
        userId: e.userId,
        name: e.name,
        brand: e.brand,
        lastFourDigits: e.lastFourDigits,
        creditLimit: e.creditLimit,
        closingDay: e.closingDay,
        dueDay: e.dueDay,
        colorHex: e.colorHex,
        paymentAccountId: e.paymentAccountId,
        isActive: e.isActive,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'name': name,
        'brand': brand.name,
        'lastFourDigits': lastFourDigits,
        'creditLimit': creditLimit,
        'closingDay': closingDay,
        'dueDay': dueDay,
        'colorHex': colorHex,
        if (paymentAccountId != null) 'paymentAccountId': paymentAccountId,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  CreditCard toEntity() => CreditCard(
        id: id,
        userId: userId,
        name: name,
        brand: brand,
        lastFourDigits: lastFourDigits,
        creditLimit: creditLimit,
        closingDay: closingDay,
        dueDay: dueDay,
        colorHex: colorHex,
        paymentAccountId: paymentAccountId,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
