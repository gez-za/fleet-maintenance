import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../models/demande.dart';

class DemandeService {
  final ApiService _api;

  DemandeService(this._api);

  Future<Map<String, dynamic>> getDemandes({
    int page = 1, 
    int limit = 10, 
    String? status,
    String? type,
    String? priority,
  }) async {
    final query = {
      'page': page,
      'limit': limit,
      if (status != null) 'statut': status,
      if (type != null) 'type': type,
      if (priority != null) 'priorite': priority,
    };
    final response = await _api.get(ApiEndpoints.demandes, query: query);
    return response.data['data'];
  }

  Future<Demande> getDemandeById(String id) async {
    final response = await _api.get('${ApiEndpoints.demandes}/$id');
    final dynamic data = response.data['data'];
    final dynamic demandeData = data['demande'] ?? data;
    return Demande.fromJson(demandeData);
  }

  Future<Demande> createDemande({
    required Demande demande,
    String? filePath,
  }) async {
    final Map<String, dynamic> data = demande.toJson();

    if (filePath != null) {
      data['justificatif'] = await MultipartFile.fromFile(
        filePath, 
        filename: 'demande_${DateTime.now().millisecondsSinceEpoch}.${filePath.split('.').last}'
      );
    }

    final formData = FormData.fromMap(data);
    final response = await _api.post(ApiEndpoints.demandes, data: formData);
    return Demande.fromJson(response.data['data']);
  }

  Future<Demande> processAction(String id, {
    required String status,
    String? rejectionReason,
    String? bonNumber,
    double? quantityGranted,
    DateTime? bonDate,
    DateTime? bonExpiryDate,
  }) async {
    final response = await _api.patch('${ApiEndpoints.demandes}/$id/validation', data: {
      'statut': status,
      'motif_rejet': rejectionReason,
      'numero_bon': bonNumber,
      'quantite_accordee': quantityGranted,
      'date_emission_bon': bonDate?.toIso8601String(),
      'date_validite_bon': bonExpiryDate?.toIso8601String(),
    });
    return Demande.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getDepenses({int page = 1, int limit = 10}) async {
    final query = {'page': page, 'limit': limit};
    final response = await _api.get(ApiEndpoints.depenses, query: query);
    return response.data['data'];
  }

  Future<Depense> createDepense({
    required String label,
    required double amount,
    String? vehicleId,
    String? demandeId,
    String? filePath,
  }) async {
    final Map<String, dynamic> data = {
      'libelle': label,
      'montant': amount,
      if (vehicleId != null) 'vehicule_id': vehicleId,
      if (demandeId != null) 'demande_id': demandeId,
    };

    if (filePath != null) {
      data['justificatif'] = await MultipartFile.fromFile(
        filePath,
        filename: 'depense_${DateTime.now().millisecondsSinceEpoch}.${filePath.split('.').last}'
      );
    }

    final formData = FormData.fromMap(data);
    final response = await _api.post(ApiEndpoints.depenses, data: formData);
    return Depense.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _api.get('${ApiEndpoints.depenses}/stats');
    return response.data['data'];
  }
}
