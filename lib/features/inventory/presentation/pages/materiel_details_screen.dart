import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fleet_maintenance_app/features/inventory/models/material.dart';
import 'package:fleet_maintenance_app/features/inventory/models/stock_movement.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/providers/inventory_providers.dart';

class MaterielDetailsScreen extends ConsumerWidget {
  final MaterialModel material;

  const MaterielDetailsScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(material.designation),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historique récent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2939)),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/inventory/history', arguments: material.id),
                  child: const Text('Tout voir'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecentMovements(ref),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/inventory/move', arguments: material),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Effectuer un mouvement'),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.tag, 'Référence', material.reference),
          const Divider(height: 24),
          _buildDetailRow(Icons.category_outlined, 'Catégorie', material.categorie),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.inventory_2_outlined, 
            'Stock actuel', 
            '${material.quantiteStock}',
            valueColor: material.isLowStock ? Colors.red : const Color(0xFF1565C0),
          ),
          const Divider(height: 24),
          _buildDetailRow(Icons.notifications_active_outlined, 'Seuil d\'alerte', '${material.seuilAlerte}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF667085)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1D2939),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMovements(WidgetRef ref) {
    final movementsAsync = ref.watch(movementsHistoryProvider);

    return movementsAsync.when(
      data: (movements) {
        final filteredMovements = movements.where((m) => m.materielId == material.id).take(5).toList();
        if (filteredMovements.isEmpty) {
          return const Center(child: Text('Aucun mouvement récent', style: TextStyle(color: Color(0xFF667085))));
        }
        return Column(
          children: filteredMovements.map((m) => _buildMovementTile(m)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Erreur: $err'),
    );
  }

  Widget _buildMovementTile(StockMovement movement) {
    final bool isEntry = movement.type == MovementType.ENTREE;
    final color = isEntry ? Colors.green : (movement.type == MovementType.SORTIE ? Colors.orange : Colors.blue);
    final icon = isEntry ? Icons.add_circle_outline : (movement.type == MovementType.SORTIE ? Icons.remove_circle_outline : Icons.swap_horiz);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movement.motif, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  'Par ${movement.userName ?? 'Inconnu'} • ${DateFormat('dd/MM/yyyy HH:mm').format(movement.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          Text(
            '${isEntry ? '+' : '-'}${movement.quantite}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
