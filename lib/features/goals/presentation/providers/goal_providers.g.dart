// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goalRemoteDataSourceHash() =>
    r'1158c1e76096fa6541d765b14cc380f8da86d2b8';

/// See also [goalRemoteDataSource].
@ProviderFor(goalRemoteDataSource)
final goalRemoteDataSourceProvider = Provider<GoalRemoteDataSource>.internal(
  goalRemoteDataSource,
  name: r'goalRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoalRemoteDataSourceRef = ProviderRef<GoalRemoteDataSource>;
String _$goalRepositoryHash() => r'fcf7fde91fbaf20113f88a2fa8dd26e0de88ebd2';

/// See also [goalRepository].
@ProviderFor(goalRepository)
final goalRepositoryProvider = Provider<GoalRepository>.internal(
  goalRepository,
  name: r'goalRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoalRepositoryRef = ProviderRef<GoalRepository>;
String _$watchGoalsHash() => r'dae06d1b8b8acba69f01b04abddeec95a1edcc3b';

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

/// Stream de metas com filtro opcional por status.
///
/// Uso:
/// ```dart
/// ref.watch(watchGoalsProvider(null))                 // todas
/// ref.watch(watchGoalsProvider(GoalStatus.active))    // ativas
/// ```
///
/// Copied from [watchGoals].
@ProviderFor(watchGoals)
const watchGoalsProvider = WatchGoalsFamily();

/// Stream de metas com filtro opcional por status.
///
/// Uso:
/// ```dart
/// ref.watch(watchGoalsProvider(null))                 // todas
/// ref.watch(watchGoalsProvider(GoalStatus.active))    // ativas
/// ```
///
/// Copied from [watchGoals].
class WatchGoalsFamily extends Family<AsyncValue<List<Goal>>> {
  /// Stream de metas com filtro opcional por status.
  ///
  /// Uso:
  /// ```dart
  /// ref.watch(watchGoalsProvider(null))                 // todas
  /// ref.watch(watchGoalsProvider(GoalStatus.active))    // ativas
  /// ```
  ///
  /// Copied from [watchGoals].
  const WatchGoalsFamily();

  /// Stream de metas com filtro opcional por status.
  ///
  /// Uso:
  /// ```dart
  /// ref.watch(watchGoalsProvider(null))                 // todas
  /// ref.watch(watchGoalsProvider(GoalStatus.active))    // ativas
  /// ```
  ///
  /// Copied from [watchGoals].
  WatchGoalsProvider call(
    GoalStatus? status,
  ) {
    return WatchGoalsProvider(
      status,
    );
  }

  @override
  WatchGoalsProvider getProviderOverride(
    covariant WatchGoalsProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'watchGoalsProvider';
}

/// Stream de metas com filtro opcional por status.
///
/// Uso:
/// ```dart
/// ref.watch(watchGoalsProvider(null))                 // todas
/// ref.watch(watchGoalsProvider(GoalStatus.active))    // ativas
/// ```
///
/// Copied from [watchGoals].
class WatchGoalsProvider extends AutoDisposeStreamProvider<List<Goal>> {
  /// Stream de metas com filtro opcional por status.
  ///
  /// Uso:
  /// ```dart
  /// ref.watch(watchGoalsProvider(null))                 // todas
  /// ref.watch(watchGoalsProvider(GoalStatus.active))    // ativas
  /// ```
  ///
  /// Copied from [watchGoals].
  WatchGoalsProvider(
    GoalStatus? status,
  ) : this._internal(
          (ref) => watchGoals(
            ref as WatchGoalsRef,
            status,
          ),
          from: watchGoalsProvider,
          name: r'watchGoalsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchGoalsHash,
          dependencies: WatchGoalsFamily._dependencies,
          allTransitiveDependencies:
              WatchGoalsFamily._allTransitiveDependencies,
          status: status,
        );

  WatchGoalsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final GoalStatus? status;

  @override
  Override overrideWith(
    Stream<List<Goal>> Function(WatchGoalsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchGoalsProvider._internal(
        (ref) => create(ref as WatchGoalsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Goal>> createElement() {
    return _WatchGoalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchGoalsProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchGoalsRef on AutoDisposeStreamProviderRef<List<Goal>> {
  /// The parameter `status` of this provider.
  GoalStatus? get status;
}

class _WatchGoalsProviderElement
    extends AutoDisposeStreamProviderElement<List<Goal>> with WatchGoalsRef {
  _WatchGoalsProviderElement(super.provider);

  @override
  GoalStatus? get status => (origin as WatchGoalsProvider).status;
}

String _$goalNotifierHash() => r'53fd206621411f01ff9f926bbe848fbc684190c6';

/// Notifier responsável por criar, editar, remover e depositar nas metas.
///
/// Copied from [GoalNotifier].
@ProviderFor(GoalNotifier)
final goalNotifierProvider =
    AutoDisposeNotifierProvider<GoalNotifier, AsyncValue<void>>.internal(
  GoalNotifier.new,
  name: r'goalNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$goalNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoalNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
