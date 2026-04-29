// lib/features/accounts/domain/entities/account.dart

import 'package:equatable/equatable.dart';

/// Tipo de conta financeira.
enum AccountType {
  /// Conta corrente bancária
  checking,

  /// Conta poupança
  savings,

  /// Carteira física / dinheiro em espécie
  wallet,

  /// Investimento (CDB, Tesouro, etc.)
  investment,

  /// Outro tipo não classificado
  other,
}

extension AccountTypeLabel on AccountType {
  String get label => switch (this) {
        AccountType.checking => 'Conta Corrente',
        AccountType.savings => 'Poupança',
        AccountType.wallet => 'Carteira',
        AccountType.investment => 'Investimento',
        AccountType.other => 'Outro',
      };

  String get iconName => switch (this) {
        AccountType.checking => 'account_balance',
        AccountType.savings => 'savings',
        AccountType.wallet => 'account_balance_wallet',
        AccountType.investment => 'trending_up',
        AccountType.other => 'attach_money',
      };
}

/// Entidade imutável de domínio para contas financeiras.
final class Account extends Equatable {
  const Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.colorHex,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.bankName,
    this.includeInTotal = true,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final AccountType type;

  /// Saldo atual em centavos (evita ponto flutuante).
  final int balance;

  final String colorHex;
  final int iconCodePoint;
  final String iconFontFamily;

  /// Nome do banco (opcional).
  final String? bankName;

  /// Se false, esta conta é excluída do saldo total no dashboard.
  final bool includeInTotal;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Saldo em reais (converte de centavos).
  double get balanceInReais => balance / 100;

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    int? balance,
    String? colorHex,
    int? iconCodePoint,
    String? iconFontFamily,
    String? bankName,
    bool? includeInTotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      bankName: bankName ?? this.bankName,
      includeInTotal: includeInTotal ?? this.includeInTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        balance,
        colorHex,
        iconCodePoint,
        iconFontFamily,
        bankName,
        includeInTotal,
        createdAt,
        updatedAt,
      ];
}
