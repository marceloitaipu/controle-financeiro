// lib/features/accounts/data/models/account_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/account.dart';

final class AccountModel {
  const AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.colorHex,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.bankName,
    required this.includeInTotal,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final int balance;
  final String colorHex;
  final int iconCodePoint;
  final String iconFontFamily;
  final String? bankName;
  final bool includeInTotal;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory AccountModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return AccountModel(
      id: doc.id,
      userId: d['userId'] as String,
      name: d['name'] as String,
      type: AccountType.values.firstWhere(
        (e) => e.name == d['type'],
        orElse: () => AccountType.other,
      ),
      balance: d['balance'] as int? ?? 0,
      colorHex: d['colorHex'] as String? ?? '#1565C0',
      iconCodePoint: d['iconCodePoint'] as int,
      iconFontFamily: d['iconFontFamily'] as String? ?? 'MaterialIcons',
      bankName: d['bankName'] as String?,
      includeInTotal: d['includeInTotal'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory AccountModel.fromEntity(Account e) => AccountModel(
        id: e.id,
        userId: e.userId,
        name: e.name,
        type: e.type,
        balance: e.balance,
        colorHex: e.colorHex,
        iconCodePoint: e.iconCodePoint,
        iconFontFamily: e.iconFontFamily,
        bankName: e.bankName,
        includeInTotal: e.includeInTotal,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'name': name,
        'type': type.name,
        'balance': balance,
        'colorHex': colorHex,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        if (bankName != null) 'bankName': bankName,
        'includeInTotal': includeInTotal,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Account toEntity() => Account(
        id: id,
        userId: userId,
        name: name,
        type: type,
        balance: balance,
        colorHex: colorHex,
        iconCodePoint: iconCodePoint,
        iconFontFamily: iconFontFamily,
        bankName: bankName,
        includeInTotal: includeInTotal,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
