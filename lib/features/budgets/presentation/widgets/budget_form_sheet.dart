// lib/features/budgets/presentation/widgets/budget_form_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';

/// Abre o bottom sheet de criação/edição de orçamento.
///
/// Retorna `true` se o orçamento foi salvo com sucesso, `false` caso contrário.
Future<bool> showBudgetForm(
  BuildContext context,
  WidgetRef ref, {
  Budget? budget,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: AppRadius.sheetRadius,
    ),
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: _BudgetFormSheet(budget: budget),
    ),
  );
  return result ?? false;
}

// ── Bottom Sheet ─────────────────────────────────────────────────────────────

class _BudgetFormSheet extends ConsumerStatefulWidget {
  const _BudgetFormSheet({this.budget});

  final Budget? budget;

  @override
  ConsumerState<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<_BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool get _isEditMode => widget.budget != null;

  Category? _selectedCategory;
  BudgetPeriod _period = BudgetPeriod.monthly;
  double _alertThreshold = 0.8;
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  // Limiar mapeado para rótulo legível.
  String get _thresholdLabel =>
      '${(_alertThreshold * 100).round()}%';

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    if (b != null) {
      _period = b.period;
      _alertThreshold = b.alertThreshold;
      _startDate = b.startDate;
      _amountController.text =
          (b.amount / 100).toStringAsFixed(2).replaceAll('.', ',');
    } else {
      // Padrão: início do mês atual
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, 1);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ── Salvar ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null && !_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final userId = ref.read(currentUserIdProvider);
    final amountDouble =
        CurrencyInputFormatter.extractValue(_amountController.text);
    final amountCents = (amountDouble * 100).round();

    final now = DateTime.now();
    final Budget budget;

    if (_isEditMode) {
      budget = widget.budget!.copyWith(
        amount: amountCents,
        period: _period,
        alertThreshold: _alertThreshold,
        startDate: _startDate,
        updatedAt: now,
      );
    } else {
      budget = Budget(
        id: '',
        userId: userId,
        categoryId: _selectedCategory!.id,
        amount: amountCents,
        period: _period,
        startDate: _startDate,
        alertThreshold: _alertThreshold,
        createdAt: now,
      );
    }

    final notifier = ref.read(budgetNotifierProvider.notifier);
    final ok = _isEditMode
        ? await notifier.updateBudget(budget)
        : await notifier.createBudget(budget);

    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao salvar orçamento. Tente novamente.')),
        );
      }
    }
  }

  // ── Seletor de data ────────────────────────────────────────────────────────

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: AppSpacing.pagePadding,
              children: [
                // ── Handle + título ─────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: AppRadius.fullRadius,
                    ),
                  ),
                ),
                Text(
                  _isEditMode ? 'Editar orçamento' : 'Novo orçamento',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.vXl,

                // ── Categoria ───────────────────────────────────────────
                if (!_isEditMode) ...[
                  _CategorySection(
                    selected: _selectedCategory,
                    onSelected: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                  AppSpacing.vLg,
                ],

                // ── Valor limite ────────────────────────────────────────
                AppTextField(
                  label: 'Valor limite',
                  prefixIcon: Icons.attach_money_rounded,
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o valor.';
                    final d =
                        CurrencyInputFormatter.extractValue(v);
                    if (d <= 0) return 'O valor deve ser maior que zero.';
                    return null;
                  },
                ),
                AppSpacing.vLg,

                // ── Período ─────────────────────────────────────────────
                Text(
                  'Período',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vSm,
                Wrap(
                  spacing: AppSpacing.sm,
                  children: BudgetPeriod.values.map((p) {
                    final selected = p == _period;
                    return FilterChip(
                      label: Text(p.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _period = p),
                    );
                  }).toList(),
                ),
                AppSpacing.vLg,

                // ── Data de início ──────────────────────────────────────
                _DateField(
                  label: 'Data de início',
                  date: _startDate,
                  onTap: _pickStartDate,
                ),
                AppSpacing.vLg,

                // ── Limiar de alerta ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alerta em',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        _thresholdLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _alertThreshold,
                  min: 0.5,
                  max: 1.0,
                  divisions: 10,
                  label: _thresholdLabel,
                  onChanged: (v) => setState(() => _alertThreshold = v),
                ),
                AppSpacing.vXl,

                // ── Botão salvar ────────────────────────────────────────
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditMode ? 'Salvar alterações' : 'Criar orçamento'),
                ),
                AppSpacing.vMd,
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Seção de categorias ───────────────────────────────────────────────────────

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    required this.selected,
    required this.onSelected,
  });

  final Category? selected;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync =
        ref.watch(watchCategoriesProvider(CategoryType.expense));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.vSm,
        categoriesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => Text(
            'Erro ao carregar categorias.',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return Text(
                'Nenhuma categoria de despesa cadastrada.',
                style: theme.textTheme.bodySmall,
              );
            }
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories.map((cat) {
                final isSelected = selected?.id == cat.id;
                return ChoiceChip(
                  avatar: Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : cat.color,
                  ),
                  label: Text(cat.name),
                  selected: isSelected,
                  selectedColor: cat.color,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  onSelected: (_) => onSelected(cat),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ── Campo de data ─────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      prefixIcon: Icons.calendar_today_rounded,
      controller: TextEditingController(text: _fmt(date)),
      readOnly: true,
      onTap: onTap,
    );
  }
}

