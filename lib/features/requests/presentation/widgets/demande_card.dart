import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/demande_enums.dart';
import '../../models/demande.dart';

class DemandeCard extends StatelessWidget {
  final Demande demande;
  final VoidCallback onTap;

  const DemandeCard({
    super.key,
    required this.demande,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  _buildTypeChip(),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                demande.motif,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    demande.vehicle?.immatriculation ?? 'VÉHICULE NON SPÉCIFIÉ',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(demande.createdAt),
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.priority_high, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Priorité: ${demande.priority.label}',
                    style: TextStyle(
                      fontSize: 12, 
                      color: demande.priority.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Demandé par: ${demande.requester?.displayName ?? 'Inconnu'}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(demande.type.icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            demande.type.label,
            style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: demande.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        demande.status.label.toUpperCase(),
        style: TextStyle(color: demande.status.color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
