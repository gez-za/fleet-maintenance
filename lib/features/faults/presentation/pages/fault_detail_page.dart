import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/maintenance_enums.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/fault.dart';
import '../providers/fault_notifier.dart';
import '../widgets/status_badge.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/fault_map_widget.dart';

class FaultDetailPage extends ConsumerStatefulWidget {
  final String faultId;

  const FaultDetailPage({super.key, required this.faultId});

  @override
  ConsumerState<FaultDetailPage> createState() => _FaultDetailPageState();
}

class _FaultDetailPageState extends ConsumerState<FaultDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(faultProvider.notifier).fetchFaultDetail(widget.faultId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les erreurs pour afficher une snackbar
    ref.listen<FaultState>(faultProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    final faultState = ref.watch(faultProvider);
    final user = ref.watch(authProvider).user;
    
    // On cherche la panne dans la liste actuelle
    Fault? fault;
    try {
      fault = faultState.faults.firstWhere((f) => f.id == widget.faultId);
    } catch (_) {
      fault = null;
    }

    if (fault == null && faultState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (fault == null && !faultState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                const SizedBox(height: 16),
                Text(
                  faultState.error ?? 'Panne non trouvée',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.read(faultProvider.notifier).fetchFaultDetail(widget.faultId),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // A ce stade, fault n'est plus nul
    final currentFault = fault!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail de la Panne'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: () => ref.read(faultProvider.notifier).fetchFaultDetail(widget.faultId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(faultProvider.notifier).fetchFaultDetail(widget.faultId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderImage(context, currentFault),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(context, currentFault),
                    const SizedBox(height: 20),
                    if (currentFault.latitude != null && currentFault.longitude != null) ...[
                      _buildLocationInfo(currentFault),
                      const SizedBox(height: 20),
                    ],
                    _buildDescription(currentFault),
                    const SizedBox(height: 20),
                    _buildStatusCard(currentFault),
                    const SizedBox(height: 20),
                    if (currentFault.diagnostic != null && currentFault.diagnostic!.isNotEmpty)
                      _buildDiagnosticCard(currentFault),
                    const SizedBox(height: 40),
                    _buildActionButtons(context, ref, currentFault, user),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, Fault fault) {
    final imageUrl = ApiConstants.getFullImageUrl(fault.photo);
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Colors.black12,
      ),
      child: imageUrl != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      _showFullScreenImage(context, imageUrl);
                    },
                    child: const Icon(Icons.fullscreen),
                  ),
                ),
              ],
            )
          : const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 80, color: AppColors.textHint),
            ),
    );
  }

  Widget _buildMainInfo(BuildContext context, Fault fault) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: fault.vehicle != null 
                ? () => Navigator.pushNamed(context, '/vehicles/detail', arguments: fault.vehicleId)
                : null,
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fault.vehicle?.immatriculation ?? 'VÉHICULE INCONNU',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        '${fault.vehicle?.marque ?? ""} ${fault.vehicle?.modele ?? ""}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (fault.vehicle != null)
                  const Icon(Icons.chevron_right, color: AppColors.textHint),
                const SizedBox(width: 8),
                StatusBadge(
                  label: fault.criticality.label,
                  color: fault.criticality.color,
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMiniInfo(Icons.person_outline, 'Déclarant', fault.reporter?.displayName ?? 'Inconnu')),
              if (fault.reporter?.profile?.telephone != null)
                IconButton(
                  onPressed: () => launchUrl(Uri.parse('tel:${fault.reporter!.profile!.telephone}')),
                  icon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              const SizedBox(width: 16),
              Expanded(child: _buildMiniInfo(Icons.calendar_today_outlined, 'Date', fault.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(fault.createdAt!) : '--')),
            ],
          ),
          if (fault.vehicle?.numeroChassis != null) ...[
            const Divider(height: 24),
            _buildMiniInfo(Icons.fingerprint, 'N° Chassis', fault.vehicle!.numeroChassis!),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo(Fault fault) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LOCALISATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(AppDimensions.space12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fault.addressApprox != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fault.addressApprox!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              FaultMapWidget(
                latitude: fault.latitude!,
                longitude: fault.longitude!,
                criticality: fault.criticality,
                vehicleInfo: '${fault.vehicle?.immatriculation} - ${fault.vehicle?.marque} ${fault.vehicle?.modele}',
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openRoute(fault.latitude!, fault.longitude!),
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('VOIR L\'ITINÉRAIRE'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openRoute(double lat, double lng) async {
    final googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');
    final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Fault fault) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(fault.description, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildStatusCard(Fault fault) {
    return Row(
      children: [
        const Text('STATUT ACTUEL : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        StatusBadge(
          label: fault.status.label,
          color: _getStatusColor(fault.status),
        ),
      ],
    );
  }

  Widget _buildDiagnosticCard(Fault fault) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DIAGNOSTIC TECHNIQUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fault.diagnostic ?? "", style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
              if (fault.technician != null) ...[
                const Divider(),
                Text('Par : ${fault.technician?.displayName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Fault fault, User? user) {
    if (user == null) return const SizedBox();

    final List<Widget> actions = [];

    final isTechOrManager = user.role == UserRole.TECHNICIEN || 
                             user.role == UserRole.CHEF_ATELIER || 
                             user.role == UserRole.ADMIN;
                             
    final isManager = user.role == UserRole.CHEF_ATELIER || 
                      user.role == UserRole.ADMIN;

    // 1. Démarrer Diagnostic (DECLAREE -> EN_DIAGNOSTIC)
    if (isTechOrManager && fault.status == PanneStatus.DECLAREE) {
      actions.add(
        _buildActionItem(
          context,
          'Démarrer Diagnostic',
          Icons.play_arrow_outlined,
          Colors.blue,
          () => ref.read(faultProvider.notifier).updateFaultStatus(fault.id, 'EN_DIAGNOSTIC'),
        ),
      );
    }

    // 2. Ajouter Diagnostic (Pendant EN_DIAGNOSTIC)
    if (isTechOrManager && fault.status == PanneStatus.EN_DIAGNOSTIC) {
      actions.add(
        _buildActionItem(
          context,
          'Ajouter un Diagnostic',
          Icons.biotech_outlined,
          Colors.orange,
          () => _showDiagnosticDialog(context, ref, fault),
        ),
      );
    }

    // 3. Créer Ordre de Travail (EN_DIAGNOSTIC ou VALIDEE)
    if (isManager && (fault.status == PanneStatus.EN_DIAGNOSTIC || fault.status == PanneStatus.VALIDEE)) {
      if (actions.isNotEmpty) actions.add(const SizedBox(height: 12));
      actions.add(
        _buildActionItem(
          context,
          'Créer un Ordre de Travail',
          Icons.assignment_add,
          AppColors.primary,
          () => Navigator.pushNamed(context, '/work-orders/create', arguments: fault),
        ),
      );
    }

    // 4. Clôturer (Pendant EN_COURS)
    if (isTechOrManager && fault.status == PanneStatus.EN_COURS) {
      actions.add(
        _buildActionItem(
          context,
          'Clôturer la Panne',
          Icons.check_circle_outline,
          Colors.green,
          () => ref.read(faultProvider.notifier).updateFaultStatus(fault.id, 'CLOTUREE'),
        ),
      );
    }

    return Column(children: actions);
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
        ),
      ),
    );
  }

  void _showDiagnosticDialog(BuildContext context, WidgetRef ref, Fault fault) {
    final controller = TextEditingController(text: fault.diagnostic);
    PanneStatus selectedStatus = PanneStatus.VALIDEE;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostic Technique'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Résultats du diagnostic...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PanneStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Nouveau statut'),
                items: [PanneStatus.EN_DIAGNOSTIC, PanneStatus.VALIDEE, PanneStatus.EN_COURS, PanneStatus.CLOTUREE]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (val) => selectedStatus = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(faultProvider.notifier).addDiagnostic(
                fault.id,
                diagnostic: controller.text,
                status: selectedStatus.name,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagnostic mis à jour')));
              }
            },
            child: const Text('ENREGISTRER'),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Stack(
          children: [
            Center(child: Image.network(imageUrl)),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PanneStatus status) {
    switch (status) {
      case PanneStatus.DECLAREE:      return Colors.blue;
      case PanneStatus.VALIDEE:       return Colors.indigo;
      case PanneStatus.EN_DIAGNOSTIC: return Colors.orange;
      case PanneStatus.EN_COURS: return Colors.purple;
      case PanneStatus.CLOTUREE:      return Colors.green;
      default:                        return Colors.grey;
    }
  }
}
