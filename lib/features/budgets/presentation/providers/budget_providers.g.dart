// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetRemoteDataSourceHash() =>
    r'ccd4321ff616510c9c2ef33583ce33b0596e1173';

/// See also [budgetRemoteDataSource].
@ProviderFor(budgetRemoteDataSource)
final budgetRemoteDataSourceProvider =
    Provider<BudgetRemoteDataSource>.internal(
  budgetRemoteDataSource,
  name: r'budgetRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetRemoteDataSourceRef = ProviderRef<BudgetRemoteDataSource>;
String _$budgetRepositoryHash() => r'8f6493a48a9039400e095f90ef14085cd6d22c1a';

/// See also [budgetRepository].
@ProviderFor(budgetRepository)
final budgetRepositoryProvider = Provider<BudgetRepository>.internal(
  budgetRepository,
  name: r'budgetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetRepositoryRef = ProviderRef<BudgetRepository>;
String _$watchBudgetsHash() => r'2bf7ff5245b9e4b3cb9f8c86946c1973f5de204c';

/// Stream de orçamentos ativos do usuário.
///
/// Copied from [watchBudgets].
@ProviderFor(watchBudgets)
final watchBudgetsProvider = AutoDisposeStreamProvider<List<Budget>>.internal(
  watchBudgets,
  name: r'watchBudgetsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchBudgetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchBudgetsRef = AutoDisposeStreamProviderRef<List<Budget>>;
String _$budgetProgressListHash() =>
    r'4c366af82b6d09e4a62e91c1a7e3e60383e2e73e';

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

/// Lista de [BudgetProgress] calculada para o mês informado.
///
/// Busca o valor gasto de cada orçamento ativo via [BudgetRepository.getSpentAmount].
///
/// Copied from [budgetProgressList].
@ProviderFor(budgetProgressList)
const budgetProgressListProvider = BudgetProgressListFamily();

/// Lista de [BudgetProgress] calculada para o mês informado.
///
/// Busca o valor gasto de cada orçamento ativo via [BudgetRepository.getSpentAmount].
///
/// Copied from [budgetProgressList].
class BudgetProgressListFamily
    extends Family<AsyncValue<List<BudgetProgress>>> {
  /// Lista de [BudgetProgress] calculada para o mês informado.
  ///
  /// Busca o valor gasto de cada orçamento ativo via [BudgetRepository.getSpentAmount].
  ///
  /// Copied from [budgetProgressList].
  const BudgetProgressListFamily();

  /// Lista de [BudgetProgress] calculada para o mês informado.
  ///
  /// Busca o valor gasto de cada orçamento ativo via [BudgetRepository.getSpentAmount].
  ///
  /// Copied from [budgetProgressList].
  BudgetProgressListProvider call(
    DateTime month,
  ) {
    return BudgetProgressListProvider(
      month,
    );
  }

  @override
  BudgetProgressListProvider getProviderOverride(
    covariant BudgetProgressListProvider provider,
  ) {
    return call(
      provider.month,
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
  String? get name => r'budgetProgressListProvider';
}

/// Lista de [BudgetProgress] calculada para o mês informado.
///
/// Busca o valor gasto de cada orçamento ativo via [BudgetRepository.getSpentAmount].
///
/// Copied from [budgetProgressList].
class BudgetProgressListProvider
    extends AutoDisposeFutureProvider<List<BudgetProgress>> {
  /// Lista de [BudgetProgress] calculada para o mês informado.
  ///
  /// Busca o valor gasto de cada orçamento ativo via [BudgetRepository.getSpentAmount].
  ///
  /// Copied from [budgetProgressList].
  BudgetProgressListProvider(
    DateTime month,
  ) : this._internal(
          (ref) => budgetProgressList(
            ref as BudgetProgressListRef,
            month,
          ),
          from: budgetProgressListProvider,
          name: r'budgetProgressListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$budgetProgressListHash,
          dependencies: BudgetProgressListFamily._dependencies,
          allTransitiveDependencies:
              BudgetProgressListFamily._allTransitiveDependencies,
          month: month,
        );

  BudgetProgressListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<List<BudgetProgress>> Function(BudgetProgressListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BudgetProgressListProvider._internal(
        (ref) => create(ref as BudgetProgressListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BudgetProgress>> createElement() {
    return _BudgetProgressListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetProgressListProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BudgetProgressListRef
    on AutoDisposeFutureProviderRef<List<BudgetProgress>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _BudgetProgressListProviderElement
    extends AutoDisposeFutureProviderElement<List<BudgetProgress>>
    with BudgetProgressListRef {
  _BudgetProgressListProviderElement(super.provider);

  @override
  DateTime get month => (origin as BudgetProgressListProvider).month;
}

String _$budgetNotifierHash() => r'fde2a6aa385cd8782726201e65fcda67194d9bad';

/// Notifier responsável por criar, editar e remover orçamentos.
///
/// Copied from [BudgetNotifier].
@ProviderFor(BudgetNotifier)
final budgetNotifierProvider =
    AutoDisposeNotifierProvider<BudgetNotifier, AsyncValue<void>>.internal(
  BudgetNotifier.new,
  name: r'budgetNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BudgetNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
