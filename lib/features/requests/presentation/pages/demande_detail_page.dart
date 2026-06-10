import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/demande_enums.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/demande.dart';
import '../providers/demande_notifier.dart';

class DemandeDetailPage extends ConsumerWidget {
  final Demande demande;

  const DemandeDetailPage({super.key, required this.demande});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final canValidate = user?.role == UserRole.ADMIN || 
                        user?.role == UserRole.CHEF_ATELIER || 
                        user?.role == UserRole.DIRECTEUR;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la Demande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildDetailsCard(),
            const SizedBox(height: 24),
            if (demande.justificatif != null) _buildJustificatifCard(),
            const SizedBox(height: 40),
            if (canValidate && demande.status == DemandeStatus.EN_ATTENTE) _buildValidationActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: demande.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: demande.status.color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(demande.type.icon, size: 48, color: demande.status.color),
          const SizedBox(height: 8),
          Text(
            demande.status.label.toUpperCase(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: demande.status.color),
          ),
          if (demande.rejectionReason != null) ...[
            const Divider(),
            Text('Motif du rejet:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(demande.rejectionReason!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('INFORMATIONS GÉNÉRALES', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const Divider(),
            _buildInfoRow(Icons.info_outline, 'Motif', demande.motif),
            _buildInfoRow(Icons.directions_car, 'Véhicule', demande.vehicle?.immatriculation ?? 'Non spécifié'),
            _buildInfoRow(Icons.priority_high, 'Priorité', demande.priority.label, valueColor: demande.priority.color),
            _buildInfoRow(Icons.person_outline, 'Demandeur', demande.requester?.displayName ?? 'Inconnu'),
            _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('dd/MM/yyyy HH:mm').format(demande.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DÉTAILS SPÉCIFIQUES', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const Divider(),
            ...demande.details.entries.map((e) => _buildInfoRow(Icons.label_important_outline, _formatKey(e.key), e.value.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildJustificatifCard() {
    final imageUrl = ApiConstants.getFullImageUrl(demande.justificatif);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PIÈCE JOINTE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const Divider(),
            if (imageUrl != null) Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showValidationDialog(context, ref, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('APPROUVER'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showValidationDialog(context, ref, false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('REJETER'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textHint),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: valueColor))),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key.replaceAll('_', ' ').toUpperCase();
  }

  void _showValidationDialog(BuildContext context, WidgetRef ref, bool approve) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approuver la demande' : 'Rejeter la demande'),
        content: approve 
            ? const Text('Voulez-vous valider cette demande ?')
            : TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Motif du rejet')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(demandeProvider.notifier).validateDemande(
                demande.id, 
                isApproved: approve, 
                rejectionReason: approve ? null : reasonController.text
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('CONFIRMER'),
          ),
        ],
      ),
    );
  }
}
