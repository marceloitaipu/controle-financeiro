// lib/features/categories/domain/entities/category.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Tipo da categoria.
enum CategoryType { income, expense }

/// Entidade imutável de domínio para categorias de transação.
final class Category extends Equatable {
  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.colorHex,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final CategoryType type;

  /// Cor como string hex, ex: '#EF5350'
  final String colorHex;

  /// [IconData.codePoint] do ícone
  final int iconCodePoint;

  /// [IconData.fontFamily] do ícone
  final String iconFontFamily;

  /// Categoria criada pelo seed padrão
  final bool isDefault;

  final DateTime createdAt;
  final DateTime? updatedAt;

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: iconFontFamily,
      );

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    CategoryType? type,
    String? colorHex,
    int? iconCodePoint,
    String? iconFontFamily,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        colorHex,
        iconCodePoint,
        iconFontFamily,
        isDefault,
        createdAt,
        updatedAt,
      ];
}
