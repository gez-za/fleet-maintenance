import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/maintenance_enums.dart';
import '../../models/fault.dart';
import 'status_badge.dart';

class FaultCard extends StatelessWidget {
  final Fault fault;
  final VoidCallback onTap;

  const FaultCard({
    super.key,
    required this.fault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail
              _buildImage(),
              const SizedBox(width: AppDimensions.space16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fault.vehicle?.immatriculation ?? 'VÉHICULE INCONNU',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppDimensions.fontMD,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: fault.status.label,
                          color: _getStatusColor(fault.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      fault.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppDimensions.fontSM,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(fault.createdAt),
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: AppDimensions.fontXS,
                          ),
                        ),
                        const Spacer(),
                        _buildCriticalityBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = ApiConstants.getFullImageUrl(fault.photo);
    
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textHint,
                size: 30,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            )
          : const Icon(
              Icons.directions_car_filled_outlined,
              color: AppColors.textHint,
              size: 30,
            ),
    );
  }

  Widget _buildCriticalityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fault.criticality.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        fault.criticality.label,
        style: TextStyle(
          color: fault.criticality.color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(PanneStatus status) {
    switch (status) {
      case PanneStatus.DECLAREE:      return Colors.blue;
      case PanneStatus.VALIDEE:       return Colors.indigo;
      case PanneStatus.EN_DIAGNOSTIC: return Colors.orange;
      case PanneStatus.EN_REPARATION: return Colors.purple;
      case PanneStatus.CLOTUREE:      return Colors.green;
      default:                        return Colors.grey;
    }
  }
}
