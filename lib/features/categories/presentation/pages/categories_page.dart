// lib/features/categories/presentation/pages/categories_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

/// Tela de gestão de categorias.
///
/// Duas abas: Receitas e Despesas.
/// Cada aba mostra categorias padrão (não editáveis) e personalizadas (editáveis).
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.arrow_downward_rounded),
              text: 'Despesas',
            ),
            Tab(
              icon: Icon(Icons.arrow_upward_rounded),
              text: 'Receitas',
            ),
          ],
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CategoryTab(type: CategoryType.expense),
          _CategoryTab(type: CategoryType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final type = _tabController.index == 0
              ? CategoryType.expense
              : CategoryType.income;
          context.pushNamed(
            AppRoutes.categoryNewName,
            extra: type,
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova categoria'),
      ),
    );
  }
}

// ── Aba de categorias ─────────────────────────────────────────────────────────

class _CategoryTab extends ConsumerWidget {
  const _CategoryTab({required this.type});
  final CategoryType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(watchCategoriesProvider(type));

    return categoriesAsync.when(
      loading: () => const _CategoryShimmer(),
      error: (_, __) => Center(
        child: Text(
          'Erro ao carregar categorias.',
          style:
              TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (categories) {
        final defaults =
            categories.where((c) => c.isDefault).toList();
        final custom =
            categories.where((c) => !c.isDefault).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          children: [
            // ── Categorias padrão ──────────────────────────────────────
            if (defaults.isNotEmpty) ...[
              _SectionHeader(
                label: 'Padrão',
                icon: Icons.auto_awesome_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
              ...defaults.map(
                (c) => _CategoryTile(
                  category: c,
                  isDefault: true,
                ),
              ),
            ],

            // ── Categorias personalizadas ──────────────────────────────
            _SectionHeader(
              label: 'Personalizadas',
              icon: Icons.tune_rounded,
              color: type == CategoryType.income
                  ? AppColors.income
                  : AppColors.expense,
            ),
            if (custom.isEmpty)
              _EmptyCustomState(type: type)
            else
              ...custom.map(
                (c) => _CategoryTile(
                  category: c,
                  isDefault: false,
                ),
              ),
            const SizedBox(height: 80), // espaço para FAB
          ],
        );
      },
    );
  }
}

// ── Tile de categoria ─────────────────────────────────────────────────────────

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({
    required this.category,
    required this.isDefault,
  });

  final Category category;
  final bool isDefault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final tile = ListTile(
      leading: _CategoryIcon(category: category),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: isDefault
          ? Text(
              'Padrão do sistema',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: isDefault
          ? Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Editar',
                  onPressed: () => context.pushNamed(
                    AppRoutes.categoryNewName,
                    extra: category,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  tooltip: 'Excluir',
                  onPressed: () =>
                      _confirmDelete(context, ref),
                ),
              ],
            ),
    );

    if (isDefault) return tile;

    // Swipe-to-delete para categorias personalizadas
    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl2),
        color: colorScheme.error,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      child: tile,
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja excluir a categoria "${category.name}"?'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'As transações vinculadas não serão afetadas.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(categoryNotifierProvider.notifier)
          .deleteCategory(category.id);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao excluir categoria.')),
        );
      }
      return success;
    }
    return false;
  }
}

// ── Ícone de categoria ────────────────────────────────────────────────────────

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        category.icon,
        color: category.color,
        size: 22,
      ),
    );
  }
}

// ── Cabeçalho de seção ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Divider(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado vazio de categorias personalizadas ─────────────────────────────────

class _EmptyCustomState extends StatelessWidget {
  const _EmptyCustomState({required this.type});
  final CategoryType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl2,
        vertical: AppSpacing.xl3,
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhuma categoria personalizada',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            type == CategoryType.expense
                ? 'Crie categorias de despesa específicas para o seu perfil.'
                : 'Crie categorias de receita específicas para o seu perfil.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer de carregamento ───────────────────────────────────────────────────

class _CategoryShimmer extends StatelessWidget {
  const _CategoryShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 8,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppRadius.md),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

