import 'package:fleet_maintenance_app/core/services/api_service.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/supplier.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/catalogue_item.dart';

class SupplierService {
  final ApiService _apiService;

  SupplierService(this._apiService);

  Future<List<Supplier>> getFournisseurs() async {
    final response = await _apiService.get('api/v1/fournisseurs');
    final List data = response.data['data'] ?? [];
    return data.map((e) => Supplier.fromJson(e)).toList();
  }

  Future<List<CatalogueItem>> getCatalogue(String supplierId) async {
    final response = await _apiService.get('api/v1/fournisseurs/$supplierId/catalogue');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CatalogueItem.fromJson(e)).toList();
  }

  Future<CatalogueItem> addToCatalogue(String supplierId, CatalogueItem item) async {
    final response = await _apiService.post('api/v1/fournisseurs/$supplierId/catalogue', data: item.toJson());
    return CatalogueItem.fromJson(response.data['data']);
  }
}
