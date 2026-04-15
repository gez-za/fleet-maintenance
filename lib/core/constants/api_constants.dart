class ApiConstants {
  ApiConstants._();

  // API BASE
  static const String baseUrl = 'http://192.168.1.118:5000/api/v1';

  // TIMEOUTS
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // STORAGE KEYS
  static const String userDataKey = 'fleetManagement_user_data';
  static const String isLoggedInKey = 'fleetManagement_is_logged_in';

  // APP INFO
  static const String appName = 'fleet management IUC';
  static const String appVersion = '1.0.0';
}