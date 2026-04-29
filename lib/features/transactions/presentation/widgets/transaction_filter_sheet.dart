// lib/features/transactions/presentation/widgets/transaction_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// Exibe o bottom sheet de filtros de transações.
///
/// Aplica/limpa filtros via [TransactionFilterNotifier].
Future<void> showTransactionFilterSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransactionFilterSheet(ref: ref),
  );
}

class _TransactionFilterSheet extends ConsumerStatefulWidget {
  const _TransactionFilterSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState
    extends ConsumerState<_TransactionFilterSheet> {
  late TransactionFilterState _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(transactionFilterNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(watchAccountsProvider);
    final expenseCategoriesAsync =
        ref.watch(watchCategoriesProvider(CategoryType.expense));
    final incomeCategoriesAsync =
        ref.watch(watchCategoriesProvider(CategoryType.income));

    final allCategories = [
      ...?expenseCategoriesAsync.valueOrNull,
      ...?incomeCategoriesAsync.valueOrNull,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle + Header ─────────────────────────────────────────────
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl2,
                AppSpacing.lg,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filtrar transações',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _draft = const TransactionFilterState();
                    }),
                    child: const Text('Limpar'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Conteúdo ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.xl2),
                children: [
                  // Tipo
                  _FilterSection(
                    title: 'Tipo',
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        _TypeChip(
                          label: 'Receita',
                          icon: Icons.arrow_circle_up_outlined,
                          color: AppColors.income,
                          isSelected: _draft.type == TransactionType.income,
                          onTap: () => setState(() {
                            _draft = _draft.withType(
                              _draft.type == TransactionType.income
                                  ? null
                                  : TransactionType.income,
                            );
                          }),
                        ),
                        _TypeChip(
                          label: 'Despesa',
                          icon: Icons.arrow_circle_down_outlined,
                          color: AppColors.expense,
                          isSelected: _draft.type == TransactionType.expense,
                          onTap: () => setState(() {
                            _draft = _draft.withType(
                              _draft.type == TransactionType.expense
                                  ? null
                                  : TransactionType.expense,
                            );
                          }),
                        ),
                        _TypeChip(
                          label: 'Transferência',
                          icon: Icons.swap_horiz_outlined,
                          color: AppColors.transfer,
                          isSelected:
                              _draft.type == TransactionType.transfer,
                          onTap: () => setState(() {
                            _draft = _draft.withType(
                              _draft.type == TransactionType.transfer
                                  ? null
                                  : TransactionType.transfer,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Período
                  _FilterSection(
                    title: 'Período',
                    child: Column(
                      children: [
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            _PeriodChip(
                              label: 'Este mês',
                              isSelected: _isThisMonth,
                              onTap: () => _setPeriod(_thisMonthStart,
                                  _thisMonthEnd),
                            ),
                            _PeriodChip(
                              label: 'Mês anterior',
                              isSelected: _isLastMonth,
                              onTap: () => _setPeriod(_lastMonthStart,
                                  _lastMonthEnd),
                            ),
                            _PeriodChip(
                              label: 'Últimos 3 meses',
                              isSelected: _isLast3Months,
                              onTap: () => _setPeriod(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month - 2,
                                ),
                                _thisMonthEnd,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _DateButton(
                                label: _draft.startDate != null
                                    ? _fmtDate(_draft.startDate!)
                                    : 'De',
                                icon: Icons.calendar_today_outlined,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _draft.startDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _draft =
                                        _draft.withDateRange(
                                            picked, _draft.endDate));
                                  }
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm),
                              child: Text('–'),
                            ),
                            Expanded(
                              child: _DateButton(
                                label: _draft.endDate != null
                                    ? _fmtDate(_draft.endDate!)
                                    : 'Até',
                                icon: Icons.calendar_today_outlined,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _draft.endDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _draft =
                                        _draft.withDateRange(
                                            _draft.startDate, picked));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Conta
                  _FilterSection(
                    title: 'Conta',
                    child: accountsAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (accounts) => Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: accounts.map((a) {
                          return FilterChip(
                            label: Text(a.name),
                            selected: _draft.accountId == a.id,
                            onSelected: (_) => setState(() {
                              _draft = _draft.withAccount(
                                _draft.accountId == a.id ? null : a.id,
                              );
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Categoria
                  _FilterSection(
                    title: 'Categoria',
                    child: allCategories.isEmpty
                        ? const SizedBox.shrink()
                        : Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: allCategories.map((cat) {
                              return FilterChip(
                                avatar: Icon(
                                  cat.icon,
                                  size: 16,
                                  color: cat.color,
                                ),
                                label: Text(cat.name),
                                selected: _draft.categoryId == cat.id,
                                onSelected: (_) => setState(() {
                                  _draft = _draft.withCategory(
                                    _draft.categoryId == cat.id
                                        ? null
                                        : cat.id,
                                  );
                                }),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xl3),
                ],
              ),
            ),

            // ── Apply button ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl2,
                AppSpacing.sm,
                AppSpacing.xl2,
                MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              child: FilledButton(
                onPressed: () {
                  ref
                      .read(transactionFilterNotifierProvider.notifier)
                      .setType(_draft.type);
                  ref
                      .read(transactionFilterNotifierProvider.notifier)
                      .setDateRange(_draft.startDate, _draft.endDate);
                  ref
                      .read(transactionFilterNotifierProvider.notifier)
                      .setAccount(_draft.accountId);
                  ref
                      .read(transactionFilterNotifierProvider.notifier)
                      .setCategory(_draft.categoryId);
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Period helpers ──────────────────────────────────────────────────────────

  DateTime get _thisMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  DateTime get _thisMonthEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  DateTime get _lastMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1);
  }

  DateTime get _lastMonthEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 0, 23, 59, 59);
  }

  bool get _isThisMonth =>
      _draft.startDate != null &&
      _draft.startDate!.year == _thisMonthStart.year &&
      _draft.startDate!.month == _thisMonthStart.month &&
      _draft.endDate != null &&
      _draft.endDate!.month == _thisMonthEnd.month;

  bool get _isLastMonth =>
      _draft.startDate != null &&
      _draft.startDate!.year == _lastMonthStart.year &&
      _draft.startDate!.month == _lastMonthStart.month &&
      _draft.endDate != null &&
      _draft.endDate!.month == _lastMonthEnd.month;

  bool get _isLast3Months {
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 2);
    return _draft.startDate != null &&
        _draft.startDate!.year == threeMonthsAgo.year &&
        _draft.startDate!.month == threeMonthsAgo.month;
  }

  void _setPeriod(DateTime start, DateTime end) {
    setState(() {
      _draft = _isThisMonth && start == _thisMonthStart
          ? _draft.withDateRange(null, null)
          : _draft.withDateRange(start, end);
    });
  }

  String _fmtDate(DateTime date) =>
      DateFormat('dd/MM/yy', 'pt_BR').format(date);
}

// ── Auxiliary widgets ─────────────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : null),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
