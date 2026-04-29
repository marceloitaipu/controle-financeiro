// lib/core/constants/default_categories.dart

import 'package:flutter/material.dart';

import '../../features/categories/domain/entities/category.dart';

/// Definição simples de uma categoria padrão antes de ter o userId.
typedef _CategorySeed = ({
  String name,
  CategoryType type,
  String colorHex,
  IconData icon,
});

/// Gera a lista de categorias padrão para um novo usuário.
/// O [userId] é injetado no momento da criação.
abstract final class DefaultCategories {
  // ── Seeds de receitas ────────────────────────────────────────────────────

  static const List<_CategorySeed> _incomeSeeds = [
    (
      name: 'Salário',
      type: CategoryType.income,
      colorHex: '#2E7D32',
      icon: Icons.account_balance_wallet_rounded,
    ),
    (
      name: 'Freelance',
      type: CategoryType.income,
      colorHex: '#1565C0',
      icon: Icons.work_rounded,
    ),
    (
      name: 'Investimentos',
      type: CategoryType.income,
      colorHex: '#558B2F',
      icon: Icons.trending_up_rounded,
    ),
    (
      name: 'Outros (entrada)',
      type: CategoryType.income,
      colorHex: '#00796B',
      icon: Icons.add_circle_outline_rounded,
    ),
  ];

  // ── Seeds de despesas ────────────────────────────────────────────────────

  static const List<_CategorySeed> _expenseSeeds = [
    (
      name: 'Alimentação',
      type: CategoryType.expense,
      colorHex: '#E53935',
      icon: Icons.restaurant_rounded,
    ),
    (
      name: 'Transporte',
      type: CategoryType.expense,
      colorHex: '#F57C00',
      icon: Icons.directions_car_rounded,
    ),
    (
      name: 'Moradia',
      type: CategoryType.expense,
      colorHex: '#6D4C41',
      icon: Icons.home_rounded,
    ),
    (
      name: 'Saúde',
      type: CategoryType.expense,
      colorHex: '#D81B60',
      icon: Icons.favorite_rounded,
    ),
    (
      name: 'Educação',
      type: CategoryType.expense,
      colorHex: '#6A1B9A',
      icon: Icons.school_rounded,
    ),
    (
      name: 'Lazer',
      type: CategoryType.expense,
      colorHex: '#0288D1',
      icon: Icons.sports_esports_rounded,
    ),
    (
      name: 'Vestuário',
      type: CategoryType.expense,
      colorHex: '#AD1457',
      icon: Icons.checkroom_rounded,
    ),
    (
      name: 'Supermercado',
      type: CategoryType.expense,
      colorHex: '#558B2F',
      icon: Icons.shopping_cart_rounded,
    ),
    (
      name: 'Assinaturas',
      type: CategoryType.expense,
      colorHex: '#00838F',
      icon: Icons.subscriptions_rounded,
    ),
    (
      name: 'Outros (saída)',
      type: CategoryType.expense,
      colorHex: '#546E7A',
      icon: Icons.remove_circle_outline_rounded,
    ),
  ];

  static List<_CategorySeed> get _all => [..._incomeSeeds, ..._expenseSeeds];

  /// Constrói a lista de [Category] com o [userId] e IDs gerados.
  static List<Category> build({
    required String userId,
    required String Function() idGenerator,
  }) {
    final now = DateTime.now();
    return _all.map((seed) {
      return Category(
        id: idGenerator(),
        userId: userId,
        name: seed.name,
        type: seed.type,
        colorHex: seed.colorHex,
        iconCodePoint: seed.icon.codePoint,
        iconFontFamily: seed.icon.fontFamily ?? 'MaterialIcons',
        isDefault: true,
        createdAt: now,
      );
    }).toList();
  }
}
