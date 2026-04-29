// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountRemoteDataSourceHash() =>
    r'23447365fe208c3f8d14ec1eec90ce0e97f87c45';

/// See also [accountRemoteDataSource].
@ProviderFor(accountRemoteDataSource)
final accountRemoteDataSourceProvider =
    Provider<AccountRemoteDataSource>.internal(
  accountRemoteDataSource,
  name: r'accountRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccountRemoteDataSourceRef = ProviderRef<AccountRemoteDataSource>;
String _$accountRepositoryHash() => r'273f1e65676c549ab9ea91ea31a6fb2bc033fb66';

/// See also [accountRepository].
@ProviderFor(accountRepository)
final accountRepositoryProvider = Provider<AccountRepository>.internal(
  accountRepository,
  name: r'accountRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccountRepositoryRef = ProviderRef<AccountRepository>;
String _$watchAccountsHash() => r'5a86be121326eb18a9d266f220e018571a2eb0cb';

/// Stream de todas as contas do usuário, ordenadas por nome.
///
/// Copied from [watchAccounts].
@ProviderFor(watchAccounts)
final watchAccountsProvider = AutoDisposeStreamProvider<List<Account>>.internal(
  watchAccounts,
  name: r'watchAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchAccountsRef = AutoDisposeStreamProviderRef<List<Account>>;
String _$totalBalanceHash() => r'327d20568c1619d71fc452f0652b318fb152a4f6';

/// Saldo total de todas as contas marcadas como [includeInTotal].
/// Derivado do stream de contas — atualiza automaticamente.
///
/// Copied from [totalBalance].
@ProviderFor(totalBalance)
final totalBalanceProvider = AutoDisposeProvider<int>.internal(
  totalBalance,
  name: r'totalBalanceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalBalanceRef = AutoDisposeProviderRef<int>;
String _$accountByIdHash() => r'f9c5135e0af9083e0b830d45f21e3ed0d5496a73';

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

/// Carrega uma conta pelo ID (usado na tela de detalhe via deep link).
///
/// Copied from [accountById].
@ProviderFor(accountById)
const accountByIdProvider = AccountByIdFamily();

/// Carrega uma conta pelo ID (usado na tela de detalhe via deep link).
///
/// Copied from [accountById].
class AccountByIdFamily extends Family<AsyncValue<Account?>> {
  /// Carrega uma conta pelo ID (usado na tela de detalhe via deep link).
  ///
  /// Copied from [accountById].
  const AccountByIdFamily();

  /// Carrega uma conta pelo ID (usado na tela de detalhe via deep link).
  ///
  /// Copied from [accountById].
  AccountByIdProvider call(
    String id,
  ) {
    return AccountByIdProvider(
      id,
    );
  }

  @override
  AccountByIdProvider getProviderOverride(
    covariant AccountByIdProvider provider,
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
  String? get name => r'accountByIdProvider';
}

/// Carrega uma conta pelo ID (usado na tela de detalhe via deep link).
///
/// Copied from [accountById].
class AccountByIdProvider extends AutoDisposeFutureProvider<Account?> {
  /// Carrega uma conta pelo ID (usado na tela de detalhe via deep link).
  ///
  /// Copied from [accountById].
  AccountByIdProvider(
    String id,
  ) : this._internal(
          (ref) => accountById(
            ref as AccountByIdRef,
            id,
          ),
          from: accountByIdProvider,
          name: r'accountByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$accountByIdHash,
          dependencies: AccountByIdFamily._dependencies,
          allTransitiveDependencies:
              AccountByIdFamily._allTransitiveDependencies,
          id: id,
        );

  AccountByIdProvider._internal(
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
    FutureOr<Account?> Function(AccountByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountByIdProvider._internal(
        (ref) => create(ref as AccountByIdRef),
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
  AutoDisposeFutureProviderElement<Account?> createElement() {
    return _AccountByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountByIdProvider && other.id == id;
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
mixin AccountByIdRef on AutoDisposeFutureProviderRef<Account?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AccountByIdProviderElement
    extends AutoDisposeFutureProviderElement<Account?> with AccountByIdRef {
  _AccountByIdProviderElement(super.provider);

  @override
  String get id => (origin as AccountByIdProvider).id;
}

String _$accountNotifierHash() => r'cbea3ec460f37b2b278bc1ddef8567034bb98a05';

/// Notifier para criação, edição e exclusão de contas.
///
/// Estado: [AsyncValue<void>] — AsyncData = idle, AsyncLoading = em progresso,
/// AsyncError = falha com mensagem da [Failure].
///
/// Copied from [AccountNotifier].
@ProviderFor(AccountNotifier)
final accountNotifierProvider =
    AutoDisposeNotifierProvider<AccountNotifier, AsyncValue<void>>.internal(
  AccountNotifier.new,
  name: r'accountNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
