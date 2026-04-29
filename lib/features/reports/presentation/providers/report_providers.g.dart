// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportTransactionsHash() =>
    r'adabe7623c92c4a88cc47731f9f02be4ce18d1f2';

/// Transações no período com filtros aplicados.
///
/// Copied from [reportTransactions].
@ProviderFor(reportTransactions)
final reportTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
  reportTransactions,
  name: r'reportTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportTransactionsRef = AutoDisposeStreamProviderRef<List<Transaction>>;
String _$reportSummaryHash() => r'cf78cc5dc0099042866336f6c3d9fd817e3877d2';

/// Resumo consolidado do período.
///
/// Copied from [reportSummary].
@ProviderFor(reportSummary)
final reportSummaryProvider = AutoDisposeFutureProvider<ReportSummary>.internal(
  reportSummary,
  name: r'reportSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportSummaryRef = AutoDisposeFutureProviderRef<ReportSummary>;
String _$reportByCategoryHash() => r'2c46e5e68730797c25e7b499fbbd918e9a27be41';

/// Despesas agrupadas por categoria com percentual.
///
/// Copied from [reportByCategory].
@ProviderFor(reportByCategory)
final reportByCategoryProvider =
    AutoDisposeFutureProvider<List<CategoryExpense>>.internal(
  reportByCategory,
  name: r'reportByCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportByCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportByCategoryRef
    = AutoDisposeFutureProviderRef<List<CategoryExpense>>;
String _$reportEvolutionHash() => r'5723ff70cd6f23acb776cd0b129a818f6841813a';

/// Evolução mensal no período selecionado (mês a mês).
///
/// Copied from [reportEvolution].
@ProviderFor(reportEvolution)
final reportEvolutionProvider =
    AutoDisposeFutureProvider<List<MonthlyEvolution>>.internal(
  reportEvolution,
  name: r'reportEvolutionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportEvolutionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportEvolutionRef
    = AutoDisposeFutureProviderRef<List<MonthlyEvolution>>;
String _$reportFilterHash() => r'0990e00db765750b1418bb63c59738aad8525a07';

/// See also [ReportFilter].
@ProviderFor(ReportFilter)
final reportFilterProvider =
    AutoDisposeNotifierProvider<ReportFilter, ReportFilterState>.internal(
  ReportFilter.new,
  name: r'reportFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$reportFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportFilter = AutoDisposeNotifier<ReportFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
