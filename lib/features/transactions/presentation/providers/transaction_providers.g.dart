// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRemoteDataSourceHash() =>
    r'f5a424dcabfa2d76422424784f9d6bf0e046963e';

/// See also [transactionRemoteDataSource].
@ProviderFor(transactionRemoteDataSource)
final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>.internal(
  transactionRemoteDataSource,
  name: r'transactionRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRemoteDataSourceRef
    = ProviderRef<TransactionRemoteDataSource>;
String _$transactionRepositoryHash() =>
    r'0d6a466eb1547ea5f715ba214719fa13314a0db8';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider = Provider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef = ProviderRef<TransactionRepository>;
String _$watchRecentTransactionsHash() =>
    r'b00f27792f7f7ee4386b967df5d4f211bd219385';

/// Últimas 10 transações do usuário, ordenadas por data desc.
///
/// Copied from [watchRecentTransactions].
@ProviderFor(watchRecentTransactions)
final watchRecentTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
  watchRecentTransactions,
  name: r'watchRecentTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchRecentTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchRecentTransactionsRef
    = AutoDisposeStreamProviderRef<List<Transaction>>;
String _$monthlyIncomeHash() => r'446eb6658c9a1f108ea51d844bfc62bc08b31307';

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

/// Total de receitas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
///
/// Copied from [monthlyIncome].
@ProviderFor(monthlyIncome)
const monthlyIncomeProvider = MonthlyIncomeFamily();

/// Total de receitas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
///
/// Copied from [monthlyIncome].
class MonthlyIncomeFamily extends Family<AsyncValue<int>> {
  /// Total de receitas em um determinado mês.
  /// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
  ///
  /// Copied from [monthlyIncome].
  const MonthlyIncomeFamily();

  /// Total de receitas em um determinado mês.
  /// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
  ///
  /// Copied from [monthlyIncome].
  MonthlyIncomeProvider call(
    DateTime month,
  ) {
    return MonthlyIncomeProvider(
      month,
    );
  }

  @override
  MonthlyIncomeProvider getProviderOverride(
    covariant MonthlyIncomeProvider provider,
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
  String? get name => r'monthlyIncomeProvider';
}

/// Total de receitas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
///
/// Copied from [monthlyIncome].
class MonthlyIncomeProvider extends AutoDisposeFutureProvider<int> {
  /// Total de receitas em um determinado mês.
  /// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
  ///
  /// Copied from [monthlyIncome].
  MonthlyIncomeProvider(
    DateTime month,
  ) : this._internal(
          (ref) => monthlyIncome(
            ref as MonthlyIncomeRef,
            month,
          ),
          from: monthlyIncomeProvider,
          name: r'monthlyIncomeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyIncomeHash,
          dependencies: MonthlyIncomeFamily._dependencies,
          allTransitiveDependencies:
              MonthlyIncomeFamily._allTransitiveDependencies,
          month: month,
        );

  MonthlyIncomeProvider._internal(
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
    FutureOr<int> Function(MonthlyIncomeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyIncomeProvider._internal(
        (ref) => create(ref as MonthlyIncomeRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _MonthlyIncomeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyIncomeProvider && other.month == month;
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
mixin MonthlyIncomeRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlyIncomeProviderElement
    extends AutoDisposeFutureProviderElement<int> with MonthlyIncomeRef {
  _MonthlyIncomeProviderElement(super.provider);

  @override
  DateTime get month => (origin as MonthlyIncomeProvider).month;
}

String _$monthlyExpenseHash() => r'c515b41e2fc6930ea73c847f8f4b2a515094b90a';

/// Total de despesas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
///
/// Copied from [monthlyExpense].
@ProviderFor(monthlyExpense)
const monthlyExpenseProvider = MonthlyExpenseFamily();

/// Total de despesas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
///
/// Copied from [monthlyExpense].
class MonthlyExpenseFamily extends Family<AsyncValue<int>> {
  /// Total de despesas em um determinado mês.
  /// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
  ///
  /// Copied from [monthlyExpense].
  const MonthlyExpenseFamily();

  /// Total de despesas em um determinado mês.
  /// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
  ///
  /// Copied from [monthlyExpense].
  MonthlyExpenseProvider call(
    DateTime month,
  ) {
    return MonthlyExpenseProvider(
      month,
    );
  }

  @override
  MonthlyExpenseProvider getProviderOverride(
    covariant MonthlyExpenseProvider provider,
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
  String? get name => r'monthlyExpenseProvider';
}

/// Total de despesas em um determinado mês.
/// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
///
/// Copied from [monthlyExpense].
class MonthlyExpenseProvider extends AutoDisposeFutureProvider<int> {
  /// Total de despesas em um determinado mês.
  /// [month] deve ser o primeiro dia do mês (ex: DateTime(2025, 4)).
  ///
  /// Copied from [monthlyExpense].
  MonthlyExpenseProvider(
    DateTime month,
  ) : this._internal(
          (ref) => monthlyExpense(
            ref as MonthlyExpenseRef,
            month,
          ),
          from: monthlyExpenseProvider,
          name: r'monthlyExpenseProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyExpenseHash,
          dependencies: MonthlyExpenseFamily._dependencies,
          allTransitiveDependencies:
              MonthlyExpenseFamily._allTransitiveDependencies,
          month: month,
        );

  MonthlyExpenseProvider._internal(
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
    FutureOr<int> Function(MonthlyExpenseRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyExpenseProvider._internal(
        (ref) => create(ref as MonthlyExpenseRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _MonthlyExpenseProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyExpenseProvider && other.month == month;
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
mixin MonthlyExpenseRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlyExpenseProviderElement
    extends AutoDisposeFutureProviderElement<int> with MonthlyExpenseRef {
  _MonthlyExpenseProviderElement(super.provider);

  @override
  DateTime get month => (origin as MonthlyExpenseProvider).month;
}

String _$monthlySummaryListHash() =>
    r'37fe777145f5897d416a738a6a829f6a2ad61ff0';

/// Retorna o resumo dos últimos 6 meses para exibição em gráfico.
///
/// Copied from [monthlySummaryList].
@ProviderFor(monthlySummaryList)
final monthlySummaryListProvider =
    AutoDisposeFutureProvider<List<MonthlySummary>>.internal(
  monthlySummaryList,
  name: r'monthlySummaryListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlySummaryListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlySummaryListRef
    = AutoDisposeFutureProviderRef<List<MonthlySummary>>;
String _$watchFilteredTransactionsHash() =>
    r'e6b43079887330673a8003a3ca07a8a23d82d8dc';

/// Stream de transações com filtros dinâmicos aplicados.
///
/// Copied from [watchFilteredTransactions].
@ProviderFor(watchFilteredTransactions)
final watchFilteredTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
  watchFilteredTransactions,
  name: r'watchFilteredTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchFilteredTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchFilteredTransactionsRef
    = AutoDisposeStreamProviderRef<List<Transaction>>;
String _$transactionByIdHash() => r'b9bffbca49f9cb950eee5050833f0d6eb8316861';

/// Carrega uma transação específica por ID (para tela de detalhe).
///
/// Copied from [transactionById].
@ProviderFor(transactionById)
const transactionByIdProvider = TransactionByIdFamily();

/// Carrega uma transação específica por ID (para tela de detalhe).
///
/// Copied from [transactionById].
class TransactionByIdFamily extends Family<AsyncValue<Transaction?>> {
  /// Carrega uma transação específica por ID (para tela de detalhe).
  ///
  /// Copied from [transactionById].
  const TransactionByIdFamily();

  /// Carrega uma transação específica por ID (para tela de detalhe).
  ///
  /// Copied from [transactionById].
  TransactionByIdProvider call(
    String id,
  ) {
    return TransactionByIdProvider(
      id,
    );
  }

  @override
  TransactionByIdProvider getProviderOverride(
    covariant TransactionByIdProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'transactionByIdProvider';
}

/// Carrega uma transação específica por ID (para tela de detalhe).
///
/// Copied from [transactionById].
class TransactionByIdProvider extends AutoDisposeFutureProvider<Transaction?> {
  /// Carrega uma transação específica por ID (para tela de detalhe).
  ///
  /// Copied from [transactionById].
  TransactionByIdProvider(
    String id,
  ) : this._internal(
          (ref) => transactionById(
            ref as TransactionByIdRef,
            id,
          ),
          from: transactionByIdProvider,
          name: r'transactionByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionByIdHash,
          dependencies: TransactionByIdFamily._dependencies,
          allTransitiveDependencies:
              TransactionByIdFamily._allTransitiveDependencies,
          id: id,
        );

  TransactionByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Transaction?> Function(TransactionByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionByIdProvider._internal(
        (ref) => create(ref as TransactionByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Transaction?> createElement() {
    return _TransactionByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionByIdRef on AutoDisposeFutureProviderRef<Transaction?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TransactionByIdProviderElement
    extends AutoDisposeFutureProviderElement<Transaction?>
    with TransactionByIdRef {
  _TransactionByIdProviderElement(super.provider);

  @override
  String get id => (origin as TransactionByIdProvider).id;
}

String _$watchAccountTransactionsHash() =>
    r'605f4b9bf27927f86d57b57b22f894945036bec3';

/// Stream das últimas 30 transações de uma conta específica.
///
/// Usado na tela de detalhe da conta para exibir o extrato.
///
/// Copied from [watchAccountTransactions].
@ProviderFor(watchAccountTransactions)
const watchAccountTransactionsProvider = WatchAccountTransactionsFamily();

/// Stream das últimas 30 transações de uma conta específica.
///
/// Usado na tela de detalhe da conta para exibir o extrato.
///
/// Copied from [watchAccountTransactions].
class WatchAccountTransactionsFamily
    extends Family<AsyncValue<List<Transaction>>> {
  /// Stream das últimas 30 transações de uma conta específica.
  ///
  /// Usado na tela de detalhe da conta para exibir o extrato.
  ///
  /// Copied from [watchAccountTransactions].
  const WatchAccountTransactionsFamily();

  /// Stream das últimas 30 transações de uma conta específica.
  ///
  /// Usado na tela de detalhe da conta para exibir o extrato.
  ///
  /// Copied from [watchAccountTransactions].
  WatchAccountTransactionsProvider call(
    String accountId,
  ) {
    return WatchAccountTransactionsProvider(
      accountId,
    );
  }

  @override
  WatchAccountTransactionsProvider getProviderOverride(
    covariant WatchAccountTransactionsProvider provider,
  ) {
    return call(
      provider.accountId,
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
  String? get name => r'watchAccountTransactionsProvider';
}

/// Stream das últimas 30 transações de uma conta específica.
///
/// Usado na tela de detalhe da conta para exibir o extrato.
///
/// Copied from [watchAccountTransactions].
class WatchAccountTransactionsProvider
    extends AutoDisposeStreamProvider<List<Transaction>> {
  /// Stream das últimas 30 transações de uma conta específica.
  ///
  /// Usado na tela de detalhe da conta para exibir o extrato.
  ///
  /// Copied from [watchAccountTransactions].
  WatchAccountTransactionsProvider(
    String accountId,
  ) : this._internal(
          (ref) => watchAccountTransactions(
            ref as WatchAccountTransactionsRef,
            accountId,
          ),
          from: watchAccountTransactionsProvider,
          name: r'watchAccountTransactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchAccountTransactionsHash,
          dependencies: WatchAccountTransactionsFamily._dependencies,
          allTransitiveDependencies:
              WatchAccountTransactionsFamily._allTransitiveDependencies,
          accountId: accountId,
        );

  WatchAccountTransactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.accountId,
  }) : super.internal();

  final String accountId;

  @override
  Override overrideWith(
    Stream<List<Transaction>> Function(WatchAccountTransactionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchAccountTransactionsProvider._internal(
        (ref) => create(ref as WatchAccountTransactionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        accountId: accountId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Transaction>> createElement() {
    return _WatchAccountTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchAccountTransactionsProvider &&
        other.accountId == accountId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchAccountTransactionsRef
    on AutoDisposeStreamProviderRef<List<Transaction>> {
  /// The parameter `accountId` of this provider.
  String get accountId;
}

class _WatchAccountTransactionsProviderElement
    extends AutoDisposeStreamProviderElement<List<Transaction>>
    with WatchAccountTransactionsRef {
  _WatchAccountTransactionsProviderElement(super.provider);

  @override
  String get accountId =>
      (origin as WatchAccountTransactionsProvider).accountId;
}

String _$watchCreditCardTransactionsHash() =>
    r'ced19204c8962a6286d1b2cb7d6c5aa3aa782b9e';

/// Stream das transações de um cartão de crédito para um período de fatura.
///
/// [yearMonth] no formato 'YYYY-MM'. Filtra um intervalo amplo que cobre o
/// ciclo de cobrança típico (mês anterior + mês atual).
///
/// Copied from [watchCreditCardTransactions].
@ProviderFor(watchCreditCardTransactions)
const watchCreditCardTransactionsProvider = WatchCreditCardTransactionsFamily();

/// Stream das transações de um cartão de crédito para um período de fatura.
///
/// [yearMonth] no formato 'YYYY-MM'. Filtra um intervalo amplo que cobre o
/// ciclo de cobrança típico (mês anterior + mês atual).
///
/// Copied from [watchCreditCardTransactions].
class WatchCreditCardTransactionsFamily
    extends Family<AsyncValue<List<Transaction>>> {
  /// Stream das transações de um cartão de crédito para um período de fatura.
  ///
  /// [yearMonth] no formato 'YYYY-MM'. Filtra um intervalo amplo que cobre o
  /// ciclo de cobrança típico (mês anterior + mês atual).
  ///
  /// Copied from [watchCreditCardTransactions].
  const WatchCreditCardTransactionsFamily();

  /// Stream das transações de um cartão de crédito para um período de fatura.
  ///
  /// [yearMonth] no formato 'YYYY-MM'. Filtra um intervalo amplo que cobre o
  /// ciclo de cobrança típico (mês anterior + mês atual).
  ///
  /// Copied from [watchCreditCardTransactions].
  WatchCreditCardTransactionsProvider call(
    String cardId,
    String yearMonth,
  ) {
    return WatchCreditCardTransactionsProvider(
      cardId,
      yearMonth,
    );
  }

  @override
  WatchCreditCardTransactionsProvider getProviderOverride(
    covariant WatchCreditCardTransactionsProvider provider,
  ) {
    return call(
      provider.cardId,
      provider.yearMonth,
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
  String? get name => r'watchCreditCardTransactionsProvider';
}

/// Stream das transações de um cartão de crédito para um período de fatura.
///
/// [yearMonth] no formato 'YYYY-MM'. Filtra um intervalo amplo que cobre o
/// ciclo de cobrança típico (mês anterior + mês atual).
///
/// Copied from [watchCreditCardTransactions].
class WatchCreditCardTransactionsProvider
    extends AutoDisposeStreamProvider<List<Transaction>> {
  /// Stream das transações de um cartão de crédito para um período de fatura.
  ///
  /// [yearMonth] no formato 'YYYY-MM'. Filtra um intervalo amplo que cobre o
  /// ciclo de cobrança típico (mês anterior + mês atual).
  ///
  /// Copied from [watchCreditCardTransactions].
  WatchCreditCardTransactionsProvider(
    String cardId,
    String yearMonth,
  ) : this._internal(
          (ref) => watchCreditCardTransactions(
            ref as WatchCreditCardTransactionsRef,
            cardId,
            yearMonth,
          ),
          from: watchCreditCardTransactionsProvider,
          name: r'watchCreditCardTransactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchCreditCardTransactionsHash,
          dependencies: WatchCreditCardTransactionsFamily._dependencies,
          allTransitiveDependencies:
              WatchCreditCardTransactionsFamily._allTransitiveDependencies,
          cardId: cardId,
          yearMonth: yearMonth,
        );

  WatchCreditCardTransactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cardId,
    required this.yearMonth,
  }) : super.internal();

  final String cardId;
  final String yearMonth;

  @override
  Override overrideWith(
    Stream<List<Transaction>> Function(WatchCreditCardTransactionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchCreditCardTransactionsProvider._internal(
        (ref) => create(ref as WatchCreditCardTransactionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cardId: cardId,
        yearMonth: yearMonth,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Transaction>> createElement() {
    return _WatchCreditCardTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCreditCardTransactionsProvider &&
        other.cardId == cardId &&
        other.yearMonth == yearMonth;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cardId.hashCode);
    hash = _SystemHash.combine(hash, yearMonth.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchCreditCardTransactionsRef
    on AutoDisposeStreamProviderRef<List<Transaction>> {
  /// The parameter `cardId` of this provider.
  String get cardId;

  /// The parameter `yearMonth` of this provider.
  String get yearMonth;
}

class _WatchCreditCardTransactionsProviderElement
    extends AutoDisposeStreamProviderElement<List<Transaction>>
    with WatchCreditCardTransactionsRef {
  _WatchCreditCardTransactionsProviderElement(super.provider);

  @override
  String get cardId => (origin as WatchCreditCardTransactionsProvider).cardId;
  @override
  String get yearMonth =>
      (origin as WatchCreditCardTransactionsProvider).yearMonth;
}

String _$transactionFilterNotifierHash() =>
    r'08191aa0d7fee06e3f6f7147e99713c34fa19b3b';

/// Notifier do estado de filtros da tela de transações.
///
/// Copied from [TransactionFilterNotifier].
@ProviderFor(TransactionFilterNotifier)
final transactionFilterNotifierProvider = AutoDisposeNotifierProvider<
    TransactionFilterNotifier, TransactionFilterState>.internal(
  TransactionFilterNotifier.new,
  name: r'transactionFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionFilterNotifier
    = AutoDisposeNotifier<TransactionFilterState>;
String _$transactionNotifierHash() =>
    r'b1fe50b1be98d6b0032ac08510686e1abc443934';

/// Notifier para operações de criação, edição e exclusão de transações.
///
/// Estado: [AsyncValue<void>] — AsyncData = idle/success, AsyncLoading = em progresso,
/// AsyncError = falha com mensagem.
///
/// Copied from [TransactionNotifier].
@ProviderFor(TransactionNotifier)
final transactionNotifierProvider =
    AutoDisposeNotifierProvider<TransactionNotifier, AsyncValue<void>>.internal(
  TransactionNotifier.new,
  name: r'transactionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
