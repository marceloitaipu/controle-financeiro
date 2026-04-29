// lib/features/notifications/presentation/providers/fcm_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'fcm_provider.g.dart';

/// Provider que gerencia o token FCM e as permissões de notificações push.
///
/// Solicita permissão ao usuário, obtém o token do dispositivo e persiste
/// no Firestore para que o backend possa enviar notificações direcionadas
/// mesmo após reinstalação ou troca de dispositivo.
///
/// keepAlive: true — mantém o estado durante toda a sessão autenticada.
@Riverpod(keepAlive: true)
Future<String?> fcmToken(Ref ref) async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  final status = settings.authorizationStatus;
  if (status != AuthorizationStatus.authorized &&
      status != AuthorizationStatus.provisional) {
    AppLogger.warning('Permissão de push negada — status: $status');
    return null;
  }

  final token = await messaging.getToken();
  AppLogger.info('FCM token: $token');

  if (token != null) {
    await _saveTokenToFirestore(ref, token);
  }

  // Escuta atualizações de token (ex: após reinstalação ou troca de dispositivo)
  messaging.onTokenRefresh.listen((newToken) async {
    AppLogger.info('FCM token atualizado: $newToken');
    await _saveTokenToFirestore(ref, newToken);
  });

  return token;
}

/// Persiste o [token] FCM no documento do usuário no Firestore.
/// Falhas são logadas mas não propagadas — nunca bloqueiam o app.
Future<void> _saveTokenToFirestore(Ref ref, String token) async {
  try {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });

    AppLogger.info('FCM token salvo no Firestore para uid=${user.id}');
  } catch (e, st) {
    AppLogger.error('fcmToken._saveTokenToFirestore', e, st);
  }
}
