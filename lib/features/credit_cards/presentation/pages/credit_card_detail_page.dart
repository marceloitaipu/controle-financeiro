// lib/features/credit_cards/presentation/pages/credit_card_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/invoice.dart';
import '../providers/credit_card_providers.dart';
import '../widgets/credit_card_widget.dart';

/// Detalhe de um cartão de crédito com fatura atual e histórico.
class CreditCardDetailPage extends ConsumerWidget {
  const CreditCardDetailPage({
    super.key,
    required this.cardId,
    this.creditCard,
  });

  final String cardId;

  /// Cartão passado via navegação para evitar loading extra.
  final CreditCard? creditCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(watchInvoicesProvider(cardId));
    final colorScheme = Theme.of(context).colorScheme;

    // Tenta usar o cartão passado ou procura na stream
    final cardsAsync = ref.watch(watchCreditCardsProvider);
    final card = creditCard ??
        cardsAsync.valueOrNull?.where((c) => c.id == cardId).firstOrNull;

    if (card == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final now = DateTime.now();
    final currentYearMonth = computeInvoiceYearMonth(now, card.closingDay);

    final invoices = invoicesAsync.valueOrNull ?? [];
    Invoice? currentInvoice;
    try {
      currentInvoice =
          invoices.firstWhere((inv) => inv.yearMonth == currentYearMonth);
    } catch (_) {
      currentInvoice = null;
    }

    final pastInvoices = invoices
        .where((inv) => inv.yearMonth != currentYearMonth)
        .toList()
      ..sort((a, b) => b.yearMonth.compareTo(a.yearMonth));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar cartão',
            onPressed: () => context.pushNamed(
              AppRoutes.creditCardNewName,
              extra: card,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir cartão',
            onPressed: () => _confirmDelete(context, ref, card),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(
          AppRoutes.transactionNewName,
          queryParameters: {'type': 'expense'},
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova compra'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        children: [
          // ── Cartão visual ─────────────────────────────────────────────────
          Hero(
            tag: 'card_$cardId',
            child: CreditCardWidget(
              card: card,
              usedAmount: currentInvoice?.totalAmount,
            ),
          ),
          const SizedBox(height: AppSpacing.xl2),

          // ── Fatura atual ──────────────────────────────────────────────────
          Text(
            'FATURA ATUAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InvoiceCard(
            invoice: currentInvoice,
            yearMonth: currentYearMonth,
            cardId: cardId,
            card: card,
            isCurrent: true,
          ),

          // ── Histórico de faturas ──────────────────────────────────────────
          if (pastInvoices.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl2),
            Text(
              'HISTÓRICO DE FATURAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...pastInvoices.map(
              (inv) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _InvoiceCard(
                  invoice: inv,
                  yearMonth: inv.yearMonth,
                  cardId: cardId,
                  card: card,
                  isCurrent: false,
                ),
              ),
            ),
          ],

          if (invoicesAsync.isLoading)
            Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surfaceContainerLow,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.xl3 + 72),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CreditCard card,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cartão?'),
        content: Text(
          'O cartão "${card.name}" será desativado. '
          'As transações existentes não serão afetadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(creditCardNotifierProvider.notifier)
          .deleteCreditCard(card.id);
      if (success && context.mounted) {
        context.pop();
      }
    }
  }
}

// ── Invoice Card ──────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.yearMonth,
    required this.cardId,
    required this.card,
    required this.isCurrent,
  });

  final Invoice? invoice;
  final String yearMonth;
  final String cardId;
  final CreditCard card;
  final bool isCurrent;

  String _formatYearMonth(String ym) {
    final parts = ym.split('-');
    if (parts.length != 2) return ym;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    return DateFormatter.monthYear(DateTime(year, month));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inv = invoice;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: inv != null
            ? () => context.pushNamed(
                  AppRoutes.invoiceName,
                  pathParameters: {
                    'cardId': cardId,
                    'yearMonth': yearMonth,
                  },
                  extra: inv,
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // ── Info ─────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatYearMonth(yearMonth),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (inv != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Vence em ${DateFormatter.shortDate(inv.dueDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        isCurrent ? 'Fatura ainda não gerada' : 'Sem lançamentos',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Total + status ────────────────────────────────────────────
              if (inv != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(inv.totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: inv.status == InvoiceStatus.paid
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: inv.status),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ] else if (isCurrent) ...[
                Text(
                  CurrencyFormatter.format(0),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      InvoiceStatus.open => ('Aberta', AppColors.warning),
      InvoiceStatus.closed => ('Fechada', AppColors.expense),
      InvoiceStatus.paid => ('Paga', AppColors.income),
    };

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
