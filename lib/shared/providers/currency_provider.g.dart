// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currencyNotifierHash() => r'76da8a7ad4a43ecd1c6d82cdf3ba5399f348a49b';

/// Gerenciador da preferência de moeda do usuário.
///
/// Persiste em [SharedPreferences] sob [AppConstants.kCurrencyKey].
/// keepAlive: true — mantém o estado durante toda a sessão.
///
/// Leitura: `ref.watch(currencyNotifierProvider)`
/// Escrita:  `ref.read(currencyNotifierProvider.notifier).setCurrency(CurrencyOption.usd)`
///
/// Copied from [CurrencyNotifier].
@ProviderFor(CurrencyNotifier)
final currencyNotifierProvider =
    NotifierProvider<CurrencyNotifier, CurrencyOption>.internal(
  CurrencyNotifier.new,
  name: r'currencyNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencyNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrencyNotifier = Notifier<CurrencyOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
