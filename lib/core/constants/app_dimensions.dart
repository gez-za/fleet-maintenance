/// Système de dimensions et espacements AutoPark
/// Basé sur une grille de 8px
abstract class AppDimensions {
  // ── Espacements (grille 8px) ──────────────────────────
  static const double space2  = 2.0;
  static const double space4  = 4.0;
  static const double space8  = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;

  // ── Padding horizontal de page ────────────────────────
  static const double paddingHorizontal = 24.0;
  static const double paddingVertical   = 16.0;

  // ── Border radius ──────────────────────────────────────
  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge  = 16.0;
  static const double radiusXL     = 24.0;
  static const double radiusFull   = 100.0; // Pour les boutons pills

  // ── Hauteurs des composants ───────────────────────────
  static const double inputHeight       = 58.0;
  static const double buttonHeight      = 56.0;
  static const double socialButtonSize  = 56.0;
  static const double headerHeight      = 300.0;
  static const double iconSize          = 22.0;
  static const double iconSizeLarge     = 28.0;

  // ── Élévations (ombres) ───────────────────────────────
  static const double elevationNone   = 0.0;
  static const double elevationLow    = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh   = 8.0;

  // ── Typographie ───────────────────────────────────────
  static const double fontXS   = 11.0;
  static const double fontSM   = 13.0;
  static const double fontBase = 15.0;
  static const double fontMD   = 16.0;
  static const double fontLG   = 18.0;
  static const double fontXL   = 22.0;
  static const double fontXXL  = 26.0;
  static const double font3XL  = 30.0;
}