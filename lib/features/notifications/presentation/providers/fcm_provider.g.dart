// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fcmTokenHash() => r'48a17b5ad6b81b3ef012770bad5511cf2754dba4';

/// Provider que gerencia o token FCM e as permissões de notificações push.
///
/// Solicita permissão ao usuário, obtém o token do dispositivo e persiste
/// no Firestore para que o backend possa enviar notificações direcionadas
/// mesmo após reinstalação ou troca de dispositivo.
///
/// keepAlive: true — mantém o estado durante toda a sessão autenticada.
///
/// Copied from [fcmToken].
@ProviderFor(fcmToken)
final fcmTokenProvider = FutureProvider<String?>.internal(
  fcmToken,
  name: r'fcmTokenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fcmTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenRef = FutureProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
