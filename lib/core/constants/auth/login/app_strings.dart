/// Chaînes de caractères de l'application AutoPark
/// Centralisation pour faciliter la future internationalisation (i18n)
abstract class AppStrings {
  // ── Application ───────────────────────────────────────
  static const String appName       = 'AutoPark';
  static const String appTagline    = 'Gestion de Parc Automobile';
  static const String appSubtitle   = 'Optimisez la gestion de votre flotte';

  // ── Page de connexion ─────────────────────────────────
  static const String loginTitle       = 'Gestion de Parc\nAutomobile';
  static const String loginSubtitle    = 'Optimisez la gestion de votre flotte';
  static const String loginButton      = 'Se Connecter';
  static const String loginForgot      = 'Mot de passe oublié ?';
  static const String loginCreate      = 'Créer un compte';
  static const String loginOr          = 'Ou connectez-vous avec';
  static const String loginWelcome     = 'Bon retour !';
  static const String loginConnecting  = 'Connexion en cours...';

  // ── Champs ────────────────────────────────────────────
  static const String email            = 'Adresse Email';
  static const String emailHint        = 'Entrez votre email';
  static const String password         = 'Mot de passe';
  static const String passwordHint     = 'Entrez votre mot de passe';
  static const String passwordShow     = 'Afficher';
  static const String passwordHide     = 'Masquer';

  // ── Validation ────────────────────────────────────────
  static const String errorEmailEmpty     = 'L\'email est requis';
  static const String errorEmailInvalid   = 'Format d\'email invalide';
  static const String errorPasswordEmpty  = 'Le mot de passe est requis';
  static const String errorPasswordShort  = 'Minimum 6 caractères';
  static const String errorLoginFailed    = 'Email ou mot de passe incorrect';
  static const String errorNetwork        = 'Vérifiez votre connexion internet';

  // ── Réseaux sociaux ───────────────────────────────────
  static const String continueWithGoogle   = 'Google';
  static const String continueWithFacebook = 'Facebook';

  // ── Modules de navigation ─────────────────────────────
  static const String navDashboard   = 'Tableau de bord';
  static const String navVehicules   = 'Véhicules';
  static const String navPannes      = 'Pannes';
  static const String navAtelier     = 'Atelier';
  static const String navCarburant   = 'Depenses';
  static const String navCarte       = 'Carte';
}