import 'package:dio/dio.dart';
import 'package:fleet_maintenance_app/features/inventory/../../core/services/api_service.dart';
import 'package:fleet_maintenance_app/features/inventory/models/material.dart';
import 'package:fleet_maintenance_app/features/inventory/models/stock_movement.dart';

class InventoryService {
  final ApiService _apiService;

  InventoryService(this._apiService);

  Future<List<MaterialModel>> getMateriels({int page = 1, String? search, String? categorie}) async {
    final query = {
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
      if (categorie != null && categorie.isNotEmpty) 'categorie': categorie,
    };
    
    final response = await _apiService.get('api/v1/materiels', query: query);
    final List data = response.data['data'] ?? [];
    return data.map((e) => MaterialModel.fromJson(e)).toList();
  }

  Future<List<MaterialModel>> getStockAlerts() async {
    final response = await _apiService.get('api/v1/materiels/alerts');
    final List data = response.data['data'] ?? [];
    return data.map((e) => MaterialModel.fromJson(e)).toList();
  }

  Future<MaterialModel> createMateriel(MaterialModel material) async {
    final response = await _apiService.post('api/v1/materiels', data: material.toJson());
    return MaterialModel.fromJson(response.data['data']);
  }

  Future<StockMovement> createMovement(StockMovement movement) async {
    final response = await _apiService.post('api/v1/mouvements_stock', data: movement.toJson());
    return StockMovement.fromJson(response.data['data']);
  }

  Future<List<StockMovement>> getMovementHistory({int page = 1, String? materielId}) async {
    final query = {
      'page': page,
      if (materielId != null) 'materiel_id': materielId,
    };
    final response = await _apiService.get('api/v1/mouvements_stock', query: query);
    final List data = response.data['data'] ?? [];
    return data.map((e) => StockMovement.fromJson(e)).toList();
  }

  Future<MaterialModel> getMaterielDetails(String id) async {
    final response = await _apiService.get('api/v1/materiels/$id');
    return MaterialModel.fromJson(response.data['data']);
  }
}
