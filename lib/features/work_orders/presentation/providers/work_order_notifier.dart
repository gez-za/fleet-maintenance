import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/services/work_order_service.dart';
import '../../models/work_order.dart';

class WorkOrderState {
  final bool isLoading;
  final List<WorkOrder> workOrders;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final String? error;

  WorkOrderState({
    this.isLoading = false,
    this.workOrders = const [],
    this.totalItems = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.error,
  });

  WorkOrderState copyWith({
    bool? isLoading,
    List<WorkOrder>? workOrders,
    int? totalItems,
    int? currentPage,
    int? totalPages,
    String? error,
    bool clearError = false,
  }) {
    return WorkOrderState(
      isLoading: isLoading ?? this.isLoading,
      workOrders: workOrders ?? this.workOrders,
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final workOrderServiceProvider = Provider((ref) {
  final api = ref.watch(apiServiceProvider);
  return WorkOrderService(api);
});

final workOrderProvider = NotifierProvider<WorkOrderNotifier, WorkOrderState>(() {
  return WorkOrderNotifier();
});

class WorkOrderNotifier extends Notifier<WorkOrderState> {
  @override
  WorkOrderState build() => WorkOrderState();

  Future<void> fetchWorkOrders({int page = 1, String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(workOrderServiceProvider).getWorkOrders(page: page, status: status);
      final List<dynamic> itemsJson = data['items'] ?? [];
      final List<WorkOrder> items = itemsJson.map((j) => WorkOrder.fromJson(j)).toList();
      
      final pagination = data['pagination'];
      
      state = state.copyWith(
        isLoading: false,
        workOrders: page == 1 ? items : [...state.workOrders, ...items],
        totalItems: pagination?['total'] ?? items.length,
        currentPage: pagination?['page'] ?? page,
        totalPages: pagination?['totalPages'] ?? 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createWorkOrder({
    required String faultId,
    required String description,
    required String technicianId,
    DateTime? startDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(workOrderServiceProvider).createWorkOrder(
        faultId: faultId,
        description: description,
        technicianId: technicianId,
        startDate: startDate,
      );
      await fetchWorkOrders(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(workOrderServiceProvider).updateWorkOrderStatus(id, status);
      await fetchWorkOrders(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> closeWorkOrder(String id, {DateTime? endDate, List<dynamic>? parts}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(workOrderServiceProvider).closeWorkOrder(id, endDate: endDate, parts: parts);
      await fetchWorkOrders(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> refresh() async => fetchWorkOrders(page: 1);
}
