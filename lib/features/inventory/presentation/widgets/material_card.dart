import 'package:flutter/material.dart';
import 'package:fleet_maintenance_app/features/inventory/models/material.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback onTap;

  const MaterialCard({
    super.key,
    required this.material,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = material.isLowStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowStock ? Colors.red.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.designation,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2939),
                          ),
                        ),
                        Text(
                          'Réf: ${material.reference}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCategoryBadge(material.categorie),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stock actuel',
                        style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                      ),
                      Text(
                        '${material.quantiteStock}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLowStock ? Colors.red : const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Seuil d\'alerte',
                        style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                      ),
                      Text(
                        '${material.seuilAlerte}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D2939),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isLowStock) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Stock critique',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
      ),
    );
  }
}
