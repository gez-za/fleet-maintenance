import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/vehicle.dart';
import 'vehicle_status_badge.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Construction sécurisée de l'URL
    final String? imageUrl =
    ApiConstants.getFullImageUrl(vehicle.image);

    // 🔍 DEBUG (tu peux supprimer après test)
    // print("IMAGE RAW: ${vehicle.image}");
    // print("IMAGE FULL: $imageUrl");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // ================= IMAGE =================
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,

                      // ✅ Loader pendant chargement
                      loadingBuilder:
                          (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },

                      // ❌ Si erreur → icône fallback
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.directions_car_filled,
                          color: Color(0xFF98A2B3),
                          size: 32,
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons.directions_car_filled,
                    color: Color(0xFF98A2B3),
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                // ================= INFOS =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.marque} ${vehicle.modele}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2939),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.immatriculation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF667085),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      VehicleStatusBadge(status: vehicle.statut),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFF98A2B3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}