// lib/firebase_options.dart
// IMPORTANTE: Este arquivo deve ser gerado pelo FlutterFire CLI.
// Execute: flutterfire configure
// Documentacao: https://firebase.flutter.dev/docs/cli
//
// Por enquanto, este e um arquivo PLACEHOLDER para que o projeto compile.
// Substitua pelo arquivo real gerado pelo flutterfire configure.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCVzlymb3EsLxlFryTVQTIybbCUWhCRiCI',
    appId: '1:637495919647:web:de02af5151c37ffa99412a',
    messagingSenderId: '637495919647',
    projectId: 'controle-fin-3936',
    authDomain: 'controle-fin-3936.firebaseapp.com',
    storageBucket: 'controle-fin-3936.firebasestorage.app',
    measurementId: 'G-PLACEHOLDER',
  );

  // SUBSTITUA ESTES VALORES pelos gerados pelo FlutterFire CLI

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5GhN5ihshwybgyG2zXXvQEwldf1Ofln0',
    appId: '1:637495919647:android:1b64e5cc059b1ea099412a',
    messagingSenderId: '637495919647',
    projectId: 'controle-fin-3936',
    storageBucket: 'controle-fin-3936.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJNUNN2XRFRbsZCf6KwXIS_dPtNDWc03s',
    appId: '1:637495919647:ios:d23ff30eef13233a99412a',
    messagingSenderId: '637495919647',
    projectId: 'controle-fin-3936',
    storageBucket: 'controle-fin-3936.firebasestorage.app',
    iosBundleId: 'com.marcelos.financeiro.controleFinanceiro',
  );

}