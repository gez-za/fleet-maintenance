import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/vehicle.dart';

class VehicleService {
  final ApiService _api;

  VehicleService(this._api);

  // ── Lecture liste ──────────────────────────────────────────────────────────

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _api.get(ApiEndpoints.vehicules);
      final dynamic responseData = response.data['data'];

      List<dynamic> items = [];
      if (responseData is List) {
        items = responseData;
      } else if (responseData is Map && responseData['items'] is List) {
        items = responseData['items'];
      }

      return items.map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ── Lecture unitaire ───────────────────────────────────────────────────────

  Future<Vehicle> getVehicleById(String id) async {
    try {
      final response = await _api.get('${ApiEndpoints.vehicules}/$id');
      return Vehicle.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // ── Création ───────────────────────────────────────────────────────────────

  Future<Vehicle> createVehicle(
      Map<String, dynamic> data, {
        List<int>? imageBytes,
        String? imageName,
      }) async {
    try {
      final payload = _buildPayload(data, imageBytes: imageBytes, imageName: imageName);

      final response = await _api.post(
        ApiEndpoints.vehicules,
        data: payload,
      );

      return Vehicle.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // ── Mise à jour (PUT) ──────────────────────────────────────────────────────

  Future<Vehicle> updateVehicle(
      String id,
      Map<String, dynamic> data, {
        List<int>? imageBytes,
        String? imageName,
      }) async {
    try {
      final payload = _buildPayload(data, imageBytes: imageBytes, imageName: imageName);

      final response = await _api.put(
        '${ApiEndpoints.vehicules}/$id',
        data: payload,
      );

      return Vehicle.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // ── Suppression ────────────────────────────────────────────────────────────

  Future<void> deleteVehicle(String id) async {
    try {
      await _api.delete('${ApiEndpoints.vehicules}/$id');
    } catch (e) {
      rethrow;
    }
  }

  // ── Helper : construction du payload (JSON ou multipart) ──────────────────

  dynamic _buildPayload(
      Map<String, dynamic> data, {
        List<int>? imageBytes,
        String? imageName,
      }) {
    if (imageBytes != null && imageName != null) {
      final ext = imageName.split('.').last.toLowerCase();
      final subtype = ext == 'png' ? 'png' : 'jpeg';

      return FormData.fromMap({
        ...data,
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: imageName,
          contentType: MediaType('image', subtype),
        ),
      });
    }
    return data;
  }
}