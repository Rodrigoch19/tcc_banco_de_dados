import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/perfil_comunitario.dart';

/// Centraliza o perfil salvo no Firestore.
///
/// O aplicativo não possui tela de login. Quando o Firebase está disponível,
/// uma sessão anônima é criada internamente apenas para que cada instalação
/// tenha seu próprio documento protegido pelas regras do Firestore.
class DatabaseService {
  factory DatabaseService() => _instance;

  DatabaseService._();

  static final DatabaseService _instance = DatabaseService._();

  bool get isAvailable => Firebase.apps.isNotEmpty;
  User? get currentUser =>
      isAvailable ? FirebaseAuth.instance.currentUser : null;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      FirebaseFirestore.instance.collection('profiles');

  Future<CommunityProfile> getOrCreateProfile({
    required String email,
    required String displayName,
  }) async {
    final fallback = CommunityProfile(
      email: email.trim().toLowerCase(),
      displayName: displayName.trim(),
    );

    if (!isAvailable) return fallback;

    final userId = _currentUserId();
    final reference = _profiles.doc(userId);

    try {
      return await FirebaseFirestore.instance
          .runTransaction<CommunityProfile>((transaction) async {
        final snapshot = await transaction.get(reference);
        final data = snapshot.data();
        if (snapshot.exists && data != null) {
          return CommunityProfile.fromMap(data);
        }

        transaction.set(reference, {
          ...fallback.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return fallback;
      });
    } on FirebaseException catch (error, stackTrace) {
      _log('Firestore', error.code, error.message, stackTrace);
      throw DatabaseException(_firestoreMessage(error.code), code: error.code);
    }
  }

  Future<void> saveProfile({required CommunityProfile profile}) async {
    if (!isAvailable) return;

    final userId = _currentUserId();
    try {
      await _profiles.doc(userId).set(
        {
          ...profile.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error, stackTrace) {
      _log('Firestore', error.code, error.message, stackTrace);
      throw DatabaseException(_firestoreMessage(error.code), code: error.code);
    }
  }

  String _currentUserId() {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw const DatabaseException(
        'Faça login para acessar seus dados.',
        code: 'unauthenticated',
      );
    }
    return currentUser.uid;
  }

  static String _firestoreMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'O Firestore recusou o acesso. Publique as regras do projeto.';
      case 'unauthenticated':
        return 'Não foi possível identificar esta instalação no Firebase.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'O banco está temporariamente indisponível.';
      case 'not-found':
        return 'Crie o banco Cloud Firestore (default) no Console do Firebase.';
      default:
        return 'Não foi possível acessar o banco de dados.';
    }
  }

  static void _log(
    String service,
    String code,
    String? message,
    StackTrace stackTrace,
  ) {
    debugPrint('Erro do $service ($code): ${message ?? 'sem detalhes'}');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class DatabaseException implements Exception {
  const DatabaseException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
