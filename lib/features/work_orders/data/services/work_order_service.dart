import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../models/work_order.dart';

class WorkOrderService {
  final ApiService _api;

  WorkOrderService(this._api);

  Future<Map<String, dynamic>> getWorkOrders({int page = 1, int limit = 10, String? status}) async {
    final query = {
      'page': page,
      'limit': limit,
      if (status != null) 'statut': status,
    };
    final response = await _api.get(ApiEndpoints.ordresTravail, query: query);
    return response.data['data'];
  }

  Future<WorkOrder> getWorkOrderById(String id) async {
    final response = await _api.get('${ApiEndpoints.ordresTravail}/$id');
    return WorkOrder.fromJson(response.data['data']);
  }

  Future<WorkOrder> createWorkOrder({
    required String faultId,
    required String description,
    required String technicianId,
    DateTime? startDate,
  }) async {
    final response = await _api.post(ApiEndpoints.ordresTravail, data: {
      'panne_id': faultId,
      'description': description,
      'technicien_id': technicianId,
      'date_debut': startDate?.toIso8601String(),
    });
    return WorkOrder.fromJson(response.data['data']);
  }

  Future<WorkOrder> updateWorkOrderStatus(String id, String status) async {
    final response = await _api.put('${ApiEndpoints.ordresTravail}/$id/statut', data: {
      'statut': status,
    });
    return WorkOrder.fromJson(response.data['data']);
  }

  Future<WorkOrder> closeWorkOrder(String id, {DateTime? endDate, List<dynamic>? parts}) async {
    final response = await _api.put('${ApiEndpoints.ordresTravail}/$id/cloturer', data: {
      'date_fin': endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'pieces': parts,
    });
    return WorkOrder.fromJson(response.data['data']);
  }
}
