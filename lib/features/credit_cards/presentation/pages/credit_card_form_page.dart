// lib/features/credit_cards/presentation/pages/credit_card_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../transactions/presentation/widgets/account_picker_sheet.dart';
import '../../domain/entities/credit_card.dart';
import '../providers/credit_card_providers.dart';
import '../widgets/credit_card_widget.dart';

const _kColorPalette = [
  '#4CAF50', '#2196F3', '#9C27B0', '#F44336',
  '#FF9800', '#009688', '#3F51B5', '#E91E63',
  '#607D8B', '#795548', '#00BCD4', '#8BC34A',
];

/// Página de formulário para criar ou editar um cartão de crédito.
class CreditCardFormPage extends ConsumerStatefulWidget {
  const CreditCardFormPage({super.key, this.creditCard});

  /// null = modo criação, não-null = modo edição.
  final CreditCard? creditCard;

  @override
  ConsumerState<CreditCardFormPage> createState() =>
      _CreditCardFormPageState();
}

class _CreditCardFormPageState extends ConsumerState<CreditCardFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _limitController = TextEditingController();

  late CardBrand _brand;
  late int _closingDay;
  late int _dueDay;
  late String _colorHex;
  String? _paymentAccountId;

  bool get _isEditMode => widget.creditCard != null;

  @override
  void initState() {
    super.initState();
    final card = widget.creditCard;
    if (card != null) {
      _nameController.text = card.name;
      _lastFourController.text = card.lastFourDigits;
      final limitReais = card.creditLimit / 100;
      _limitController.text =
          limitReais.toStringAsFixed(2).replaceAll('.', ',');
      _brand = card.brand;
      _closingDay = card.closingDay;
      _dueDay = card.dueDay;
      _colorHex = card.colorHex;
      _paymentAccountId = card.paymentAccountId;
    } else {
      _brand = CardBrand.visa;
      _closingDay = 1;
      _dueDay = 10;
      _colorHex = _kColorPalette.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastFourController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(creditCardNotifierProvider);
    final isLoading = notifierState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    // Prévia do cartão com os valores atuais
    final previewCard = CreditCard(
      id: widget.creditCard?.id ?? '',
      userId: '',
      name: _nameController.text.isEmpty
          ? 'Nome do cartão'
          : _nameController.text,
      brand: _brand,
      lastFourDigits:
          _lastFourController.text.isEmpty ? '0000' : _lastFourController.text,
      creditLimit:
          ((CurrencyInputFormatter.extractValue(_limitController.text)) * 100)
              .round(),
      closingDay: _closingDay,
      dueDay: _dueDay,
      colorHex: _colorHex,
      isActive: true,
      createdAt: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar cartão' : 'Novo cartão'),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          children: [
            // ── Prévia ────────────────────────────────────────────────────────
            CreditCardWidget(card: previewCard),
            const SizedBox(height: AppSpacing.xl2),

            // ── Nome ──────────────────────────────────────────────────────────
            const _SectionLabel('Nome do cartão'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Nome',
              controller: _nameController,
              keyboardType: TextInputType.text,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Bandeira ──────────────────────────────────────────────────────
            const _SectionLabel('Bandeira'),
            const SizedBox(height: AppSpacing.sm),
            _BrandSelector(
              selected: _brand,
              onChanged: (b) => setState(() => _brand = b),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Últimos 4 dígitos ─────────────────────────────────────────────
            const _SectionLabel('Últimos 4 dígitos'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: '0000',
              controller: _lastFourController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (v) {
                if (v == null || v.length != 4) {
                  return 'Informe os 4 últimos dígitos';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Limite de crédito ─────────────────────────────────────────────
            const _SectionLabel('Limite de crédito'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Limite',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o limite';
                final value =
                    CurrencyInputFormatter.extractValue(v) * 100;
                if (value <= 0) return 'Limite deve ser maior que zero';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Dia de fechamento ─────────────────────────────────────────────
            const _SectionLabel('Dia de fechamento'),
            const SizedBox(height: AppSpacing.sm),
            _DayDropdown(
              value: _closingDay,
              label: 'Dia de fechamento',
              onChanged: (d) => setState(() => _closingDay = d),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Dia de vencimento ─────────────────────────────────────────────
            const _SectionLabel('Dia de vencimento'),
            const SizedBox(height: AppSpacing.sm),
            _DayDropdown(
              value: _dueDay,
              label: 'Dia de vencimento',
              onChanged: (d) => setState(() => _dueDay = d),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Cor ───────────────────────────────────────────────────────────
            const _SectionLabel('Cor'),
            const SizedBox(height: AppSpacing.sm),
            _ColorPicker(
              selected: _colorHex,
              onChanged: (c) => setState(() => _colorHex = c),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Conta de pagamento ────────────────────────────────────────────
            const _SectionLabel('Conta de pagamento (opcional)'),
            const SizedBox(height: AppSpacing.sm),
            _PaymentAccountSelector(
              selectedId: _paymentAccountId,
              onChanged: (id) => setState(() => _paymentAccountId = id),
            ),
            const SizedBox(height: AppSpacing.xl3),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final limitReais =
        CurrencyInputFormatter.extractValue(_limitController.text);
    final limitCentavos = (limitReais * 100).round();
    final userId = ref.read(currentUserIdProvider);
    final existing = widget.creditCard;

    final card = CreditCard(
      id: existing?.id ?? const Uuid().v4(),
      userId: userId,
      name: _nameController.text.trim(),
      brand: _brand,
      lastFourDigits: _lastFourController.text.trim(),
      creditLimit: limitCentavos,
      closingDay: _closingDay,
      dueDay: _dueDay,
      colorHex: _colorHex,
      paymentAccountId: _paymentAccountId,
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditMode) {
      success = await ref
          .read(creditCardNotifierProvider.notifier)
          .updateCreditCard(card);
    } else {
      success = await ref
          .read(creditCardNotifierProvider.notifier)
          .createCreditCard(card);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (!success && mounted) {
      final errorState = ref.read(creditCardNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorState.error?.toString() ?? 'Erro ao salvar cartão.',
          ),
        ),
      );
    }
  }
}

// ── Auxiliares ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _BrandSelector extends StatelessWidget {
  const _BrandSelector({required this.selected, required this.onChanged});

  final CardBrand selected;
  final ValueChanged<CardBrand> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: CardBrand.values.map((brand) {
        final isSelected = brand == selected;
        final colorScheme = Theme.of(context).colorScheme;
        return FilterChip(
          label: Text(brand.label),
          selected: isSelected,
          selectedColor: colorScheme.primaryContainer,
          checkmarkColor: colorScheme.onPrimaryContainer,
          onSelected: (_) => onChanged(brand),
        );
      }).toList(),
    );
  }
}

class _DayDropdown extends StatelessWidget {
  const _DayDropdown({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      items: List.generate(
        28,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text('Dia ${i + 1}'),
        ),
      ),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _kColorPalette.map((hex) {
        Color color;
        try {
          color = Color(
            int.parse('FF${hex.replaceFirst('#', '')}', radix: 16),
          );
        } catch (_) {
          color = AppColors.expense;
        }
        final isSelected = hex == selected;
        return GestureDetector(
          onTap: () => onChanged(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 2.5,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentAccountSelector extends ConsumerWidget {
  const _PaymentAccountSelector({
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(watchAccountsProvider);
    final selected = accountsAsync.valueOrNull
        ?.where((a) => a.id == selectedId)
        .firstOrNull;

    return InkWell(
      onTap: () async {
        final account = await showAccountPicker(
          context: context,
          ref: ref,
          selectedId: selectedId,
          title: 'Conta de pagamento',
        );
        if (account != null) onChanged(account.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                selected?.name ?? 'Nenhuma (selecionar depois)',
                style: TextStyle(
                  color: selected != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (selectedId != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(
                  Icons.clear,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
