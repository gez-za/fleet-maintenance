import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:fleet_maintenance_app/features/inventory/data/inventory_service.dart';
import 'package:fleet_maintenance_app/features/inventory/models/material.dart';
import 'package:fleet_maintenance_app/features/inventory/models/stock_movement.dart';

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return InventoryService(apiService);
});

final materielsProvider = AsyncNotifierProvider<MaterielsNotifier, List<MaterialModel>>(() {
  return MaterielsNotifier();
});

class MaterielsNotifier extends AsyncNotifier<List<MaterialModel>> {
  @override
  Future<List<MaterialModel>> build() async {
    return ref.read(inventoryServiceProvider).getMateriels();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(inventoryServiceProvider).getMateriels());
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(inventoryServiceProvider).getMateriels(search: query));
  }

  Future<void> createMaterial(MaterialModel material) async {
    await ref.read(inventoryServiceProvider).createMateriel(material);
    await refresh();
  }
}

final stockAlertsProvider = AsyncNotifierProvider<StockAlertsNotifier, List<MaterialModel>>(() {
  return StockAlertsNotifier();
});

class StockAlertsNotifier extends AsyncNotifier<List<MaterialModel>> {
  @override
  Future<List<MaterialModel>> build() async {
    return ref.read(inventoryServiceProvider).getStockAlerts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(inventoryServiceProvider).getStockAlerts());
  }
}

final movementsHistoryProvider = AsyncNotifierProvider<MovementsHistoryNotifier, List<StockMovement>>(() {
  return MovementsHistoryNotifier();
});

class MovementsHistoryNotifier extends AsyncNotifier<List<StockMovement>> {
  @override
  Future<List<StockMovement>> build() async {
    return ref.read(inventoryServiceProvider).getMovementHistory();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(inventoryServiceProvider).getMovementHistory());
  }

  Future<void> createMovement(StockMovement movement) async {
    await ref.read(inventoryServiceProvider).createMovement(movement);
    await refresh();
    // Also refresh materials because stock changed
    ref.read(materielsProvider.notifier).refresh();
    ref.read(stockAlertsProvider.notifier).refresh();
  }
}
