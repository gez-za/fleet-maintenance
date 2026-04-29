class ApiEndpoints {
  ApiEndpoints._();

  // AUTH
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String me = 'auth/me';

  // USERS & PROFILES
  static const String users = 'users';
  static const String profiles = 'profiles';

  // PARC AUTOMOBILE
  static const String vehicules = '/vehicles';

  static const String chauffeurs = 'chauffeurs';
  static const String techniciens = 'techniciens';

  // MAINTENANCE &workflow
  static const String pannes = 'pannes';
  static const String ordresTravail = 'ordres_travail';
  static const String demandesCarburant = 'demandes_carburant';
}