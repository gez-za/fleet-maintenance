import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/maintenance_enums.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/work_order.dart';
import '../providers/work_order_notifier.dart';
import '../../../faults/presentation/widgets/status_badge.dart';

class WorkOrderDetailPage extends ConsumerWidget {
  final String woId;

  const WorkOrderDetailPage({super.key, required this.woId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final woState = ref.watch(workOrderProvider);
    final user = ref.watch(authProvider).user;
    
    final wo = woState.workOrders.firstWhere(
      (w) => w.id == woId,
      orElse: () => throw Exception('OT non trouvé'),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail de l\'OT'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(wo),
            const SizedBox(height: 20),
            _buildFaultInfo(context, wo),
            const SizedBox(height: 20),
            _buildDescription(wo),
            const SizedBox(height: 20),
            _buildDates(wo),
            const SizedBox(height: 40),
            _buildActionButtons(context, ref, wo, user),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(WorkOrder wo) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OT #${wo.id.length > 8 ? wo.id.substring(0, 8).toUpperCase() : wo.id.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
              StatusBadge(label: wo.status.label, color: wo.status.color),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.engineering, 'Technicien', wo.technician?.displayName ?? 'Inconnu'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.directions_car, 'Véhicule', wo.fault?.vehicle?.immatriculation ?? 'Inconnu'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textHint),
        const SizedBox(width: 12),
        Text('$label : ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildFaultInfo(BuildContext context, WorkOrder wo) {
    if (wo.fault == null) return const SizedBox();
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/faults/detail', arguments: wo.faultId),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PANNE ASSOCIÉE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text(wo.fault!.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(WorkOrder wo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DESCRIPTION DES TRAVAUX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(wo.description, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildDates(WorkOrder wo) {
    return Row(
      children: [
        Expanded(
          child: _buildDateItem('Début prévu', wo.startDate ?? wo.createdAt),
        ),
        if (wo.endDate != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateItem('Terminé le', wo.endDate!),
          ),
        ],
      ],
    );
  }

  Widget _buildDateItem(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
          const SizedBox(height: 4),
          Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, WorkOrder wo, User? user) {
    if (user == null) return const SizedBox();
    
    // Uniquement le technicien assigné ou le chef d'atelier peut modifier le statut
    final bool canEdit = user.uuid == wo.technicianId || user.role == UserRole.CHEF_ATELIER || user.role == UserRole.ADMIN;
    if (!canEdit) return const SizedBox();

    if (wo.status == WorkOrderStatus.CREE) {
      return _buildActionBtn(
        'DÉMARRER LES TRAVAUX',
        Icons.play_arrow,
        AppColors.primary,
        () => _updateStatus(ref, wo, WorkOrderStatus.EN_COURS),
      );
    }

    if (wo.status == WorkOrderStatus.EN_COURS) {
      return _buildActionBtn(
        'TERMINER L\'INTERVENTION',
        Icons.check_circle,
        Colors.green,
        () => _showCloseDialog(context, ref, wo),
      );
    }

    return const SizedBox();
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _updateStatus(WidgetRef ref, WorkOrder wo, WorkOrderStatus status) async {
    await ref.read(workOrderProvider.notifier).updateStatus(wo.id, status.name);
  }

  void _showCloseDialog(BuildContext context, WidgetRef ref, WorkOrder wo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clôturer l\'OT'),
        content: const Text('Souhaitez-vous marquer cette intervention comme terminée ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(workOrderProvider.notifier).closeWorkOrder(wo.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('TERMINER'),
          ),
        ],
      ),
    );
  }
}
