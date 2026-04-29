// lib/features/categories/presentation/pages/category_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

// ── Paleta de cores ────────────────────────────────────────────────────────────

const _kColorPalette = [
  '#E53935', // Vermelho
  '#D81B60', // Rosa
  '#8E24AA', // Roxo
  '#5E35B1', // Roxo escuro
  '#1E88E5', // Azul
  '#00ACC1', // Ciano
  '#00897B', // Verde azulado
  '#43A047', // Verde
  '#7CB342', // Verde claro
  '#F4511E', // Laranja escuro
  '#FB8C00', // Laranja
  '#F6BF26', // Amarelo
  '#6D4C41', // Marrom
  '#546E7A', // Cinza azulado
  '#455A64', // Cinza escuro
  '#1565C0', // Azul escuro
];

// ── Lista de ícones disponíveis ────────────────────────────────────────────────

typedef _IconOption = ({IconData icon, String label});

const List<_IconOption> _kIconOptions = [
  (icon: Icons.restaurant_rounded, label: 'Restaurante'),
  (icon: Icons.directions_car_rounded, label: 'Transporte'),
  (icon: Icons.home_rounded, label: 'Moradia'),
  (icon: Icons.favorite_rounded, label: 'Saúde'),
  (icon: Icons.school_rounded, label: 'Educação'),
  (icon: Icons.sports_esports_rounded, label: 'Lazer'),
  (icon: Icons.checkroom_rounded, label: 'Vestuário'),
  (icon: Icons.shopping_cart_rounded, label: 'Compras'),
  (icon: Icons.subscriptions_rounded, label: 'Assinaturas'),
  (icon: Icons.account_balance_wallet_rounded, label: 'Carteira'),
  (icon: Icons.work_rounded, label: 'Trabalho'),
  (icon: Icons.trending_up_rounded, label: 'Investimentos'),
  (icon: Icons.attach_money_rounded, label: 'Dinheiro'),
  (icon: Icons.account_balance_rounded, label: 'Banco'),
  (icon: Icons.payments_rounded, label: 'Pagamentos'),
  (icon: Icons.savings_rounded, label: 'Poupança'),
  (icon: Icons.local_hospital_rounded, label: 'Hospital'),
  (icon: Icons.flight_rounded, label: 'Viagem'),
  (icon: Icons.monetization_on_rounded, label: 'Receita'),
  (icon: Icons.card_giftcard_rounded, label: 'Presente'),
  (icon: Icons.fitness_center_rounded, label: 'Fitness'),
  (icon: Icons.local_gas_station_rounded, label: 'Combustível'),
  (icon: Icons.movie_rounded, label: 'Cinema'),
  (icon: Icons.smartphone_rounded, label: 'Tecnologia'),
  (icon: Icons.pets_rounded, label: 'Pets'),
  (icon: Icons.sports_soccer_rounded, label: 'Esportes'),
  (icon: Icons.coffee_rounded, label: 'Café'),
  (icon: Icons.construction_rounded, label: 'Reformas'),
  (icon: Icons.electrical_services_rounded, label: 'Contas'),
  (icon: Icons.child_care_rounded, label: 'Crianças'),
];

