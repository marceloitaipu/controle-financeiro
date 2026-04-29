// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedMonthNotifierHash() =>
    r'872e93dd9b67c79e961f7bf727e6206362983233';

/// Controla o mês de referência exibido no dashboard.
/// Inicializa com o mês atual e não permite navegar para o futuro.
///
/// Copied from [SelectedMonthNotifier].
@ProviderFor(SelectedMonthNotifier)
final selectedMonthNotifierProvider =
    AutoDisposeNotifierProvider<SelectedMonthNotifier, DateTime>.internal(
  SelectedMonthNotifier.new,
  name: r'selectedMonthNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedMonthNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedMonthNotifier = AutoDisposeNotifier<DateTime>;
String _$balanceVisibilityNotifierHash() =>
    r'824d6767e83d9df257a7662565e68b47cb0a3181';

/// Controla se o saldo total é exibido ou ocultado (•••••).
///
/// Copied from [BalanceVisibilityNotifier].
@ProviderFor(BalanceVisibilityNotifier)
final balanceVisibilityNotifierProvider =
    AutoDisposeNotifierProvider<BalanceVisibilityNotifier, bool>.internal(
  BalanceVisibilityNotifier.new,
  name: r'balanceVisibilityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$balanceVisibilityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BalanceVisibilityNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
