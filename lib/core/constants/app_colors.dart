import 'package:flutter/material.dart';

/// Palette de couleurs officielle fleet_maintenance
/// Thème : Vert (principal) · Rouge (erreur/alerte) · Gris (neutre)
abstract class AppColors {
  // ── Vert principal ─────────────────────────────────────
  static const Color primary         = Color(0xFF1A6B3A); // Vert foncé
  static const Color primaryMid      = Color(0xFF2D8653); // Vert moyen
  static const Color primaryLight    = Color(0xFF4CAF72); // Vert clair
  static const Color primarySurface  = Color(0xFFE8F5EE); // Vert très pâle (fond)

  // ── Dégradés ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6B3A), Color(0xFF2D8653)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A6B3A), Color(0xFF2D8653), Color(0xFF3DA06A)],
    stops: [0.0, 0.6, 1.0],
  );

  // ── Rouge (danger/erreur) ──────────────────────────────
  static const Color danger         = Color(0xFFC0392B);
  static const Color dangerLight    = Color(0xFFFFEBEE);

  // ── Ambre (avertissement) ─────────────────────────────
  static const Color warning        = Color(0xFFF39C12);
  static const Color warningLight   = Color(0xFFFFF8E1);

  // ── Gris (neutres) ────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1C2833);
  static const Color textSecondary  = Color(0xFF5D6D7E);
  static const Color textHint       = Color(0xFF95A5A6);
  static const Color border         = Color(0xFFDEE2E6);
  static const Color surface        = Color(0xFFF8F9FA);
  static const Color background     = Color(0xFFFFFFFF);
  static const Color divider        = Color(0xFFECF0F1);

  // ── Blanc / Noir ──────────────────────────────────────
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF000000);

  // ── Statuts véhicules ─────────────────────────────────
  static const Color statusAvailable = Color(0xFF27AE60); // Disponible
  static const Color statusMission   = Color(0xFF2980B9); // En mission
  static const Color statusPanne     = Color(0xFFE74C3C); // En panne
  static const Color statusAtelier   = Color(0xFF95A5A6); // En atelier
}