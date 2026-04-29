// lib/features/accounts/presentation/pages/account_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';

/// Paleta de cores predefinidas para contas.
const _kColorPalette = [
  '#1565C0',
  '#2E7D32',
  '#C62828',
  '#F57C00',
  '#6A1B9A',
  '#00838F',
  '#AD1457',
  '#37474F',
  '#4E342E',
  '#78909C',
  '#FF7043',
  '#0288D1',
];

/// Ícones predefinidos para contas (codePoint + fontFamily + label).
const _kIconOptions = [
  (codePoint: 0xe04c, label: 'Carteira'),    // account_balance_wallet
  (codePoint: 0xe0b2, label: 'Banco'),       // account_balance
  (codePoint: 0xf8f0, label: 'Poupança'),    // savings
  (codePoint: 0xe1ba, label: 'Cartão'),      // credit_card
  (codePoint: 0xe6e1, label: 'Investimento'), // trending_up
  (codePoint: 0xe227, label: 'Dinheiro'),    // attach_money
  (codePoint: 0xeac5, label: 'ATM'),         // local_atm
  (codePoint: 0xf1a7, label: 'Pagamentos'),  // payments
  (codePoint: 0xe3a6, label: 'Loja'),        // store
  (codePoint: 0xe88a, label: 'Casa'),        // home
  (codePoint: 0xe915, label: 'Monetização'), // monetization_on
  (codePoint: 0xf04c, label: 'Câmbio'),      // currency_exchange
];

/// Formulário para criar ou editar uma conta financeira.
///
/// - Criar: [account] == null
/// - Editar: [account] é a conta existente
class AccountFormPage extends ConsumerStatefulWidget {
  const AccountFormPage({super.key, this.account});

  final Account? account;

  @override
  ConsumerState<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends ConsumerState<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _initialBalanceController;

  late AccountType _selectedType;
  late String _selectedColorHex;
  late int _selectedIconCodePoint;
  late bool _includeInTotal;

  bool get _isEditMode => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController = TextEditingController(text: a?.name ?? '');
    _bankNameController = TextEditingController(text: a?.bankName ?? '');
    _initialBalanceController = TextEditingController();
    _selectedType = a?.type ?? AccountType.checking;
    _selectedColorHex = a?.colorHex ?? _kColorPalette.first;
    _selectedIconCodePoint =
        a?.iconCodePoint ?? _kIconOptions.first.codePoint;
    _includeInTotal = a?.includeInTotal ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    // Saldo inicial (apenas para criação)
    int initialBalance = 0;
    if (!_isEditMode) {
      final raw = _initialBalanceController.text;
      if (raw.isNotEmpty) {
        initialBalance =
            (CurrencyInputFormatter.extractValue(raw) * 100).round();
      }
    }

    final account = Account(
      id: _isEditMode ? widget.account!.id : '',
      userId: userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: _isEditMode ? widget.account!.balance : initialBalance,
      colorHex: _selectedColorHex,
      iconCodePoint: _selectedIconCodePoint,
      iconFontFamily: 'MaterialIcons',
      bankName: _bankNameController.text.trim().isEmpty
          ? null
          : _bankNameController.text.trim(),
      includeInTotal: _includeInTotal,
      createdAt: _isEditMode ? widget.account!.createdAt : now,
      updatedAt: _isEditMode ? now : null,
    );

