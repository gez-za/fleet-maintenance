/// ============================================================
/// AutoPark IUC - Service Firebase Auth (Flutter)
/// ============================================================
/// Encapsule toute interaction avec Firebase Authentication côté Flutter.
/// Ce service gère : login, logout, état de connexion, et récupération du token.
///
/// ⚠️ Ce service ne gère PAS les rôles.
///    Les rôles sont uniquement gérés par le backend Express.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ─── État de connexion ───────────────────────────────────────

  /// Stream de l'état de connexion (utilisé pour la navigation automatique).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Utilisateur Firebase actuellement connecté (null si déconnecté).
  User? get currentUser => _firebaseAuth.currentUser;

  /// Indique si un utilisateur est connecté.
  bool get isLoggedIn => currentUser != null;

  // ─── Token ───────────────────────────────────────────────────

  /// Récupère le Firebase ID Token de l'utilisateur connecté.
  /// Le token est automatiquement rafraîchi par Firebase si expiré.
  ///
  /// [forceRefresh] : force le rafraîchissement même si le token est valide.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      debugPrint('[FirebaseAuthService] Erreur getIdToken : $e');
      return null;
    }
  }

  // ─── Connexion ───────────────────────────────────────────────

  /// Connecte l'utilisateur avec email + password via Firebase Auth.
  /// Retourne le Firebase ID Token (à envoyer au backend Express).
  ///
  /// Throws : [FirebaseAuthException] si credentials invalides.
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Échec de la connexion Firebase.');
    }

    // Récupération du ID Token à envoyer au backend
    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Impossible de récupérer le token d\'authentification.');
    }

    return idToken;
  }

  // ─── Déconnexion ─────────────────────────────────────────────

  /// Déconnecte l'utilisateur de Firebase Auth.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    debugPrint('[FirebaseAuthService] Utilisateur déconnecté.');
  }

  // ─── Helpers ─────────────────────────────────────────────────

  /// Traduit les codes d'erreur Firebase en messages lisibles.
  static String mapFirebaseAuthError(FirebaseAuthException e) {
    const errorMessages = {
      'user-not-found': 'Aucun compte associé à cet email.',
      'wrong-password': 'Mot de passe incorrect.',
      'invalid-email': 'Adresse email invalide.',
      'user-disabled': 'Ce compte a été désactivé.',
      'too-many-requests': 'Trop de tentatives. Réessayez plus tard.',
      'network-request-failed': 'Erreur réseau. Vérifiez votre connexion.',
      'invalid-credential': 'Email ou mot de passe incorrect.',
    };
    return errorMessages[e.code] ?? 'Erreur d\'authentification : ${e.message}';
  }
}