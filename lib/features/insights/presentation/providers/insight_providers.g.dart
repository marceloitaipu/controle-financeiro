// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentMonthTransactionsHash() =>
    r'3de3af8632a0dee9dd0a2e44bf7640b9619f975d';

/// Stream de transações do mês atual, usadas para apurar a principal categoria.
///
/// Copied from [currentMonthTransactions].
@ProviderFor(currentMonthTransactions)
final currentMonthTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
  currentMonthTransactions,
  name: r'currentMonthTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMonthTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMonthTransactionsRef
    = AutoDisposeStreamProviderRef<List<Transaction>>;
String _$currentMonthInsightsHash() =>
    r'ceae637605425a08c7c1be25ace8e7285dba5ffb';

/// Gera a lista de insights financeiros para o usuário no mês corrente.
///
/// Agrega dados de orçamentos, metas, resumo mensal e transações para
/// produzir análises automáticas, ordenadas por severidade decrescente.
///
/// Copied from [currentMonthInsights].
@ProviderFor(currentMonthInsights)
final currentMonthInsightsProvider =
    AutoDisposeFutureProvider<List<Insight>>.internal(
  currentMonthInsights,
  name: r'currentMonthInsightsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMonthInsightsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMonthInsightsRef = AutoDisposeFutureProviderRef<List<Insight>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
