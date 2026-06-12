import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/catalogue_item.dart';
import '../models/supplier.dart';

class SupplierService {
  final ApiService _apiService;

  SupplierService(this._apiService);

  Future<List<Supplier>> getFournisseurs() async {
    final response = await _apiService.get(ApiEndpoints.fournisseurs);
    final List data = response.data['data'] ?? [];
    return data.map((e) => Supplier.fromJson(e)).toList();
  }

  Future<List<CatalogueItem>> getCatalogue(String supplierId) async {
    final response = await _apiService.get('${ApiEndpoints.fournisseurs}/$supplierId/catalogue');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CatalogueItem.fromJson(e)).toList();
  }

  Future<CatalogueItem> addToCatalogue(String supplierId, CatalogueItem item) async {
    final response = await _apiService.post('${ApiEndpoints.fournisseurs}/$supplierId/catalogue', data: item.toJson());
    return CatalogueItem.fromJson(response.data['data']);
  }
}
