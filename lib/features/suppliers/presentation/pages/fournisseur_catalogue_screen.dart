import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/supplier.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/catalogue_item.dart';
import 'package:fleet_maintenance_app/features/suppliers/presentation/providers/supplier_providers.dart';

class FournisseurCatalogueScreen extends ConsumerWidget {
  final Supplier supplier;

  const FournisseurCatalogueScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogueAsync = ref.watch(supplierCatalogueProvider(supplier.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Catalogue • ${supplier.nom}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: catalogueAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucun article dans le catalogue'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildCatalogueCard(items[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, ref),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCatalogueCard(CatalogueItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.designation,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2939)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Livraison: ${item.delaiLivraison}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          Text(
            '${item.prixHT} FCFA',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final designationController = TextEditingController();
    final prixController = TextEditingController();
    final delaiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter au catalogue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: designationController, decoration: const InputDecoration(labelText: 'Désignation')),
            TextField(controller: prixController, decoration: const InputDecoration(labelText: 'Prix HT'), keyboardType: TextInputType.number),
            TextField(controller: delaiController, decoration: const InputDecoration(labelText: 'Délai livraison (ex: 3 jours)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final item = CatalogueItem(
                id: '',
                fournisseurId: supplier.id,
                designation: designationController.text,
                prixHT: double.tryParse(prixController.text) ?? 0,
                delaiLivraison: delaiController.text,
              );
              
              await ref.read(supplierServiceProvider).addToCatalogue(supplier.id, item);
              ref.invalidate(supplierCatalogueProvider(supplier.id));
              
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
