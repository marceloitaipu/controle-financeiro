// lib/shared/providers/firebase_providers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Provider da instância do [FirebaseAuth].
@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Provider da instância do [FirebaseFirestore].
@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

/// Provider da instância do [FirebaseStorage].
@riverpod
FirebaseStorage firebaseStorage(Ref ref) => FirebaseStorage.instance;

/// Provider do ID do usuário autenticado.
/// Retorna null se não houver usuário autenticado.
/// Prefira este provider para evitar crashes fora do contexto autenticado.
@riverpod
String? currentUserIdOrNull(Ref ref) {
  return FirebaseAuth.instance.currentUser?.uid;
}

/// Provider do ID do usuário autenticado.
/// Lança [StateError] apenas se chamado fora de uma rota autenticada
/// (o GoRouter garante que rotas protegidas só são acessíveis com login).
@riverpod
String currentUserId(Ref ref) {
  final uid = ref.watch(currentUserIdOrNullProvider);
  if (uid == null) throw StateError('Nenhum usuário autenticado.');
  return uid;
}

/// Provider da referência Firestore do usuário atual.
@riverpod
DocumentReference<Map<String, dynamic>> currentUserRef(Ref ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(firebaseFirestoreProvider).collection('users').doc(userId);
}

/// Provider da sub-coleção do usuário atual.
/// Uso: ref.watch(userCollectionProvider('transactions'))
@riverpod
CollectionReference<Map<String, dynamic>> userCollection(
  Ref ref,
  String collectionName,
) {
  return ref.watch(currentUserRefProvider).collection(collectionName);
}
