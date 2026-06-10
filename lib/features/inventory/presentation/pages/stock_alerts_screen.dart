import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/widgets/material_card.dart';

class StockAlertsScreen extends ConsumerWidget {
  const StockAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(stockAlertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Alertes Stock Faible'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(stockAlertsProvider.notifier).refresh(),
        child: alertsAsync.when(
          data: (materiels) {
            if (materiels.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text('Aucune alerte de stock', style: TextStyle(fontSize: 16, color: Color(0xFF667085))),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: materiels.length,
              itemBuilder: (context, index) => MaterialCard(
                material: materiels[index],
                onTap: () => Navigator.pushNamed(
                  context,
                  '/inventory/details',
                  arguments: materiels[index],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erreur: $err')),
        ),
      ),
    );
  }
}
