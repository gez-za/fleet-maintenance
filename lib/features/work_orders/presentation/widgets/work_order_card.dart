import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/maintenance_enums.dart';
import '../../models/work_order.dart';
import '../../../faults/presentation/widgets/status_badge.dart';

class WorkOrderCard extends StatelessWidget {
  final WorkOrder workOrder;
  final VoidCallback onTap;

  const WorkOrderCard({super.key, required this.workOrder, required this.onTap});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'OT #${workOrder.id.length > 8 ? workOrder.id.substring(0, 8).toUpperCase() : workOrder.id.toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  StatusBadge(label: workOrder.status.label, color: workOrder.status.color),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                workOrder.fault?.vehicle?.immatriculation ?? 'VÉHICULE INCONNU',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                workOrder.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.engineering_outlined, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workOrder.technician?.displayName ?? 'Technicien non assigné',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(workOrder.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
