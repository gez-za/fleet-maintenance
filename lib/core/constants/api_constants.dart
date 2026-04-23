/// ============================================================
/// AutoPark IUC - ApiConstants (URL corrigée pour Flutter Web)
/// ============================================================
///
/// PROBLÈME RÉSOLU :
/// Flutter Web s'exécute dans un navigateur. Une requête vers
/// 192.168.1.118 depuis localhost déclenche une politique CORS.
/// On utilise donc une URL adaptée à chaque plateforme/mode.

import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // ─── Base URL (adaptée à la plateforme) ───────────────────────
  static String get baseUrl {
    // ── Production : toujours HTTPS avec le vrai domaine ─────────
    // Décommente quand tu déploies :
    // if (kReleaseMode) return 'https://api.autopark-iuc.cm/api/v1';

    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api/v1/';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1/';
    }

    return 'http://192.168.1.118:5000/api/v1/';
  }

  static String get uploadUrl {
    return baseUrl.replaceAll('/api/v1/', '/');
  }

  static String? getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    
    // Si le path commence par /, on l'enlève pour éviter le double //
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${uploadUrl}$cleanPath';
  }

  // ─── Timeouts ─────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ─── Storage Keys ─────────────────────────────────────────────
  static const String userDataKey = 'fleetManagement_user_data';
  static const String isLoggedInKey = 'fleetManagement_is_logged_in';

  // ─── App Info ─────────────────────────────────────────────────
  static const String appName = 'Fleet Management IUC';
  static const String appVersion = '1.0.0';
}