// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryRepositoryHash() =>
    r'2813bcc5f924412b9a1ec94f00427ed8ce2daff2';

/// Repositório de categorias com escopo no usuário autenticado.
///
/// Copied from [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider = Provider<CategoryRepository>.internal(
  categoryRepository,
  name: r'categoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryRepositoryRef = ProviderRef<CategoryRepository>;
String _$watchCategoriesHash() => r'd26b72620d0b0ce35c34a5408f57c52d365da784';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Stream de categorias do usuário com filtro opcional por tipo.
///
/// Uso:
/// ```dart
/// ref.watch(watchCategoriesProvider(null))           // todas
/// ref.watch(watchCategoriesProvider(CategoryType.expense)) // despesas
/// ```
///
/// Copied from [watchCategories].
@ProviderFor(watchCategories)
const watchCategoriesProvider = WatchCategoriesFamily();

/// Stream de categorias do usuário com filtro opcional por tipo.
///
/// Uso:
/// ```dart
/// ref.watch(watchCategoriesProvider(null))           // todas
/// ref.watch(watchCategoriesProvider(CategoryType.expense)) // despesas
/// ```
///
/// Copied from [watchCategories].
class WatchCategoriesFamily extends Family<AsyncValue<List<Category>>> {
  /// Stream de categorias do usuário com filtro opcional por tipo.
  ///
  /// Uso:
  /// ```dart
  /// ref.watch(watchCategoriesProvider(null))           // todas
  /// ref.watch(watchCategoriesProvider(CategoryType.expense)) // despesas
  /// ```
  ///
  /// Copied from [watchCategories].
  const WatchCategoriesFamily();

  /// Stream de categorias do usuário com filtro opcional por tipo.
  ///
  /// Uso:
  /// ```dart
  /// ref.watch(watchCategoriesProvider(null))           // todas
  /// ref.watch(watchCategoriesProvider(CategoryType.expense)) // despesas
  /// ```
  ///
  /// Copied from [watchCategories].
  WatchCategoriesProvider call(
    CategoryType? type,
  ) {
    return WatchCategoriesProvider(
      type,
    );
  }

  @override
  WatchCategoriesProvider getProviderOverride(
    covariant WatchCategoriesProvider provider,
  ) {
    return call(
      provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'watchCategoriesProvider';
}

/// Stream de categorias do usuário com filtro opcional por tipo.
///
/// Uso:
/// ```dart
/// ref.watch(watchCategoriesProvider(null))           // todas
/// ref.watch(watchCategoriesProvider(CategoryType.expense)) // despesas
/// ```
///
/// Copied from [watchCategories].
class WatchCategoriesProvider
    extends AutoDisposeStreamProvider<List<Category>> {
  /// Stream de categorias do usuário com filtro opcional por tipo.
  ///
  /// Uso:
  /// ```dart
  /// ref.watch(watchCategoriesProvider(null))           // todas
  /// ref.watch(watchCategoriesProvider(CategoryType.expense)) // despesas
  /// ```
  ///
  /// Copied from [watchCategories].
  WatchCategoriesProvider(
    CategoryType? type,
  ) : this._internal(
          (ref) => watchCategories(
            ref as WatchCategoriesRef,
            type,
          ),
          from: watchCategoriesProvider,
          name: r'watchCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchCategoriesHash,
          dependencies: WatchCategoriesFamily._dependencies,
          allTransitiveDependencies:
              WatchCategoriesFamily._allTransitiveDependencies,
          type: type,
        );

  WatchCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final CategoryType? type;

  @override
  Override overrideWith(
    Stream<List<Category>> Function(WatchCategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchCategoriesProvider._internal(
        (ref) => create(ref as WatchCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Category>> createElement() {
    return _WatchCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCategoriesProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchCategoriesRef on AutoDisposeStreamProviderRef<List<Category>> {
  /// The parameter `type` of this provider.
  CategoryType? get type;
}

class _WatchCategoriesProviderElement
    extends AutoDisposeStreamProviderElement<List<Category>>
    with WatchCategoriesRef {
  _WatchCategoriesProviderElement(super.provider);

  @override
  CategoryType? get type => (origin as WatchCategoriesProvider).type;
}

String _$categoryNotifierHash() => r'73fa599de8b64af11c298b41a9206b95e1a96839';

/// Notifier responsável por criar, editar e remover categorias.
///
/// Copied from [CategoryNotifier].
@ProviderFor(CategoryNotifier)
final categoryNotifierProvider =
    AutoDisposeNotifierProvider<CategoryNotifier, AsyncValue<void>>.internal(
  CategoryNotifier.new,
  name: r'categoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
