// lib/features/categories/data/repositories/category_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

final class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource, this._userId);

  final CategoryRemoteDataSource _dataSource;
  final String _userId;

  Failure _mapException(AppException e) => switch (e) {
        AuthException() => AuthFailure(e.message),
        NotFoundException() => NotFoundFailure(e.message),
        NetworkException() => NetworkFailure(e.message),
        ValidationException() => ValidationFailure(e.message),
        ConflictException() => ConflictFailure(e.message),
        StorageException() => StorageFailure(e.message),
        CancelledException() => CancelledFailure(e.message),
        UnexpectedException() => UnexpectedFailure(e.message),
      };

  @override
  Stream<List<Category>> watchCategories({CategoryType? type}) {
    return _dataSource
        .watchCategories(_userId, type: type)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final model = await _dataSource.getCategoryById(_userId, id);
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('CategoryRepo.getCategoryById', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(Category category) async {
    try {
      final model = await _dataSource.createCategory(
        CategoryModel.fromEntity(category),
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('CategoryRepo.createCategory', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      final model = await _dataSource.updateCategory(
        CategoryModel.fromEntity(category),
      );
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('CategoryRepo.updateCategory', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _dataSource.deleteCategory(_userId, id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('CategoryRepo.deleteCategory', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> seedDefaultCategories(String userId) async {
    try {
      await _dataSource.seedDefaultCategories(userId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('CategoryRepo.seedDefaultCategories', e, st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasCategories() async {
    try {
      final result = await _dataSource.hasCategories(_userId);
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapException(e));
    } catch (e, st) {
      AppLogger.error('CategoryRepo.hasCategories', e, st);
      return const Left(UnexpectedFailure());
    }
  }
}
