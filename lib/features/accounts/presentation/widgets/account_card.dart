// lib/features/accounts/presentation/widgets/account_card.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/account.dart';

/// Card de conta financeira — versão de lista (maior que o do carousel).
///
/// Exibe: ícone colorido, nome, tipo, banco (opcional), saldo.
/// Quando [isBalanceVisible] == false, substitui o saldo por "••••••".
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    this.isBalanceVisible = true,
    this.onTap,
  });

  final Account account;
  final bool isBalanceVisible;
  final VoidCallback? onTap;

  Color get _color {
    final hex = account.colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get _icon => IconData(
        account.iconCodePoint,
        fontFamily: account.iconFontFamily,
      );

  @override
  Widget build(BuildContext context) {
    final cardColor = _color;
    final balanceColor =
        account.balance >= 0 ? Colors.white : Colors.white.withValues(alpha: 0.7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.cardRadius,
            boxShadow: AppShadows.md,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Linha superior: ícone + tipo + badge ──────────────────
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        _icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            account.bankName != null
                                ? '${account.type.label} · ${account.bankName}'
                                : account.type.label,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!account.includeInTotal)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Text(
                          'Excluída do total',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Saldo ─────────────────────────────────────────────────
                Text(
                  'Saldo atual',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBalanceVisible
                      ? CurrencyFormatter.format(account.balance)
                      : '• • • • • •',
                  style: TextStyle(
                    color: balanceColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
