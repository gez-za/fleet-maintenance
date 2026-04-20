import 'package:flutter/material.dart';

/// Palette de couleurs officielle fleet_maintenance
/// Thème : Vert (principal) · Rouge (erreur/alerte) · Gris (neutre)
abstract class AppColors {
  // ── Vert principal (AutoPark) ───────────────────────────
  static const Color primary         = Color(0xFF1A6B3A); // Vert foncé
  static const Color primaryMid      = Color(0xFF2D8653); // Vert moyen
  static const Color primaryLight    = Color(0xFF4CAF72); // Vert clair
  static const Color primarySurface  = Color(0xFFE8F5EE); // Vert très pâle (fond)
  static const Color primaryAccent   = Color(0xFF4CAF50); // Vert vif

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

  // ── Ambre (avertissement) — Utilisé avec parcimonie ──
  static const Color warning        = Color(0xFFF39C12);
  static const Color warningLight   = Color(0xFFFFF8E1);

  // ── Gris (neutres) ────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1C2833);
  static const Color textSecondary  = Color(0xFF5D6D7E);
  static const Color textHint       = Color(0xFF95A5A6);
  static const Color border         = Color(0xFFDEE2E6);
  static const Color divider        = Color(0xFFECF0F1);

  // ── Blanc / Noir ──────────────────────────────────────
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF000000);

  // ── Sidebar ───────────────────────────────────────────────
  static const Color sidebarBg     = Color(0xFF1C2833); // Gris foncé (textPrimary)
  static const Color sidebarActive = Color(0xFF1A6B3A); // Vert sélectionné
  static const Color sidebarText   = Color(0xFF95A5A6); // Texte inactif
  static const Color sidebarTextActive = Color(0xFFFFFFFF);

  // ── Fond & Surfaces ────────────────────────────────────────
  static const background    = Color(0xFFF4F6F9); 
  static const surface       = Color(0xFFFFFFFF); 
  static const surfaceHover  = Color(0xFFF0F4F8);

  // ── Statuts véhicules ─────────────────────────────────────
  static const available     = Color(0xFF1A6B3A); // Vert
  static const unavailable   = Color(0xFFC0392B); // Rouge
  static const inRepair      = Color(0xFF5D6D7E); // Gris
  static const inMission     = Color(0xFF2D8653); // Vert moyen

  // ── Graphiques ────────────────────────────────────────────
  static const chartGreen    = Color(0xFF1A6B3A);
  static const chartRed      = Color(0xFFC0392B);
  static const chartGrey     = Color(0xFF5D6D7E);
  static const chartLightGreen = Color(0xFF4CAF72);

  static BoxShadow get cardShadow => BoxShadow(
    color:       Colors.black.withOpacity(0.06),
    blurRadius:  12,
    offset:      const Offset(0, 4),
  );
}
