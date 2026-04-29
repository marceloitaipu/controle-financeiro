// lib/features/transactions/presentation/widgets/account_picker_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';

/// Exibe um bottom sheet para selecionar uma conta do usuário.
///
/// Retorna o [Account] selecionado ou null se cancelado.
///
/// Uso:
/// ```dart
/// final account = await showAccountPicker(
///   context: context,
///   ref: ref,
///   excludeId: _selectedDestAccountId, // opcional — exclui uma conta
/// );
/// ```
Future<Account?> showAccountPicker({
  required BuildContext context,
  required WidgetRef ref,
  String? selectedId,
  String? excludeId,
  String title = 'Selecionar conta',
}) {
  return showModalBottomSheet<Account>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AccountPickerSheet(
      ref: ref,
      selectedId: selectedId,
      excludeId: excludeId,
      title: title,
    ),
  );
}

class _AccountPickerSheet extends ConsumerWidget {
  const _AccountPickerSheet({
    required this.ref,
    this.selectedId,
    this.excludeId,
    required this.title,
  });

  final WidgetRef ref;
  final String? selectedId;
  final String? excludeId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final accountsAsync = widgetRef.watch(watchAccountsProvider);
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

          // ── Title ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Accounts list ─────────────────────────────────────────────────
          accountsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl3),
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (accounts) {
              final filtered = excludeId != null
                  ? accounts.where((a) => a.id != excludeId).toList()
                  : accounts;

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl3),
                  child: Text(
                    'Nenhuma conta disponível.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 64),
                itemBuilder: (_, index) {
                  final account = filtered[index];
                  final isSelected = account.id == selectedId;
                  return _AccountTile(
                    account: account,
                    isSelected: isSelected,
                    onTap: () => Navigator.of(context).pop(account),
                  );
                },
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final Account account;
  final bool isSelected;
  final VoidCallback onTap;

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
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.15),
          borderRadius: AppRadius.chipRadius,
        ),
        child: Icon(_icon, color: _color, size: 20),
      ),
      title: Text(
        account.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        CurrencyFormatter.format(account.balance),
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
    );
  }
}
