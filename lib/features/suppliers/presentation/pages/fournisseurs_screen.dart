import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/suppliers/presentation/providers/supplier_providers.dart';
import 'package:fleet_maintenance_app/features/suppliers/presentation/widgets/supplier_card.dart';

class FournisseursScreen extends ConsumerWidget {
  const FournisseursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Fournisseurs'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(suppliersProvider.notifier).refresh(),
        child: suppliersAsync.when(
          data: (suppliers) {
            if (suppliers.isEmpty) {
              return const Center(child: Text('Aucun fournisseur trouvé'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suppliers.length,
              itemBuilder: (context, index) => SupplierCard(
                supplier: suppliers[index],
                onTap: () => Navigator.pushNamed(
                  context,
                  '/suppliers/details',
                  arguments: suppliers[index],
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
