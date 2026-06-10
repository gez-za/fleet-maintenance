import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fleet_maintenance_app/features/inventory/models/stock_movement.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/providers/inventory_providers.dart';

class MouvementsHistoryScreen extends ConsumerWidget {
  final String? materielId;

  const MouvementsHistoryScreen({super.key, this.materielId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(movementsHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Historique des Mouvements'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(movementsHistoryProvider.notifier).refresh(),
        child: historyAsync.when(
          data: (movements) {
            final filtered = materielId != null 
              ? movements.where((m) => m.materielId == materielId).toList()
              : movements;

            if (filtered.isEmpty) {
              return const Center(child: Text('Aucun mouvement enregistré'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildMovementCard(filtered[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erreur: $err')),
        ),
      ),
    );
  }

  Widget _buildMovementCard(StockMovement movement) {
    final bool isEntry = movement.type == MovementType.ENTREE;
    final color = isEntry ? Colors.green : (movement.type == MovementType.SORTIE ? Colors.orange : Colors.blue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM yyyy • HH:mm').format(movement.createdAt),
                style: const TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w500),
              ),
              _buildTypeBadge(movement.type, color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            movement.materielDesignation ?? 'Matériel inconnu',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2939)),
          ),
          const SizedBox(height: 4),
          Text(
            movement.motif,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475467)),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Effectué par', style: TextStyle(fontSize: 11, color: Color(0xFF667085))),
                  Text(movement.userName ?? 'Utilisateur', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Text(
                '${isEntry ? '+' : '-'}${movement.quantite}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(MovementType type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.name,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