    final notifier = ref.read(accountNotifierProvider.notifier);
    final success = _isEditMode
        ? await notifier.updateAccount(account)
        : await notifier.createAccount(account);

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      final error = ref.read(accountNotifierProvider).asError?.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error != null ? '$error' : 'Erro ao salvar conta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading =
        ref.watch(accountNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar conta' : 'Nova conta'),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
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
            // ── Preview do card ────────────────────────────────────────────
            _AccountPreviewCard(
              name: _nameController.text.isEmpty
                  ? 'Nome da conta'
                  : _nameController.text,
              type: _selectedType,
              colorHex: _selectedColorHex,
              iconCodePoint: _selectedIconCodePoint,
              includeInTotal: _includeInTotal,
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Nome ───────────────────────────────────────────────────────
            const _SectionLabel('Identificação'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Nome da conta',
              hint: 'Ex: Nubank, Caixa, Carteira',
              controller: _nameController,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Informe um nome' : null,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Banco (opcional)',
              hint: 'Ex: Banco do Brasil',
              controller: _bankNameController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Tipo ───────────────────────────────────────────────────────
            const _SectionLabel('Tipo de conta'),
            const SizedBox(height: AppSpacing.sm),
            _AccountTypeSelector(
              selected: _selectedType,
              onChanged: (t) => setState(() => _selectedType = t),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Saldo inicial (apenas criação) ─────────────────────────────
            if (!_isEditMode) ...[
              const _SectionLabel('Saldo inicial'),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Informe o saldo atual desta conta. Pode ser zero.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false),
                inputFormatters: [CurrencyInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  hintText: 'R\$ 0,00',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],

            // ── Cor ────────────────────────────────────────────────────────
            const _SectionLabel('Cor'),
            const SizedBox(height: AppSpacing.sm),
            _ColorPicker(
              selectedHex: _selectedColorHex,
              onChanged: (hex) =>
                  setState(() => _selectedColorHex = hex),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Ícone ──────────────────────────────────────────────────────
            const _SectionLabel('Ícone'),
            const SizedBox(height: AppSpacing.sm),
            _IconPicker(
              selectedCodePoint: _selectedIconCodePoint,
              selectedColor: _parseColor(_selectedColorHex),
              onChanged: (cp) =>
                  setState(() => _selectedIconCodePoint = cp),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Incluir no total ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: AppRadius.cardRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Incluir no patrimônio total',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Quando ativo, o saldo desta conta é somado ao seu total.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _includeInTotal,
                    onChanged: (v) => setState(() => _includeInTotal = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl3),

            // ── Botão Salvar ───────────────────────────────────────────────
            FilledButton(
              onPressed: isLoading ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                _isEditMode ? 'Salvar alterações' : 'Criar conta',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Preview Card ──────────────────────────────────────────────────────────────

class _AccountPreviewCard extends StatelessWidget {
  const _AccountPreviewCard({
    required this.name,
    required this.type,
    required this.colorHex,
    required this.iconCodePoint,
    required this.includeInTotal,
  });

  final String name;
  final AccountType type;
  final String colorHex;
  final int iconCodePoint;
  final bool includeInTotal;

  Color get _color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c, c.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  type.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!includeInTotal)
            Icon(
              Icons.visibility_off_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
        ],
      ),
    );
  }
}

// ── Account Type Selector ─────────────────────────────────────────────────────

class _AccountTypeSelector extends StatelessWidget {
  const _AccountTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final AccountType selected;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AccountType.values.map((t) {
        final isSelected = t == selected;
        final colorScheme = Theme.of(context).colorScheme;
        return GestureDetector(
          onTap: () => onChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: AppRadius.fullRadius,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _typeIcon(t),
                  size: 16,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  t.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _typeIcon(AccountType t) => switch (t) {
        AccountType.checking => Icons.account_balance,
        AccountType.savings => Icons.savings,
        AccountType.wallet => Icons.account_balance_wallet,
        AccountType.investment => Icons.trending_up,
        AccountType.other => Icons.attach_money,
      };
}

// ── Color Picker ──────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selectedHex,
    required this.onChanged,
  });

  final String selectedHex;
  final ValueChanged<String> onChanged;

  Color _parse(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _kColorPalette.map((hex) {
        final isSelected = hex == selectedHex;
        final color = _parse(hex);
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
                      width: 3,
                    )
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

// ── Icon Picker ───────────────────────────────────────────────────────────────

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selectedCodePoint,
    required this.selectedColor,
    required this.onChanged,
  });

  final int selectedCodePoint;
  final Color selectedColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: _kIconOptions.length,
      itemBuilder: (_, index) {
        final opt = _kIconOptions[index];
        final isSelected = opt.codePoint == selectedCodePoint;
        return GestureDetector(
          onTap: () => onChanged(opt.codePoint),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
              borderRadius: AppRadius.cardRadius,
              border: Border.all(
                color: isSelected
                    ? selectedColor
                    : colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              IconData(opt.codePoint, fontFamily: 'MaterialIcons'),
              color: isSelected
                  ? selectedColor
                  : colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

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
