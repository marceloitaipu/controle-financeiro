// lib/features/categories/data/datasources/category_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/default_categories.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

abstract interface class CategoryRemoteDataSource {
  Stream<List<CategoryModel>> watchCategories(
    String userId, {
    CategoryType? type,
  });

  Future<CategoryModel> getCategoryById(String userId, String id);
  Future<CategoryModel> createCategory(CategoryModel model);
  Future<CategoryModel> updateCategory(CategoryModel model);
  Future<void> deleteCategory(String userId, String id);

  /// Cria as categorias padrão. Não duplica se já existirem.
  Future<void> seedDefaultCategories(String userId);

  Future<bool> hasCategories(String userId);
}

final class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      firestore.collection('users').doc(userId).collection('categories');

  @override
  Stream<List<CategoryModel>> watchCategories(
    String userId, {
    CategoryType? type,
  }) {
    Query<Map<String, dynamic>> query = _col(userId).orderBy('name');
    if (type != null) {
      query = query.where(
        'type',
        isEqualTo: type == CategoryType.income ? 'income' : 'expense',
      );
    }
    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<CategoryModel> getCategoryById(String userId, String id) async {
    try {
      final doc = await _col(userId).doc(id).get();
      if (!doc.exists) throw const NotFoundException('Categoria não encontrada.');
      return CategoryModel.fromFirestore(doc);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('Erro ao buscar categoria', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel model) async {
    try {
      final docRef = model.id.isEmpty
          ? _col(model.userId).doc()
          : _col(model.userId).doc(model.id);
      final toSave = model.id.isEmpty
          ? CategoryModel.fromEntity(model.toEntity().copyWith(id: docRef.id))
          : model;
      await docRef.set(toSave.toFirestore());
      return toSave;
    } catch (e, st) {
      AppLogger.error('Erro ao criar categoria', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel model) async {
    try {
      await _col(model.userId).doc(model.id).update(model.toFirestore());
      return model;
    } catch (e, st) {
      AppLogger.error('Erro ao atualizar categoria', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> deleteCategory(String userId, String id) async {
    try {
      await _col(userId).doc(id).delete();
    } catch (e, st) {
      AppLogger.error('Erro ao deletar categoria', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> seedDefaultCategories(String userId) async {
    try {
      final existing = await _col(userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return; // Idempotente

      final categories = DefaultCategories.build(
        userId: userId,
        idGenerator: () => _uuid.v4(),
      );

      final batch = firestore.batch();
      for (final cat in categories) {
        final model = CategoryModel.fromEntity(cat);
        final ref = _col(userId).doc(cat.id);
        batch.set(ref, model.toFirestore());
      }
      await batch.commit();
      AppLogger.info('Seed de categorias criado para $userId');
    } catch (e, st) {
      AppLogger.error('Erro no seed de categorias', e, st);
      throw const UnexpectedException();
    }
  }

  @override
  Future<bool> hasCategories(String userId) async {
    try {
      final snap = await _col(userId).limit(1).get();
      return snap.docs.isNotEmpty;
    } catch (e, st) {
      AppLogger.error('Erro ao verificar categorias', e, st);
      throw const UnexpectedException();
    }
  }
}
