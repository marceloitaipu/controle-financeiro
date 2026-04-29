// lib/features/credit_cards/presentation/pages/invoice_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/account_picker_sheet.dart';
import '../../../transactions/presentation/widgets/transaction_list_tile.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/invoice.dart';
import '../providers/credit_card_providers.dart';

/// Página de detalhe de uma fatura de cartão de crédito.
class InvoicePage extends ConsumerWidget {
  const InvoicePage({
    super.key,
    required this.cardId,
    required this.yearMonth,
    this.invoice,
  });

  final String cardId;
  final String yearMonth;

  /// Fatura passada via navegação para evitar loading extra.
  final Invoice? invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tenta buscar a fatura atualizada via stream
    final invoicesAsync = ref.watch(watchInvoicesProvider(cardId));
    final Invoice? currentInvoice = invoicesAsync.valueOrNull
            ?.where((inv) => inv.yearMonth == yearMonth)
            .firstOrNull ??
        invoice;

    final txAsync = ref.watch(watchCreditCardTransactionsProvider(
      cardId,
      yearMonth,
    ));

    final cardsAsync = ref.watch(watchCreditCardsProvider);
    final card =
        cardsAsync.valueOrNull?.where((c) => c.id == cardId).firstOrNull;

    final colorScheme = Theme.of(context).colorScheme;
    final title = _formatYearMonth(yearMonth);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text('Fatura $title')),
      body: Column(
        children: [
          // ── Cabeçalho da fatura ───────────────────────────────────────────
          if (currentInvoice != null)
            _InvoiceHeader(invoice: currentInvoice, card: card),

          // ── Lista de transações ───────────────────────────────────────────
          Expanded(
            child: txAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erro ao carregar compras: $e')),
              data: (txList) {
                if (txList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Nenhuma compra nesta fatura',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.xl3 + 72,
                  ),
                  itemCount: txList.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (_, i) => TransactionListTile(
                    transaction: txList[i],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── Botão pagar fatura ────────────────────────────────────────────────
      bottomNavigationBar:
          currentInvoice != null && currentInvoice.status != InvoiceStatus.paid
              ? _PayInvoiceBar(
                  invoice: currentInvoice,
                  cardId: cardId,
                )
              : null,
    );
  }

  String _formatYearMonth(String ym) {
    final parts = ym.split('-');
    if (parts.length != 2) return ym;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    return DateFormatter.monthYear(DateTime(year, month));
  }
}

// ── Cabeçalho da fatura ───────────────────────────────────────────────────────

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({required this.invoice, this.card});

  final Invoice invoice;
  final CreditCard? card;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = switch (invoice.status) {
      InvoiceStatus.open => AppColors.warning,
      InvoiceStatus.closed => AppColors.expense,
      InvoiceStatus.paid => AppColors.income,
    };
    final statusLabel = invoice.status.label;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total da fatura',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyFormatter.format(invoice.totalAmount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _InfoChip(
                icon: Icons.lock_clock_outlined,
                label:
                    'Fecha em ${DateFormatter.shortDate(invoice.closingDate)}',
              ),
              const SizedBox(width: AppSpacing.sm),
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label:
                    'Vence em ${DateFormatter.shortDate(invoice.dueDate)}',
              ),
            ],
          ),
          if (invoice.status == InvoiceStatus.paid && invoice.paidAt != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: _InfoChip(
                icon: Icons.check_circle_outline,
                label:
                    'Pago em ${DateFormatter.shortDate(invoice.paidAt!)}',
                color: AppColors.income,
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: c)),
      ],
    );
  }
}

// ── Barra de pagamento ────────────────────────────────────────────────────────

class _PayInvoiceBar extends ConsumerWidget {
  const _PayInvoiceBar({required this.invoice, required this.cardId});

  final Invoice invoice;
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payState = ref.watch(payInvoiceNotifierProvider);
    final isLoading = payState.isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl2,
          AppSpacing.md,
          AppSpacing.xl2,
          AppSpacing.lg,
        ),
        child: FilledButton.icon(
          onPressed: isLoading
              ? null
              : () => _showPaySheet(context, ref),
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.payment),
          label: Text(
            'Pagar fatura • ${CurrencyFormatter.format(invoice.totalAmount)}',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: AppColors.income,
          ),
        ),
      ),
    );
  }

  Future<void> _showPaySheet(BuildContext context, WidgetRef ref) async {
    final account = await showAccountPicker(
      context: context,
      ref: ref,
      title: 'Conta para pagamento',
    );
    if (account == null || !context.mounted) return;

    final userId = ref.read(currentUserIdProvider);
    final success = await ref
        .read(payInvoiceNotifierProvider.notifier)
        .payInvoice(
          cardId: cardId,
          invoice: invoice,
          paymentAccountId: account.id,
          userId: userId,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Fatura paga com sucesso!'
              : ref.read(payInvoiceNotifierProvider).error?.toString() ??
                  'Erro ao pagar fatura.',
        ),
        backgroundColor: success ? AppColors.income : AppColors.expense,
      ),
    );
  }
}
