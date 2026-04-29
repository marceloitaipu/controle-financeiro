// lib/features/categories/data/models/category_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category.dart';

/// Modelo de dados para serialização Firestore da categoria.
final class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.colorHex,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final CategoryType type;
  final String colorHex;
  final int iconCodePoint;
  final String iconFontFamily;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      type: data['type'] == 'income' ? CategoryType.income : CategoryType.expense,
      colorHex: data['colorHex'] as String,
      iconCodePoint: data['iconCodePoint'] as int,
      iconFontFamily: data['iconFontFamily'] as String? ?? 'MaterialIcons',
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      colorHex: entity.colorHex,
      iconCodePoint: entity.iconCodePoint,
      iconFontFamily: entity.iconFontFamily,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type == CategoryType.income ? 'income' : 'expense',
      'colorHex': colorHex,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      userId: userId,
      name: name,
      type: type,
      colorHex: colorHex,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
