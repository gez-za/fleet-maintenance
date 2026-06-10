import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/widgets/material_card.dart';

class MaterielsScreen extends ConsumerStatefulWidget {
  const MaterielsScreen({super.key});

  @override
  ConsumerState<MaterielsScreen> createState() => _MaterielsScreenState();
}

class _MaterielsScreenState extends ConsumerState<MaterielsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materielsAsync = ref.watch(materielsProvider);
    // Note: authProvider.user is used to check roles, make sure it's correct.
    // In this project it seems UserRole is an enum.
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Stock & Matériels'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            onPressed: () => Navigator.pushNamed(context, '/inventory/alerts'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/inventory/history'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(materielsProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    onChanged: (v) => ref.read(materielsProvider.notifier).search(v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher référence, désignation...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF667085)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(materielsProvider.notifier).refresh();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            materielsAsync.when(
              data: (materiels) {
                if (materiels.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('Aucun matériel trouvé')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MaterialCard(
                        material: materiels[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/inventory/details',
                          arguments: materiels[index],
                        ),
                      ),
                      childCount: materiels.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Erreur: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/inventory/create'),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