/// Formulário para criar ou editar uma categoria personalizada.
///
/// - Criar: [category] == null, [initialType] define o tipo pré-selecionado
/// - Editar: [category] é a categoria existente (somente personalizadas)
class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({
    super.key,
    this.category,
    this.initialType,
  });

  final Category? category;
  final CategoryType? initialType;

  @override
  ConsumerState<CategoryFormPage> createState() =>
      _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late CategoryType _selectedType;
  late String _selectedColorHex;
  late IconData _selectedIcon;

  bool get _isEditMode => widget.category != null;

  Color get _selectedColor {
    final hex = _selectedColorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _selectedType =
        c?.type ?? widget.initialType ?? CategoryType.expense;
    _selectedColorHex = c?.colorHex ?? _kColorPalette.first;
    _selectedIcon = c != null
        ? IconData(c.iconCodePoint, fontFamily: c.iconFontFamily)
        : _kIconOptions.first.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = ref.read(currentUserIdProvider);
    final now = DateTime.now();

    final category = Category(
      id: _isEditMode ? widget.category!.id : '',
      userId: userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      colorHex: _selectedColorHex,
      iconCodePoint: _selectedIcon.codePoint,
      iconFontFamily: _selectedIcon.fontFamily ?? 'MaterialIcons',
      isDefault: false,
      createdAt: _isEditMode ? widget.category!.createdAt : now,
      updatedAt: _isEditMode ? now : null,
    );

    final notifier = ref.read(categoryNotifierProvider.notifier);
    final success = _isEditMode
        ? await notifier.updateCategory(category)
        : await notifier.createCategory(category);

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      final error = ref.read(categoryNotifierProvider).asError?.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              error != null ? '$error' : 'Erro ao salvar categoria.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(categoryNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEditMode ? 'Editar categoria' : 'Nova categoria'),
        actions: [
          if (isLoading)
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            // ── Preview ─────────────────────────────────────────────────
            _CategoryPreview(
              name: _nameController.text.isEmpty
                  ? 'Prévia'
                  : _nameController.text,
              icon: _selectedIcon,
              color: _selectedColor,
              type: _selectedType,
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Tipo (somente criação) ───────────────────────────────────
            if (!_isEditMode) ...[
              const _SectionLabel('Tipo'),
              const SizedBox(height: AppSpacing.sm),
              _TypeToggle(
                selected: _selectedType,
                onChanged: (t) => setState(() => _selectedType = t),
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],

            // ── Nome ─────────────────────────────────────────────────────
            const _SectionLabel('Nome'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Nome da categoria',
              hint: _selectedType == CategoryType.expense
                  ? 'Ex: Mercado, Farmácia, Aluguel'
                  : 'Ex: Salário, Freelance, Dividendos',
              controller: _nameController,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Informe um nome' : null,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Cor ──────────────────────────────────────────────────────
            const _SectionLabel('Cor'),
            const SizedBox(height: AppSpacing.sm),
            _ColorPicker(
              selectedHex: _selectedColorHex,
              onChanged: (hex) =>
                  setState(() => _selectedColorHex = hex),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ── Ícone ────────────────────────────────────────────────────
            const _SectionLabel('Ícone'),
            const SizedBox(height: AppSpacing.sm),
            _IconGrid(
              selectedIcon: _selectedIcon,
              accentColor: _selectedColor,
              onChanged: (icon) =>
                  setState(() => _selectedIcon = icon),
            ),
            const SizedBox(height: AppSpacing.xl3),

            // ── Botão salvar ─────────────────────────────────────────────
            FilledButton(
              onPressed: isLoading ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: _selectedColor,
              ),
              child: Text(
                _isEditMode ? 'Salvar alterações' : 'Criar categoria',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Preview card ───────────────────────────────────────────────────────────────

class _CategoryPreview extends StatelessWidget {
  const _CategoryPreview({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  final String name;
  final IconData icon;
  final Color color;
  final CategoryType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = type == CategoryType.income;
    final typeColor = isIncome ? AppColors.income : AppColors.expense;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullRadius,
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isIncome ? 'Receita' : 'Despesa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seletor de tipo ────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.selected,
    required this.onChanged,
  });

  final CategoryType selected;
  final ValueChanged<CategoryType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: 'Despesa',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.expense,
            isSelected: selected == CategoryType.expense,
            onTap: () => onChanged(CategoryType.expense),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TypeButton(
            label: 'Receita',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.income,
            isSelected: selected == CategoryType.income,
            onTap: () => onChanged(CategoryType.income),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Seletor de cor ─────────────────────────────────────────────────────────────

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
            duration: const Duration(milliseconds: 120),
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

// ── Grid de ícones ─────────────────────────────────────────────────────────────

class _IconGrid extends StatelessWidget {
  const _IconGrid({
    required this.selectedIcon,
    required this.accentColor,
    required this.onChanged,
  });

  final IconData selectedIcon;
  final Color accentColor;
  final ValueChanged<IconData> onChanged;

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
        final isSelected = opt.icon.codePoint == selectedIcon.codePoint;
        return Tooltip(
          message: opt.label,
          child: GestureDetector(
            onTap: () => onChanged(opt.icon),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : colorScheme.outlineVariant
                          .withValues(alpha: 0.4),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                opt.icon,
                color: isSelected
                    ? accentColor
                    : colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

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
