// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'8f84097cccd00af817397c1715c5f537399ba780';

/// Provider da instância do [FirebaseAuth].
///
/// Copied from [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = AutoDisposeProvider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = AutoDisposeProviderRef<FirebaseAuth>;
String _$firebaseFirestoreHash() => r'eca974fdc891fcd3f9586742678f47582b20adec';

/// Provider da instância do [FirebaseFirestore].
///
/// Copied from [firebaseFirestore].
@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider =
    AutoDisposeProvider<FirebaseFirestore>.internal(
  firebaseFirestore,
  name: r'firebaseFirestoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseFirestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseFirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$firebaseStorageHash() => r'47903c48019f7dfa1ba82fa0a905885442d69f6b';

/// Provider da instância do [FirebaseStorage].
///
/// Copied from [firebaseStorage].
@ProviderFor(firebaseStorage)
final firebaseStorageProvider = AutoDisposeProvider<FirebaseStorage>.internal(
  firebaseStorage,
  name: r'firebaseStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseStorageRef = AutoDisposeProviderRef<FirebaseStorage>;
String _$currentUserIdOrNullHash() =>
    r'3b614b155f4b3f9b2d698ffec5dce3323ea9a4d2';

/// Provider do ID do usuário autenticado.
/// Retorna null se não houver usuário autenticado.
/// Prefira este provider para evitar crashes fora do contexto autenticado.
///
/// Copied from [currentUserIdOrNull].
@ProviderFor(currentUserIdOrNull)
final currentUserIdOrNullProvider = AutoDisposeProvider<String?>.internal(
  currentUserIdOrNull,
  name: r'currentUserIdOrNullProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdOrNullHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserIdOrNullRef = AutoDisposeProviderRef<String?>;
String _$currentUserIdHash() => r'090337059124a6b78af29c7534fac5a4b8ca6a8e';

/// Provider do ID do usuário autenticado.
/// Lança [StateError] apenas se chamado fora de uma rota autenticada
/// (o GoRouter garante que rotas protegidas só são acessíveis com login).
///
/// Copied from [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<String>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserIdRef = AutoDisposeProviderRef<String>;
String _$currentUserRefHash() => r'7659dad586c690d708050e44eebcd59e7dc4955d';

/// Provider da referência Firestore do usuário atual.
///
/// Copied from [currentUserRef].
@ProviderFor(currentUserRef)
final currentUserRefProvider =
    AutoDisposeProvider<DocumentReference<Map<String, dynamic>>>.internal(
  currentUserRef,
  name: r'currentUserRefProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserRefHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRefRef
    = AutoDisposeProviderRef<DocumentReference<Map<String, dynamic>>>;
String _$userCollectionHash() => r'980f297aec76441a07d746035a29bd729f10af2a';

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

/// Provider da sub-coleção do usuário atual.
/// Uso: ref.watch(userCollectionProvider('transactions'))
///
/// Copied from [userCollection].
@ProviderFor(userCollection)
const userCollectionProvider = UserCollectionFamily();

/// Provider da sub-coleção do usuário atual.
/// Uso: ref.watch(userCollectionProvider('transactions'))
///
/// Copied from [userCollection].
class UserCollectionFamily
    extends Family<CollectionReference<Map<String, dynamic>>> {
  /// Provider da sub-coleção do usuário atual.
  /// Uso: ref.watch(userCollectionProvider('transactions'))
  ///
  /// Copied from [userCollection].
  const UserCollectionFamily();

  /// Provider da sub-coleção do usuário atual.
  /// Uso: ref.watch(userCollectionProvider('transactions'))
  ///
  /// Copied from [userCollection].
  UserCollectionProvider call(
    String collectionName,
  ) {
    return UserCollectionProvider(
      collectionName,
    );
  }

  @override
  UserCollectionProvider getProviderOverride(
    covariant UserCollectionProvider provider,
  ) {
    return call(
      provider.collectionName,
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
  String? get name => r'userCollectionProvider';
}

/// Provider da sub-coleção do usuário atual.
/// Uso: ref.watch(userCollectionProvider('transactions'))
///
/// Copied from [userCollection].
class UserCollectionProvider
    extends AutoDisposeProvider<CollectionReference<Map<String, dynamic>>> {
  /// Provider da sub-coleção do usuário atual.
  /// Uso: ref.watch(userCollectionProvider('transactions'))
  ///
  /// Copied from [userCollection].
  UserCollectionProvider(
    String collectionName,
  ) : this._internal(
          (ref) => userCollection(
            ref as UserCollectionRef,
            collectionName,
          ),
          from: userCollectionProvider,
          name: r'userCollectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userCollectionHash,
          dependencies: UserCollectionFamily._dependencies,
          allTransitiveDependencies:
              UserCollectionFamily._allTransitiveDependencies,
          collectionName: collectionName,
        );

  UserCollectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collectionName,
  }) : super.internal();

  final String collectionName;

  @override
  Override overrideWith(
    CollectionReference<Map<String, dynamic>> Function(
            UserCollectionRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserCollectionProvider._internal(
        (ref) => create(ref as UserCollectionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collectionName: collectionName,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<CollectionReference<Map<String, dynamic>>>
      createElement() {
    return _UserCollectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserCollectionProvider &&
        other.collectionName == collectionName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collectionName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserCollectionRef
    on AutoDisposeProviderRef<CollectionReference<Map<String, dynamic>>> {
  /// The parameter `collectionName` of this provider.
  String get collectionName;
}

class _UserCollectionProviderElement extends AutoDisposeProviderElement<
    CollectionReference<Map<String, dynamic>>> with UserCollectionRef {
  _UserCollectionProviderElement(super.provider);

  @override
  String get collectionName =>
      (origin as UserCollectionProvider).collectionName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
