import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/supplier.dart';
import 'package:fleet_maintenance_app/features/suppliers/presentation/providers/supplier_providers.dart';

class FournisseurDetailsScreen extends ConsumerWidget {
  final Supplier supplier;

  const FournisseurDetailsScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(supplier.nom),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/suppliers/catalogue', arguments: supplier),
                icon: const Icon(Icons.list_alt),
                label: const Text('Voir le catalogue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
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
          _buildDetailRow(Icons.person_outline, 'Contact Principal', supplier.contact),
          const Divider(height: 24),
          _buildDetailRow(Icons.phone_outlined, 'Téléphone', supplier.telephone ?? 'Non renseigné'),
          const Divider(height: 24),
          _buildDetailRow(Icons.email_outlined, 'Email', supplier.email ?? 'Non renseigné'),
          const Divider(height: 24),
          _buildDetailRow(Icons.location_on_outlined, 'Adresse', supplier.adresse ?? 'Non renseigné'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF667085)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1D2939),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
