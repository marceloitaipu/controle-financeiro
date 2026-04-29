// lib/features/categories/domain/repositories/category_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/category.dart';

abstract interface class CategoryRepository {
  /// Lista todas as categorias do usuário.
  Stream<List<Category>> watchCategories({CategoryType? type});

  /// Retorna uma categoria pelo ID.
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Cria uma nova categoria.
  Future<Either<Failure, Category>> createCategory(Category category);

  /// Atualiza uma categoria existente.
  Future<Either<Failure, Category>> updateCategory(Category category);

  /// Remove uma categoria.
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Cria as categorias padrão para um novo usuário.
  /// Idempotente — não duplica se já existirem.
  Future<Either<Failure, void>> seedDefaultCategories(String userId);

  /// Verifica se o usuário já possui categorias.
  Future<Either<Failure, bool>> hasCategories();
}
