// test/features/categories/domain/category_entity_test.dart

import 'package:controle_financeiro/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2026, 1, 1);

  Category makeCategory({
    String id = 'cat-1',
    String userId = 'user-1',
    String name = 'Alimentação',
    CategoryType type = CategoryType.expense,
    String colorHex = '#EF5350',
    int iconCodePoint = 0xe25a, // restaurant icon
    String iconFontFamily = 'MaterialIcons',
    bool isDefault = false,
    DateTime? createdAt,
  }) {
    return Category(
      id: id,
      userId: userId,
      name: name,
      type: type,
      colorHex: colorHex,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      isDefault: isDefault,
      createdAt: createdAt ?? baseDate,
    );
  }

  // ── color getter ──────────────────────────────────────────────────────────
  group('Category.color', () {
    test('parseia hex #EF5350 corretamente', () {
      final category = makeCategory(colorHex: '#EF5350');
      expect(category.color, const Color(0xFFEF5350));
    });

    test('parseia hex #4CAF50 corretamente', () {
      final category = makeCategory(colorHex: '#4CAF50');
      expect(category.color, const Color(0xFF4CAF50));
    });

    test('parseia hex #2196F3 corretamente', () {
      final category = makeCategory(colorHex: '#2196F3');
      expect(category.color, const Color(0xFF2196F3));
    });
  });

  // ── icon getter ───────────────────────────────────────────────────────────
  group('Category.icon', () {
    test('retorna IconData com codePoint correto', () {
      const codePoint = 0xe25a;
      final category = makeCategory(iconCodePoint: codePoint);
      expect(category.icon.codePoint, codePoint);
    });

    test('retorna IconData com fontFamily correto', () {
      final category = makeCategory(iconFontFamily: 'MaterialIcons');
      expect(category.icon.fontFamily, 'MaterialIcons');
    });
  });

  // ── Equatable ─────────────────────────────────────────────────────────────
  group('Category — igualdade (Equatable)', () {
    test('mesmos campos são iguais', () {
      expect(makeCategory(), equals(makeCategory()));
    });

    test('id diferente → diferentes', () {
      expect(
        makeCategory(id: 'c1'),
        isNot(equals(makeCategory(id: 'c2'))),
      );
    });

    test('type diferente → diferentes', () {
      expect(
        makeCategory(type: CategoryType.expense),
        isNot(equals(makeCategory(type: CategoryType.income))),
      );
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('Category.copyWith', () {
    test('altera name e mantém demais campos', () {
      final original = makeCategory();
      final copy = original.copyWith(name: 'Lazer');
      expect(copy.name, 'Lazer');
      expect(copy.id, original.id);
      expect(copy.colorHex, original.colorHex);
    });

    test('sem argumentos retorna objeto equivalente', () {
      final original = makeCategory();
      expect(original.copyWith(), equals(original));
    });

    test('altera colorHex', () {
      final copy = makeCategory().copyWith(colorHex: '#000000');
      expect(copy.colorHex, '#000000');
    });

    test('altera isDefault', () {
      final copy = makeCategory(isDefault: false).copyWith(isDefault: true);
      expect(copy.isDefault, true);
    });
  });

  // ── CategoryType ──────────────────────────────────────────────────────────
  group('CategoryType', () {
    test('possui income e expense', () {
      expect(CategoryType.values, containsAll([CategoryType.income, CategoryType.expense]));
    });
  });
}
