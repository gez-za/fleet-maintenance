import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/vehicle_notifier.dart';
import '../widgets/vehicle_card.dart';

class VehicleListPage extends ConsumerStatefulWidget {
  const VehicleListPage({super.key});

  @override
  ConsumerState<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends ConsumerState<VehicleListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les véhicules au démarrage
    Future.microtask(() => ref.read(vehicleProvider.notifier).fetchVehicles());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleProvider);
    final vehicles = vehicleState.filteredVehicles;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: () => ref.read(vehicleProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Barre de recherche
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => ref.read(vehicleProvider.notifier).setSearchQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher marque, modèle, immatriculation...',
                      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF667085)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(vehicleProvider.notifier).setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // État de chargement / erreur / liste
            if (vehicleState.isLoading && vehicles.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vehicleState.error != null && vehicles.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: ${vehicleState.error}'),
                      TextButton(
                        onPressed: () => ref.read(vehicleProvider.notifier).fetchVehicles(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              )
            else if (vehicles.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Aucun véhicule trouvé',
                    style: TextStyle(color: Color(0xFF667085)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => VehicleCard(
                      vehicle: vehicles[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/vehicles/detail',
                          arguments: vehicles[index].id,
                        );
                      },
                    ),
                    childCount: vehicles.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: (ref.watch(authProvider).user?.isAdmin ?? false)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/vehicles/add');
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
