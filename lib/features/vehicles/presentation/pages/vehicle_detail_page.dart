import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../users/presentation/providers/user_notifier.dart';
import '../../../../core/models/user.dart';
import '../../models/vehicle.dart';
import '../../models/affectation.dart';
import '../providers/vehicle_notifier.dart';
import 'edit_vehicle_page.dart';
import '../../../faults/presentation/providers/fault_notifier.dart';
import '../../../faults/presentation/widgets/fault_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page principale
// ─────────────────────────────────────────────────────────────────────────────

class VehicleDetailPage extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailPage({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends ConsumerState<VehicleDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AffectationChauffeur> _affectations = [];
  bool _loadingAffectations = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      ref.read(faultProvider.notifier).fetchFaults(vehicleId: widget.vehicleId);
      _loadAffectations();
    });
  }

  Future<void> _loadAffectations() async {
    setState(() => _loadingAffectations = true);
    try {
      final data = await ref.read(vehicleServiceProvider).getAffectations(widget.vehicleId);
      if (mounted) {
        setState(() {
          _affectations = data.map((e) => AffectationChauffeur.fromJson(e)).toList();
          _loadingAffectations = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingAffectations = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Vehicle? _resolveVehicle(List<Vehicle> vehicles) {
    try {
      return vehicles.firstWhere((v) => v.id == widget.vehicleId);
    } catch (_) {
      return null;
    }
  }

  // ── Navigation vers la page d'édition ────────────────────────────────────
  void _navigateToEdit(Vehicle vehicle) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditVehiclePage(vehicle: vehicle),
      ),
    );
    // Si des modifications ont été faites, on force un refresh
    if (updated == true) {
      ref.read(vehicleProvider.notifier).refresh();
    }
  }

  // ── Dialogue de confirmation de suppression ───────────────────────────────
  void _confirmDelete(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.danger, size: 24),
            SizedBox(width: 10),
            Text(
              'Supprimer le véhicule',
              style: TextStyle(
                fontSize: AppDimensions.fontMD,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppDimensions.fontSM,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Vous êtes sur le point de supprimer\n'),
              TextSpan(
                text: '${vehicle.marque} ${vehicle.modele} '
                    '(${vehicle.immatriculation})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(
                  text: '.\n\nCette action est irréversible.'),
            ],
          ),
        ),
        actionsPadding:
        const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // ferme le dialogue
              await _deleteVehicle(vehicle.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: const Text('Supprimer',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(String id) async {
    final success =
    await ref.read(vehicleProvider.notifier).deleteVehicle(id);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Véhicule supprimé avec succès.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context); // retour à la liste
      } else {
        final error = ref.read(vehicleProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de la suppression'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // ── Bottom sheet : affecter un chauffeur ─────────────────────────────────
  void _showAffectationDialog() {
    final userListState = ref.read(userListProvider);
    final chauffeurs = userListState.users.where((u) => u.role == UserRole.CHAUFFEUR).toList();
    
    String? selectedChauffeurId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setModal) => Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Affecter un chauffeur',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLG,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                if (chauffeurs.isEmpty)
                  const Text('Aucun chauffeur disponible. Veuillez d\'abord créer des chauffeurs.',
                    style: TextStyle(color: AppColors.danger))
                else
                  DropdownButtonFormField<String>(
                    value: selectedChauffeurId,
                    decoration: _inputDeco('Choisir un chauffeur'),
                    items: chauffeurs.map((c) => DropdownMenuItem(
                      value: c.uuid,
                      child: Text(c.displayName),
                    )).toList(),
                    onChanged: (v) => setModal(() => selectedChauffeurId = v),
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: selectedChauffeurId == null ? null : () async {
                      final success = await ref.read(vehicleProvider.notifier)
                          .affecterChauffeur(widget.vehicleId, selectedChauffeurId!);
                      
                      if (success) {
                        _loadAffectations();
                        if (mounted) Navigator.pop(context);
                      } else {
                        final error = ref.read(vehicleProvider).error;
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error ?? 'Erreur lors de l\'affectation')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium),
                      ),
                    ),
                    child: const Text('AFFECTER',
                        style:
                        TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isAdmin ?? false;
    final canAssign = user != null && (user.isAdmin || user.role == UserRole.CHEF_CHAUFFEUR);

    final vehicle = _resolveVehicle(vehicleState.vehicles);

    if (vehicleState.isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du Véhicule'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_outlined,
                  size: 64, color: AppColors.textHint),
              SizedBox(height: 16),
              Text('Véhicule introuvable',
                  style: TextStyle(
                      fontSize: AppDimensions.fontLG,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            actions: [
              if (canAssign)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Modifier',
                  onPressed: () => _navigateToEdit(vehicle),
                ),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') _confirmDelete(vehicle);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              color: AppColors.danger, size: 20),
                          SizedBox(width: 10),
                          Text('Supprimer',
                              style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  vehicle.image != null && vehicle.image!.isNotEmpty
                      ? Image.network(
                    vehicle.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _imagePlaceholder(),
                  )
                      : _imagePlaceholder(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xDD000000),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.marque} ${vehicle.modele}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  blurRadius: 8,
                                  color: Colors.black45)
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatutBadge(statut: vehicle.statut),
                            const SizedBox(width: 8),
                            _CategorieBadge(
                                categorie: vehicle.categorie),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.55),
              indicatorColor: AppColors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontSM,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline, size: 18),
                    text: 'Infos'),
                Tab(icon: Icon(Icons.person_outline, size: 18),
                    text: 'Chauffeurs'),
                Tab(icon: Icon(Icons.build_outlined, size: 18),
                    text: 'Pannes'),
                Tab(
                    icon: Icon(Icons.local_gas_station_outlined, size: 18),
                    text: 'Depenses'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _InfosTab(vehicle: vehicle),
            _ChauffeursTab(
              affectations: _affectations,
              onAffecter: _showAffectationDialog,
              isAdmin: canAssign,
              isLoading: _loadingAffectations,
            ),
            _VehicleFaultsTab(vehicleId: vehicle.id),
            const _EmptyModuleTab(
              icon: Icons.local_gas_station_outlined,
              titre: 'Depenses',
              message:
              'Le module des demandes Depenses\nsera disponible prochainement.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    color: AppColors.primary.withOpacity(0.12),
    child: const Center(
      child: Icon(Icons.directions_car_outlined,
          size: 80, color: AppColors.primary),
    ),
  );

  InputDecoration _inputDeco(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12),
    border: OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(AppDimensions.radiusMedium),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(AppDimensions.radiusMedium),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(AppDimensions.radiusMedium),
      borderSide:
      const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ONGLET 1 — Infos
// ─────────────────────────────────────────────────────────────────────────────

class _InfosTab extends StatelessWidget {
  final Vehicle vehicle;

  const _InfosTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingHorizontal),
      children: [
        const SizedBox(height: 8),
        _SectionCard(
          titre: 'Identification',
          icon: Icons.badge_outlined,
          children: [
            _InfoRow(label: 'Immatriculation', value: v.immatriculation),
            _InfoRow(label: 'Marque',           value: v.marque),
            _InfoRow(label: 'Modèle',           value: v.modele),
            _InfoRow(label: 'Année',            value: v.annee.toString()),
            _InfoRow(
              label: 'N° châssis',
              value: (v.numeroChassis?.isNotEmpty ?? false)
                  ? v.numeroChassis!
                  : '—',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          titre: 'Classification',
          icon: Icons.category_outlined,
          children: [
            _InfoRow(label: 'Catégorie', value: v.categorie.label),
            _InfoRow(label: 'Statut',    value: v.statut.label),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          titre: 'Kilométrage',
          icon: Icons.speed_outlined,
          children: [
            _InfoRow(label: 'Km actuel', value: _fmtKm(v.kmActuel)),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _fmtKm(int km) =>
      '${km.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ')} km';
}

// ─────────────────────────────────────────────────────────────────────────────
// ONGLET 2 — Chauffeurs
// ─────────────────────────────────────────────────────────────────────────────

class _ChauffeursTab extends StatelessWidget {
  final List<AffectationChauffeur> affectations;
  final VoidCallback onAffecter;
  final bool isAdmin;
  final bool isLoading;

  const _ChauffeursTab({
    required this.affectations,
    required this.onAffecter,
    required this.isAdmin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final actifs = affectations.where((a) => a.actif).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                '$actifs chauffeur${actifs > 1 ? 's' : ''} actif${actifs > 1 ? 's' : ''}',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontSM),
              ),
              const Spacer(),
              if (isAdmin)
                FilledButton.icon(
                  onPressed: onAffecter,
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Affecter'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: affectations.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_outlined,
                    size: 56, color: AppColors.textHint),
                SizedBox(height: 12),
                Text('Aucun chauffeur affecté',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppDimensions.fontMD)),
                SizedBox(height: 6),
                Text(
                  'Appuyez sur « Affecter » pour en ajouter un.',
                  style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: AppDimensions.fontSM),
                ),
              ],
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: affectations.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _AffectationCard(affectation: affectations[i]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONGLET VIDE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyModuleTab extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String message;

  const _EmptyModuleTab({
    required this.icon,
    required this.titre,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(titre,
                style: const TextStyle(
                    fontSize: AppDimensions.fontLG,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: AppDimensions.fontSM,
                    color: AppColors.textSecondary,
                    height: 1.6)),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textHint,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: const Text('Bientôt disponible'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS RÉUTILISABLES
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String titre;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.titre,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  titre.toUpperCase(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontXS,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontSM)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppDimensions.fontSM,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _AffectationCard extends StatelessWidget {
  final AffectationChauffeur affectation;

  const _AffectationCard({required this.affectation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [AppColors.cardShadow],
        border: affectation.actif
            ? Border.all(
            color: AppColors.primary.withOpacity(0.25),
            width: 1.2)
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: affectation.actif
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline,
                color: affectation.actif
                    ? AppColors.primary
                    : AppColors.textHint,
                size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(affectation.nomComplet,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.fontMD,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  'Permis ${affectation.categoriePermis} · ${affectation.numeroPermis}',
                  style: const TextStyle(
                      fontSize: AppDimensions.fontSM,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text('Depuis le ${_fmt(affectation.dateDebut)}',
                    style: const TextStyle(
                        fontSize: AppDimensions.fontXS,
                        color: AppColors.textHint)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: affectation.actif
                  ? const Color(0xFF0D9488).withOpacity(0.1)
                  : AppColors.border,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              affectation.actif ? 'Actif' : 'Terminé',
              style: TextStyle(
                  fontSize: AppDimensions.fontXS,
                  fontWeight: FontWeight.bold,
                  color: affectation.actif
                      ? const Color(0xFF0D9488)
                      : AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// ONGLET 3 — Pannes du véhicule
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleFaultsTab extends ConsumerWidget {
  final String vehicleId;

  const _VehicleFaultsTab({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faultState = ref.watch(faultProvider);
    final vehicleFaults = faultState.faults.where((f) => f.vehicleId == vehicleId).toList();

    if (faultState.isLoading && vehicleFaults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vehicleFaults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text('Aucune panne',
                  style: TextStyle(
                      fontSize: AppDimensions.fontLG,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              const Text('Aucune panne n\'a été déclarée pour ce véhicule.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: AppDimensions.fontSM,
                      color: AppColors.textSecondary,
                      height: 1.6)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicleFaults.length,
      itemBuilder: (context, index) {
        final fault = vehicleFaults[index];
        return FaultCard(
          fault: fault,
          onTap: () => Navigator.pushNamed(
            context,
            '/faults/detail',
            arguments: fault.id,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGES
// ─────────────────────────────────────────────────────────────────────────────

class _StatutBadge extends StatelessWidget {
  final VehicleStatut statut;

  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: statut.color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: statut.color.withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statut.icon, size: 12, color: statut.color),
        const SizedBox(width: 4),
        Text(statut.label,
            style: TextStyle(
                fontSize: AppDimensions.fontXS,
                fontWeight: FontWeight.bold,
                color: statut.color)),
      ],
    ),
  );
}

class _CategorieBadge extends StatelessWidget {
  final VehicleCategorie categorie;

  const _CategorieBadge({required this.categorie});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border:
      Border.all(color: Colors.white.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(categorie.icon, size: 12, color: Colors.white),
        const SizedBox(width: 4),
        Text(categorie.label,
            style: const TextStyle(
                fontSize: AppDimensions.fontXS,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    ),
  );
}