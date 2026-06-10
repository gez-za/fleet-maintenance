import 'package:flutter/material.dart';
import 'package:fleet_maintenance_app/features/suppliers/models/supplier.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;

  const SupplierCard({super.key, required this.supplier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.business, color: Color(0xFF1565C0)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2939)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplier.contact,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD0D5DD)),
            ],
          ),
        ),
      ),
    );
  }
}
