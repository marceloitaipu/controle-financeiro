// lib/features/categories/presentation/providers/category_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

part 'category_providers.g.dart';

// ── Repositório ────────────────────────────────────────────────────────────

/// Repositório de categorias com escopo no usuário autenticado.
@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  final userId = ref.watch(currentUserIdProvider);
  return CategoryRepositoryImpl(
    ref.watch(categoryRemoteDataSourceProvider),
    userId,
  );
}

// ── Stream de categorias ───────────────────────────────────────────────────

/// Stream de categorias do usuário com filtro opcional por tipo.
///
/// Uso:
/// ```dart
/// ref.watch(watchCategoriesProvider(null))           // todas
/// ref.watch(watchCategoriesProvider(CategoryType.expense)) // despesas
/// ```
@riverpod
Stream<List<Category>> watchCategories(Ref ref, CategoryType? type) {
  return ref.watch(categoryRepositoryProvider).watchCategories(type: type);
}

// ── CRUD ───────────────────────────────────────────────────────────────────

/// Notifier responsável por criar, editar e remover categorias.
@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createCategory(Category category) async {
    state = const AsyncLoading();
    final result =
        await ref.read(categoryRepositoryProvider).createCategory(category);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> updateCategory(Category category) async {
    state = const AsyncLoading();
    final result =
        await ref.read(categoryRepositoryProvider).updateCategory(category);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> deleteCategory(String id) async {
    state = const AsyncLoading();
    final result =
        await ref.read(categoryRepositoryProvider).deleteCategory(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}
