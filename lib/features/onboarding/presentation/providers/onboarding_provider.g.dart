// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryRemoteDataSourceHash() =>
    r'cd61fc8bf64981876a7a530913530974cd5c8d92';

/// See also [categoryRemoteDataSource].
@ProviderFor(categoryRemoteDataSource)
final categoryRemoteDataSourceProvider =
    Provider<CategoryRemoteDataSource>.internal(
  categoryRemoteDataSource,
  name: r'categoryRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryRemoteDataSourceRef = ProviderRef<CategoryRemoteDataSource>;
String _$onboardingRemoteDataSourceHash() =>
    r'99c8d1d66239765659db387faef6935365cf4d90';

/// See also [onboardingRemoteDataSource].
@ProviderFor(onboardingRemoteDataSource)
final onboardingRemoteDataSourceProvider =
    Provider<OnboardingRemoteDataSource>.internal(
  onboardingRemoteDataSource,
  name: r'onboardingRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingRemoteDataSourceRef = ProviderRef<OnboardingRemoteDataSource>;
String _$onboardingRepositoryHash() =>
    r'cd6f3ab218b474e7749be8f4521eac4150745030';

/// See also [onboardingRepository].
@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = Provider<OnboardingRepository>.internal(
  onboardingRepository,
  name: r'onboardingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingRepositoryRef = ProviderRef<OnboardingRepository>;
String _$onboardingStatusHash() => r'4fd8323d3da5a2712ae3e505f251090a8c6f630e';

/// Carrega o status de onboarding do usuário atual.
/// Retorna null se não houver usuário autenticado.
///
/// Copied from [onboardingStatus].
@ProviderFor(onboardingStatus)
final onboardingStatusProvider = FutureProvider<OnboardingStatus?>.internal(
  onboardingStatus,
  name: r'onboardingStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingStatusRef = FutureProviderRef<OnboardingStatus?>;
String _$onboardingNotifierHash() =>
    r'064a377736c654e146a98457f74f8faa1eae8fda';

/// Estado do onboarding durante as ações (loading, error, data).
///
/// Copied from [OnboardingNotifier].
@ProviderFor(OnboardingNotifier)
final onboardingNotifierProvider =
    AutoDisposeNotifierProvider<OnboardingNotifier, AsyncValue<void>>.internal(
  OnboardingNotifier.new,
  name: r'onboardingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
