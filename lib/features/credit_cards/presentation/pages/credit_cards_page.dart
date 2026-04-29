// lib/features/credit_cards/presentation/pages/credit_cards_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/invoice.dart';
import '../providers/credit_card_providers.dart';
import '../widgets/credit_card_widget.dart';

class CreditCardsPage extends ConsumerWidget {
  const CreditCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(watchCreditCardsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Cartões de crédito'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.pushNamed(AppRoutes.creditCardNewName),
        child: const Icon(Icons.add),
      ),
      body: cardsAsync.when(
        loading: () => _ShimmerList(),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (cards) {
          if (cards.isEmpty) {
            return _EmptyState(
              onAdd: () =>
                  context.pushNamed(AppRoutes.creditCardNewName),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl2,
              AppSpacing.lg,
              AppSpacing.xl2,
              AppSpacing.xl3 + 72,
            ),
            itemCount: cards.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.lg),
            itemBuilder: (_, i) => _CardItem(card: cards[i]),
          );
        },
      ),
    );
  }
}

// ── Item da lista ─────────────────────────────────────────────────────────────

class _CardItem extends ConsumerWidget {
  const _CardItem({required this.card});

  final CreditCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(watchInvoicesProvider(card.id));
    final now = DateTime.now();
    final currentYearMonth = computeInvoiceYearMonth(now, card.closingDay);

    Invoice? currentInvoice;
    if (invoicesAsync.hasValue) {
      try {
        currentInvoice = invoicesAsync.value!
            .firstWhere((inv) => inv.yearMonth == currentYearMonth);
      } catch (_) {
        currentInvoice = null;
      }
    }

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.creditCardDetailName,
        pathParameters: {'cardId': card.id},
        extra: card,
      ),
      child: Hero(
        tag: 'card_${card.id}',
        child: CreditCardWidget(
          card: card,
          usedAmount: currentInvoice?.totalAmount,
        ),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      itemCount: 2,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor:
            Theme.of(context).colorScheme.surfaceContainerLow,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ── Estado vazio ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 64,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum cartão cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione seu primeiro cartão de crédito',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl2),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar cartão'),
            ),
          ],
        ),
      ),
    );
  }
}
