// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationPreferencesNotifierHash() =>
    r'835d398d1514ed9e49caee6ea4631a9db5718330';

/// Gerenciador das preferências de notificação do usuário.
///
/// Persiste cada preferência em [SharedPreferences] de forma imediata.
/// O agendamento/cancelamento dos alertas é delegado ao
/// [notificationSchedulerProvider], que reage automaticamente às mudanças
/// de estado deste notifier.
///
/// Copied from [NotificationPreferencesNotifier].
@ProviderFor(NotificationPreferencesNotifier)
final notificationPreferencesNotifierProvider = NotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>.internal(
  NotificationPreferencesNotifier.new,
  name: r'notificationPreferencesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationPreferencesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationPreferencesNotifier = Notifier<NotificationPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
