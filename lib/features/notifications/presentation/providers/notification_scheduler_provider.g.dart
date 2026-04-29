// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_scheduler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationSchedulerHash() =>
    r'0b0d3f112b9ba9e3b5393012ae68f997d49c9620';

/// Agendador reativo de notificações locais.
///
/// Observa [notificationPreferencesNotifierProvider] e reagenda ou cancela
/// os alertas de lembrete diário e relatório semanal sempre que as
/// preferências forem alteradas.
///
/// Deve ser assistido (watched) em um widget de vida longa — ex: [HomePage] —
/// para garantir que o agendamento ocorra ao abrir o app.
///
/// Copied from [notificationScheduler].
@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = FutureProvider<void>.internal(
  notificationScheduler,
  name: r'notificationSchedulerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSchedulerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationSchedulerRef = FutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
