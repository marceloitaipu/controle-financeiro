// lib/features/credit_cards/presentation/widgets/credit_card_widget.dart

import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/credit_card.dart';

/// Widget visual de cartão de crédito.
///
/// Exibe nome, bandeira, últimos 4 dígitos e limite.
/// [usedAmount] (em centavos) exibe o valor usado e uma barra de progresso.
class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    super.key,
    required this.card,
    this.usedAmount,
    this.height = 180,
  });

  final CreditCard card;

  /// Total já usado na fatura (em centavos). null = não exibe barra de uso.
  final int? usedAmount;

  final double height;

  Color get _baseColor {
    try {
      return Color(
        int.parse('FF${card.colorHex.replaceFirst('#', '')}', radix: 16),
      );
    } catch (_) {
      return const Color(0xFF6750A4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = _baseColor;
    final dark = HSLColor.fromColor(base)
        .withLightness(
          (HSLColor.fromColor(base).lightness - 0.15).clamp(0.0, 1.0),
        )
        .toColor();

    final usedRatio = (usedAmount != null && card.creditLimit > 0)
        ? (usedAmount! / card.creditLimit).clamp(0.0, 1.0)
        : null;

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [dark, base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nome + bandeira ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  card.brand.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Últimos 4 dígitos ─────────────────────────────────────────────
          Text(
            '•••• •••• •••• ${card.lastFourDigits}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 3,
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 12),

          // ── Limite + usado ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LabelValue(
                label: 'LIMITE',
                value: CurrencyFormatter.format(card.creditLimit),
              ),
              if (usedAmount != null)
                _LabelValue(
                  label: 'USADO',
                  value: CurrencyFormatter.format(usedAmount!),
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
            ],
          ),

          // ── Barra de uso ──────────────────────────────────────────────────
          if (usedRatio != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usedRatio,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
