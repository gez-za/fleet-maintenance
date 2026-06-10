import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Vérifie les permissions et récupère la position actuelle
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test si les services de localisation sont activés.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Les permissions de localisation sont définitivement refusées, nous ne pouvons pas demander de permissions.');
    }

    // Lorsque nous arrivons ici, les permissions sont accordées et nous pouvons
    // continuer à accéder à la position de l'appareil.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Récupère une adresse lisible à partir de coordonnées GPS
  static Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.postalCode} ${place.locality}, ${place.country}";
      }
      return "Adresse inconnue";
    } catch (e) {
      return "Erreur lors de la récupération de l'adresse";
    }
  }
}
