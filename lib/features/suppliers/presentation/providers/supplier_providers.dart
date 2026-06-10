import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:fleet_maintenance_app/features/suppliers/data/supplier_service.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/supplier.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/catalogue_item.dart';

final supplierServiceProvider = Provider<SupplierService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SupplierService(apiService);
});

final suppliersProvider = AsyncNotifierProvider<SuppliersNotifier, List<Supplier>>(() {
  return SuppliersNotifier();
});

class SuppliersNotifier extends AsyncNotifier<List<Supplier>> {
  @override
  Future<List<Supplier>> build() async {
    return ref.read(supplierServiceProvider).getFournisseurs();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(supplierServiceProvider).getFournisseurs());
  }
}

// Switching to FutureProvider for simplicity if class-based family is causing issues,
// but I'll try one more time with the correct Riverpod 2.x syntax if possible.
// Actually, I'll use a FutureProvider for the list and a separate Notifier for actions if needed.
// Or just use the simple functional family.

final supplierCatalogueProvider = FutureProvider.family<List<CatalogueItem>, String>((ref, id) async {
  return ref.watch(supplierServiceProvider).getCatalogue(id);
});
