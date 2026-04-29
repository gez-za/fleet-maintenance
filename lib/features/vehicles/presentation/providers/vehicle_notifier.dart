import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/vehicle_service.dart';
import '../../models/vehicle.dart';

class VehicleState {
  final bool isLoading;
  final List<Vehicle> vehicles;
  final String? error;
  final String searchQuery;

  VehicleState({
    this.isLoading = false,
    this.vehicles = const [],
    this.error,
    this.searchQuery = '',
  });

  List<Vehicle> get filteredVehicles {
    if (searchQuery.isEmpty) return vehicles;
    final query = searchQuery.toLowerCase();
    return vehicles.where((v) =>
    v.marque.toLowerCase().contains(query) ||
        v.modele.toLowerCase().contains(query) ||
        v.immatriculation.toLowerCase().contains(query)).toList();
  }

  VehicleState copyWith({
    bool? isLoading,
    List<Vehicle>? vehicles,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return VehicleState(
      isLoading: isLoading ?? this.isLoading,
      vehicles: vehicles ?? this.vehicles,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final vehicleServiceProvider = Provider((ref) {
  final api = ref.watch(apiServiceProvider);
  return VehicleService(api);
});

final vehicleProvider = NotifierProvider<VehicleNotifier, VehicleState>(() {
  return VehicleNotifier();
});

class VehicleNotifier extends Notifier<VehicleState> {
  @override
  VehicleState build() => VehicleState();

  // ── Lecture ────────────────────────────────────────────────────────────────

  Future<void> fetchVehicles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final vehicles = await ref.read(vehicleServiceProvider).getVehicles();
      state = state.copyWith(isLoading: false, vehicles: vehicles);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async => fetchVehicles();

  // ── Création ───────────────────────────────────────────────────────────────

  Future<bool> createVehicle(
      Map<String, dynamic> data, {
        List<int>? imageBytes,
        String? imageName,
      }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(vehicleServiceProvider).createVehicle(
        data,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      await fetchVehicles();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── Mise à jour ────────────────────────────────────────────────────────────

  Future<bool> updateVehicle(
      String id,
      Map<String, dynamic> data, {
        List<int>? imageBytes,
        String? imageName,
      }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(vehicleServiceProvider).updateVehicle(
        id,
        data,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      await fetchVehicles();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── Suppression ────────────────────────────────────────────────────────────

  Future<bool> deleteVehicle(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(vehicleServiceProvider).deleteVehicle(id);
      // Retire le véhicule localement sans refetch complet
      final updated = state.vehicles.where((v) => v.id != id).toList();
      state = state.copyWith(isLoading: false, vehicles: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}