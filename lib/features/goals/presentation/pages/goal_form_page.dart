// lib/features/goals/presentation/pages/goal_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../transactions/presentation/widgets/account_picker_sheet.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';

// ── Paleta de cores predefinidas ───────────────────────────────────────────

const _kColors = [
  '#1565C0', '#2E7D32', '#C62828', '#F57C00',
  '#6A1B9A', '#00838F', '#AD1457', '#37474F',
  '#4E342E', '#558B2F', '#00695C', '#E65100',
];

// ── Ícones predefinidos ────────────────────────────────────────────────────

const _kIcons = [
  Icons.home_rounded,
  Icons.directions_car_rounded,
  Icons.flight_rounded,
  Icons.school_rounded,
  Icons.favorite_rounded,
  Icons.laptop_rounded,
  Icons.savings_rounded,
  Icons.celebration_rounded,
  Icons.star_rounded,
  Icons.beach_access_rounded,
  Icons.fitness_center_rounded,
  Icons.restaurant_rounded,
];

class GoalFormPage extends ConsumerStatefulWidget {
  const GoalFormPage({super.key, this.goal});

  /// Quando não nulo, entra em modo edição.
  final Goal? goal;

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  bool get _isEditMode => widget.goal != null;

  String _selectedColor = _kColors.first;
  IconData _selectedIcon = _kIcons.first;
  DateTime _deadline = DateTime.now().add(const Duration(days: 365));
  String? _linkedAccountId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    if (g != null) {
      _nameController.text = g.name;
      final reais = g.targetAmount / 100;
      _targetController.text =
          reais.toStringAsFixed(2).replaceAll('.', ',');
      _selectedColor = g.colorHex;
      _selectedIcon = IconData(g.iconCodePoint, fontFamily: g.iconFontFamily);
      _deadline = g.deadline;
      _linkedAccountId = g.linkedAccountId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  // ── Salvar ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final userId = ref.read(currentUserIdProvider);
    final amountDouble =
        CurrencyInputFormatter.extractValue(_targetController.text);
    final amountCents = (amountDouble * 100).round();
    final now = DateTime.now();

    final Goal goal;
    if (_isEditMode) {
      goal = widget.goal!.copyWith(
        name: _nameController.text.trim(),
        targetAmount: amountCents,
        deadline: _deadline,
        colorHex: _selectedColor,
        iconCodePoint: _selectedIcon.codePoint,
        iconFontFamily: _selectedIcon.fontFamily ?? 'MaterialIcons',
        linkedAccountId: _linkedAccountId,
        updatedAt: now,
      );
    } else {
      goal = Goal(
        id: '',
        userId: userId,
        name: _nameController.text.trim(),
        targetAmount: amountCents,
        currentAmount: 0,
        deadline: _deadline,
        colorHex: _selectedColor,
        iconCodePoint: _selectedIcon.codePoint,
        iconFontFamily: _selectedIcon.fontFamily ?? 'MaterialIcons',
        linkedAccountId: _linkedAccountId,
        createdAt: now,
      );
    }

    final notifier = ref.read(goalNotifierProvider.notifier);
    final ok = _isEditMode
        ? await notifier.updateGoal(goal)
        : await notifier.createGoal(goal);

    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        if (context.mounted) context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar meta. Tente novamente.'),
          ),
        );
      }
    }
  }

  // ── Seletor de data ────────────────────────────────────────────────────────

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline.isAfter(DateTime.now())
          ? _deadline
          : DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  // ── Seletor de conta ───────────────────────────────────────────────────────

  Future<void> _pickAccount() async {
    final account = await showAccountPicker(
      context: context,
      ref: ref,
      selectedId: _linkedAccountId,
      title: 'Conta vinculada (opcional)',
    );
    if (account != null) {
      setState(() => _linkedAccountId = account.id);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar meta' : 'Nova meta'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox.square(
                  dimension: 20,
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
          padding: AppSpacing.pagePadding,
          children: [
            // ── Preview do ícone ────────────────────────────────────────
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(_selectedIcon, color: color, size: 36),
              ),
            ),
            AppSpacing.vXl,

            // ── Nome ────────────────────────────────────────────────────
            AppTextField(
              label: 'Nome da meta',
              prefixIcon: Icons.flag_rounded,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                if (v.trim().length > 60) return 'Máximo 60 caracteres.';
                return null;
              },
            ),
            AppSpacing.vLg,

            // ── Valor alvo ───────────────────────────────────────────────
            AppTextField(
              label: 'Valor alvo',
              prefixIcon: Icons.savings_rounded,
              controller: _targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [CurrencyInputFormatter()],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o valor.';
                final d = CurrencyInputFormatter.extractValue(v);
                if (d <= 0) return 'O valor deve ser maior que zero.';
                return null;
              },
            ),
            AppSpacing.vLg,

            // ── Prazo ────────────────────────────────────────────────────
            AppTextField(
              label: 'Prazo',
              prefixIcon: Icons.calendar_month_rounded,
              controller:
                  TextEditingController(text: _formatDate(_deadline)),
              readOnly: true,
              onTap: _pickDeadline,
            ),
            AppSpacing.vLg,

            // ── Conta vinculada ──────────────────────────────────────────
            _LinkedAccountField(
              linkedAccountId: _linkedAccountId,
              onTap: _pickAccount,
              onClear: () => setState(() => _linkedAccountId = null),
            ),
            AppSpacing.vLg,

            // ── Cor ──────────────────────────────────────────────────────
            Text(
              'Cor',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _kColors.map((hex) {
                final c = _parseColor(hex);
                final selected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.outline,
                              width: 3,
                            )
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            AppSpacing.vLg,

            // ── Ícone ─────────────────────────────────────────────────────
            Text(
              'Ícone',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _kIcons.map((icon) {
                final selected = _selectedIcon.codePoint == icon.codePoint;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.inputRadius,
                      border: selected
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? color
                          : theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),

            AppSpacing.vXl,

            // ── Botão salvar ─────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isEditMode ? 'Salvar alterações' : 'Criar meta'),
            ),
            AppSpacing.vMd,
          ],
        ),
      ),
    );
  }
}

// ── Campo de conta vinculada ──────────────────────────────────────────────────

class _LinkedAccountField extends StatelessWidget {
  const _LinkedAccountField({
    required this.linkedAccountId,
    required this.onTap,
    required this.onClear,
  });

  final String? linkedAccountId;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.inputRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: AppRadius.inputRadius,
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            AppSpacing.hMd,
            Expanded(
              child: Text(
                linkedAccountId != null
                    ? 'Conta vinculada selecionada'
                    : 'Vincular conta (opcional)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: linkedAccountId != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (linkedAccountId != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: theme.colorScheme.onSurfaceVariant,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outlineVariant,
              ),
          ],
        ),
      ),
    );
  }
}
