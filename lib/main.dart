// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/observers/app_provider_observer.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/utils/app_logger.dart';
import 'features/notifications/data/services/local_notification_service.dart';
import 'firebase_options.dart';
import 'shared/providers/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ─────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.info('Firebase inicializado');

  // ── Crashlytics ───────────────────────────────────────────────────────────
  // Crashlytics não suporta web — ignorado nessa plataforma.
  if (!kIsWeb) {
    await CrashlyticsService.instance.initialize();
  }

  // ── UI do sistema ────────────────────────────────────────────────────────
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Preferências locais ──────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();

  // ── Notificações locais ──────────────────────────────────────────────────
  // flutter_local_notifications não suporta web — ignorado nessa plataforma.
  if (!kIsWeb) {
    await LocalNotificationService.instance.initialize();
  }

  // ── Analytics — registra abertura do app ─────────────────────────────────
  // O tracking de telas acontece automaticamente via FirebaseAnalyticsObserver
  // registrado no GoRouter (veja app_router.dart).
  if (!kDebugMode) {
    await AnalyticsService.instance.logScreenView(screenName: 'app_start');
  }

  // ── Inicialização do app ─────────────────────────────────────────────────
  runApp(
    ProviderScope(
      observers: kDebugMode ? const [AppProviderObserver()] : const [],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}

