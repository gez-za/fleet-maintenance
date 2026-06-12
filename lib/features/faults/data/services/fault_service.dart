import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../models/fault.dart';

class FaultService {
  final ApiService _api;

  FaultService(this._api);

  Future<dynamic> getFaults({int page = 1, int limit = 10, String? status, String? vehicleId}) async {
    final query = {
      'page': page,
      'limit': limit,
      if (status != null) 'statut': status,
      if (vehicleId != null) 'vehicule_id': vehicleId,
    };
    final response = await _api.get(ApiEndpoints.pannes, query: query);
    return response.data['data'];
  }

  Future<Fault> getFaultById(String id) async {
    final response = await _api.get('${ApiEndpoints.pannes}/$id');
    final dynamic data = response.data['data'];
    final dynamic faultData = data['panne'] ?? data;
    return Fault.fromJson(faultData);
  }

  Future<Fault> createFault({
    required String vehicleId,
    required String description,
    required String criticality,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? addressApprox,
  }) async {
    final Map<String, dynamic> data = {
      'vehicule_id': vehicleId,
      'description': description,
      'criticite': criticality,
      if (latitude != null) 'gps_latitude': latitude,
      if (longitude != null) 'gps_longitude': longitude,
      if (addressApprox != null) 'adresse_approx': addressApprox,
    };

    if (photoPath != null) {
      data['photo'] = await MultipartFile.fromFile(
        photoPath, 
        filename: 'panne_${DateTime.now().millisecondsSinceEpoch}.jpg'
      );
    }

    final formData = FormData.fromMap(data);

    final response = await _api.post(ApiEndpoints.pannes, data: formData);
    return Fault.fromJson(response.data['data']);
  }

  Future<Fault> addDiagnostic(String id, {required String diagnostic, required String status}) async {
    final response = await _api.patch('${ApiEndpoints.pannes}/$id/diagnostic', data: {
      'diagnostic': diagnostic,
      'statut': status,
    });
    return Fault.fromJson(response.data['data']);
  }

  Future<Fault> updateStatus(String id, String status) async {
    final response = await _api.put('${ApiEndpoints.pannes}/$id/status', data: {
      'statut': status,
    });
    return Fault.fromJson(response.data['data']);
  }
}
