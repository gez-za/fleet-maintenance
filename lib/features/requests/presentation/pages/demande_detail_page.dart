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
    
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la Demande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            if (demande.bonNumber != null) _buildCouponCard(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildDetailsCard(),
            const SizedBox(height: 24),
            if (demande.justificatif != null) _buildJustificatifCard(),
            const SizedBox(height: 40),
            _buildDynamicActions(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number_outlined, color: Colors.purple),
              SizedBox(width: 8),
              Text('COUPON / BON GÉNÉRÉ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
            ],
          ),
          const Divider(height: 32),
          Text(demande.bonNumber!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCouponInfo('Quantité', '${demande.quantityGranted ?? demande.quantityEstimated ?? '--'}'),
              _buildCouponInfo('Validité', demande.bonExpiryDate != null ? DateFormat('dd/MM/yy').format(demande.bonExpiryDate!) : '--'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDynamicActions(BuildContext context, WidgetRef ref, User? user) {
    if (user == null) return const SizedBox();

    final List<Widget> buttons = [];

    // 1. Actions CHEF ATELIER
    if (user.role == UserRole.CHEF_ATELIER && demande.status == DemandeStatus.CREEE) {
      buttons.add(_buildActionButton(
        'VALIDER ATELIER', 
        Colors.blue, 
        () => _handleAction(context, ref, DemandeStatus.VALIDEE_ATELIER)
      ));
      buttons.add(const SizedBox(width: 12));
      buttons.add(_buildActionButton(
        'REJETER', 
        Colors.red, 
        () => _handleAction(context, ref, DemandeStatus.REJETEE, needsReason: true)
      ));
    }

    // 2. Actions DIRECTEUR
    if (user.role == UserRole.DIRECTEUR) {
      if (demande.status == DemandeStatus.VALIDEE_ATELIER) {
        buttons.add(_buildActionButton(
          'VALIDER DIRECTION', 
          Colors.indigo, 
          () => _handleAction(context, ref, DemandeStatus.VALIDEE_DIRECTION)
        ));
        buttons.add(const SizedBox(width: 12));
        buttons.add(_buildActionButton(
          'GÉNÉRER COUPON', 
          Colors.purple, 
          () => _handleAction(context, ref, DemandeStatus.BON_GENERE)
        ));
        buttons.add(const SizedBox(width: 12));
        buttons.add(_buildActionButton(
          'REJETER', 
          Colors.red, 
          () => _handleAction(context, ref, DemandeStatus.REJETEE, needsReason: true)
        ));
      } else if (demande.status == DemandeStatus.VALIDEE_DIRECTION) {
        buttons.add(_buildActionButton(
          'GÉNÉRER COUPON', 
          Colors.purple, 
          () => _handleAction(context, ref, DemandeStatus.BON_GENERE)
        ));
      }
    }

    if (buttons.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: buttons),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, DemandeStatus status, {bool needsReason = false}) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == DemandeStatus.REJETEE ? 'Rejeter la demande' : 'Confirmer l\'action'),
        content: needsReason 
            ? TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Motif du rejet'))
            : Text('Voulez-vous passer cette demande au statut ${status.label} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(demandeProvider.notifier).processAction(
                demande.id, 
                status: status.name,
                rejectionReason: needsReason ? reasonController.text : null,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ref.read(demandeProvider.notifier).fetchDemandeDetail(demande.id);
              }
            },
            child: const Text('CONFIRMER'),
          ),
        ],
      ),
    );
  }
}
