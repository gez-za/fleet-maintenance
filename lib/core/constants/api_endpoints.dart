class ApiEndpoints {
  ApiEndpoints._();

  // AUTH
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String me = 'auth/me';
  static const String checkEmail = 'auth/check-email';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';

  // USERS & PROFILES
  static const String users = 'users';
  static const String profiles = 'profiles';

  // PARC AUTOMOBILE
  static const String vehicules = 'vehicles';

  static const String chauffeurs = 'chauffeurs';
  static const String techniciens = 'techniciens';

  // MAINTENANCE &workflow
  static const String pannes = 'pannes';
  static const String ordresTravail = 'ordres_travail';
  static const String demandes = 'demandes';
  static const String depenses = 'depenses';

  // INVENTAIRE
  static const String materiels = 'materiels';
  static const String mouvementsStock = 'mouvements_stock';
  static const String fournisseurs = 'fournisseurs';
}