import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/perfil_comunitario.dart';

class AuthService {
  factory AuthService() => _instance;
  AuthService._();

  static final AuthService _instance = AuthService._();
  bool _isRegistering = false;

  bool get isAvailable => Firebase.apps.isNotEmpty;
  bool get isRegistering => _isRegistering;
  User? get currentUser =>
      isAvailable ? FirebaseAuth.instance.currentUser : null;
  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    _validate(normalizedName, normalizedEmail, password, requireName: true);

    _isRegistering = true;
    User? createdUser;
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      createdUser = credential.user;
      if (createdUser == null) {
        throw const AuthException('O Firebase não retornou a conta criada.');
      }
      await createdUser.updateDisplayName(normalizedName);

      final profile = CommunityProfile(
        email: normalizedEmail,
        displayName: normalizedName,
      );
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(createdUser.uid)
          .set({
        ...profile.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _saveTestPassword(createdUser.uid, password);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error.code));
    } on FirebaseException catch (error) {
      try {
        await createdUser?.delete();
      } catch (_) {
        // Mantém a mensagem original do Firestore.
      }
      throw AuthException(_firestoreMessage(error.code));
    } finally {
      await FirebaseAuth.instance.signOut();
      _isRegistering = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _validate('', normalizedEmail, password);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      if (credential.user != null) {
        await _saveTestPassword(credential.user!.uid, password);
      }
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error.code));
    }
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();

  Future<void> _saveTestPassword(String userId, String password) async {
    if (!kDebugMode) return;
    try {
      await FirebaseFirestore.instance.collection('profiles').doc(userId).update({
        'password': password,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      // A gravacao de teste nao deve impedir o cadastro nem o login.
      // Nao registrar credenciais na mensagem de diagnostico.
      debugPrint(
        'Senha de teste nao salva no Firestore (${error.code}). '
        'Verifique as regras e a existencia do perfil.',
      );
    }
  }

  static void _validate(
    String name,
    String email,
    String password, {
    bool requireName = false,
  }) {
    if (requireName && name.length < 2) {
      throw const AuthException('Informe um nome com pelo menos 2 caracteres.');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw const AuthException('Informe um e-mail válido.');
    }
    if (password.length < 6) {
      throw const AuthException('A senha deve ter pelo menos 6 caracteres.');
    }
  }

  static String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Já existe uma conta com este e-mail.';
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'network-request-failed':
        return 'Sem conexão com o Firebase. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      case 'operation-not-allowed':
        return 'Habilite o provedor E-mail/senha no Firebase Authentication.';
      default:
        return 'Não foi possível autenticar. Tente novamente.';
    }
  }

  static String _firestoreMessage(String code) {
    if (code == 'permission-denied') {
      return 'O Firestore recusou o cadastro. Publique as regras do projeto.';
    }
    if (code == 'not-found') {
      return 'Crie o banco Cloud Firestore no Console do Firebase.';
    }
    return 'A conta não pôde ser salva no banco de dados.';
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
