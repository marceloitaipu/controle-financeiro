// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$creditCardRemoteDataSourceHash() =>
    r'74879d5d3d6dc5f817c11d67c0f0865ebb867f9a';

/// See also [creditCardRemoteDataSource].
@ProviderFor(creditCardRemoteDataSource)
final creditCardRemoteDataSourceProvider =
    Provider<CreditCardRemoteDataSource>.internal(
  creditCardRemoteDataSource,
  name: r'creditCardRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$creditCardRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreditCardRemoteDataSourceRef = ProviderRef<CreditCardRemoteDataSource>;
String _$creditCardRepositoryHash() =>
    r'43a994415ecc0bf56e2a251cdecf4d98c07af3aa';

/// See also [creditCardRepository].
@ProviderFor(creditCardRepository)
final creditCardRepositoryProvider = Provider<CreditCardRepository>.internal(
  creditCardRepository,
  name: r'creditCardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$creditCardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreditCardRepositoryRef = ProviderRef<CreditCardRepository>;
String _$watchCreditCardsHash() => r'3c25d188763d28f8feb5012b9af3ff1b8c844544';

/// See also [watchCreditCards].
@ProviderFor(watchCreditCards)
final watchCreditCardsProvider =
    AutoDisposeStreamProvider<List<CreditCard>>.internal(
  watchCreditCards,
  name: r'watchCreditCardsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchCreditCardsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchCreditCardsRef = AutoDisposeStreamProviderRef<List<CreditCard>>;
String _$watchInvoicesHash() => r'2578e6def6f49fb77b6dd65a475b96a1aa9de9c2';

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

/// See also [watchInvoices].
@ProviderFor(watchInvoices)
const watchInvoicesProvider = WatchInvoicesFamily();

/// See also [watchInvoices].
class WatchInvoicesFamily extends Family<AsyncValue<List<Invoice>>> {
  /// See also [watchInvoices].
  const WatchInvoicesFamily();

  /// See also [watchInvoices].
  WatchInvoicesProvider call(
    String cardId,
  ) {
    return WatchInvoicesProvider(
      cardId,
    );
  }

  @override
  WatchInvoicesProvider getProviderOverride(
    covariant WatchInvoicesProvider provider,
  ) {
    return call(
      provider.cardId,
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
  String? get name => r'watchInvoicesProvider';
}

/// See also [watchInvoices].
class WatchInvoicesProvider extends AutoDisposeStreamProvider<List<Invoice>> {
  /// See also [watchInvoices].
  WatchInvoicesProvider(
    String cardId,
  ) : this._internal(
          (ref) => watchInvoices(
            ref as WatchInvoicesRef,
            cardId,
          ),
          from: watchInvoicesProvider,
          name: r'watchInvoicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchInvoicesHash,
          dependencies: WatchInvoicesFamily._dependencies,
          allTransitiveDependencies:
              WatchInvoicesFamily._allTransitiveDependencies,
          cardId: cardId,
        );

  WatchInvoicesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cardId,
  }) : super.internal();

  final String cardId;

  @override
  Override overrideWith(
    Stream<List<Invoice>> Function(WatchInvoicesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchInvoicesProvider._internal(
        (ref) => create(ref as WatchInvoicesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cardId: cardId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Invoice>> createElement() {
    return _WatchInvoicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchInvoicesProvider && other.cardId == cardId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cardId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchInvoicesRef on AutoDisposeStreamProviderRef<List<Invoice>> {
  /// The parameter `cardId` of this provider.
  String get cardId;
}

class _WatchInvoicesProviderElement
    extends AutoDisposeStreamProviderElement<List<Invoice>>
    with WatchInvoicesRef {
  _WatchInvoicesProviderElement(super.provider);

  @override
  String get cardId => (origin as WatchInvoicesProvider).cardId;
}

String _$creditCardNotifierHash() =>
    r'2e0206a467da4d0a08a875582e648007694d4028';

/// Notifier para operações de criação, edição e exclusão de cartões.
///
/// Copied from [CreditCardNotifier].
@ProviderFor(CreditCardNotifier)
final creditCardNotifierProvider =
    AutoDisposeNotifierProvider<CreditCardNotifier, AsyncValue<void>>.internal(
  CreditCardNotifier.new,
  name: r'creditCardNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$creditCardNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreditCardNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$purchaseNotifierHash() => r'7b2f395a2462689fc6f840e0374ca522bd4f3bc2';

/// Notifier para criação de compras no cartão de crédito (com suporte a parcelamento).
///
/// Para cada parcela, cria uma transação com [accountId] vazio e atualiza o
/// total da fatura do mês correspondente de forma atômica.
///
/// Copied from [PurchaseNotifier].
@ProviderFor(PurchaseNotifier)
final purchaseNotifierProvider =
    AutoDisposeNotifierProvider<PurchaseNotifier, AsyncValue<void>>.internal(
  PurchaseNotifier.new,
  name: r'purchaseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purchaseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PurchaseNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$payInvoiceNotifierHash() =>
    r'4c237029891be3b058823c061c3515ccd6c6db9e';

/// Notifier para pagamento de fatura de cartão de crédito.
///
/// 1. Cria uma transação de despesa na conta de pagamento.
/// 2. Marca a fatura como paga com o ID da transação criada.
///
/// Copied from [PayInvoiceNotifier].
@ProviderFor(PayInvoiceNotifier)
final payInvoiceNotifierProvider =
    AutoDisposeNotifierProvider<PayInvoiceNotifier, AsyncValue<void>>.internal(
  PayInvoiceNotifier.new,
  name: r'payInvoiceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$payInvoiceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PayInvoiceNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
