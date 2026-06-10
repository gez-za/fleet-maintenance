import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/services/fault_service.dart';
import '../../models/fault.dart';

class FaultState {
  final bool isLoading;
  final List<Fault> faults;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final String? error;

  FaultState({
    this.isLoading = false,
    this.faults = const [],
    this.totalItems = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.error,
  });

  FaultState copyWith({
    bool? isLoading,
    List<Fault>? faults,
    int? totalItems,
    int? currentPage,
    int? totalPages,
    String? error,
    bool clearError = false,
  }) {
    return FaultState(
      isLoading: isLoading ?? this.isLoading,
      faults: faults ?? this.faults,
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final faultServiceProvider = Provider((ref) {
  final api = ref.watch(apiServiceProvider);
  return FaultService(api);
});

final faultProvider = NotifierProvider<FaultNotifier, FaultState>(() {
  return FaultNotifier();
});

class FaultNotifier extends Notifier<FaultState> {
  @override
  FaultState build() => FaultState();

  Future<void> fetchFaults({int page = 1, String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(faultServiceProvider).getFaults(page: page, status: status);
      final List<dynamic> itemsJson = data['items'] ?? [];
      final List<Fault> items = itemsJson.map((j) => Fault.fromJson(j)).toList();
      
      final pagination = data['pagination'];
      
      state = state.copyWith(
        isLoading: false,
        faults: page == 1 ? items : [...state.faults, ...items],
        totalItems: pagination?['total'] ?? items.length,
        currentPage: pagination?['page'] ?? page,
        totalPages: pagination?['totalPages'] ?? 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createFault({
    required String vehicleId,
    required String description,
    required String criticality,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? addressApprox,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(faultServiceProvider).createFault(
        vehicleId: vehicleId,
        description: description,
        criticality: criticality,
        photoPath: photoPath,
        latitude: latitude,
        longitude: longitude,
        addressApprox: addressApprox,
      );
      await fetchFaults(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> addDiagnostic(String id, {required String diagnostic, required String status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(faultServiceProvider).addDiagnostic(id, diagnostic: diagnostic, status: status);
      // On peut rafraîchir ou juste mettre à jour l'élément local
      await fetchFaults(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> refresh() async => fetchFaults(page: 1);
}
