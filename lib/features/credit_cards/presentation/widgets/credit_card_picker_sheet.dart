// lib/features/credit_cards/presentation/widgets/credit_card_picker_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/credit_card.dart';
import '../providers/credit_card_providers.dart';

/// Exibe um bottom sheet para selecionar um cartão de crédito.
///
/// Retorna o [CreditCard] selecionado ou null se cancelado.
Future<CreditCard?> showCreditCardPicker({
  required BuildContext context,
  required WidgetRef ref,
  String? selectedId,
  String title = 'Selecionar cartão',
}) {
  return showModalBottomSheet<CreditCard>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreditCardPickerSheet(
      ref: ref,
      selectedId: selectedId,
      title: title,
    ),
  );
}

class _CreditCardPickerSheet extends ConsumerWidget {
  const _CreditCardPickerSheet({
    required this.ref,
    this.selectedId,
    required this.title,
  });

  final WidgetRef ref;
  final String? selectedId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final cardsAsync = widgetRef.watch(watchCreditCardsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Lista de cartões ──────────────────────────────────────────────
          cardsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl2),
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl2),
              child: Text('Erro ao carregar cartões.'),
            ),
            data: (cards) {
              if (cards.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl2,
                    0,
                    AppSpacing.xl2,
                    AppSpacing.xl3,
                  ),
                  child: Text(
                    'Nenhum cartão cadastrado.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl2,
                  right: AppSpacing.xl2,
                  bottom: AppSpacing.xl3,
                ),
                itemCount: cards.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final card = cards[i];
                  final isSelected = card.id == selectedId;
                  Color cardColor;
                  try {
                    cardColor = Color(
                      int.parse(
                        'FF${card.colorHex.replaceFirst('#', '')}',
                        radix: 16,
                      ),
                    );
                  } catch (_) {
                    cardColor = colorScheme.primary;
                  }
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(card.name),
                    subtitle: Text(
                      '•••• ${card.lastFourDigits}  •  ${card.brand.label}',
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                          )
                        : Text(
                            CurrencyFormatter.format(card.creditLimit),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                    onTap: () => Navigator.of(context).pop(card),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
