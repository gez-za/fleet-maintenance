// ============================================================
// AutoPark IUC — Onglet d'accueil (Résumé des activités)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../faults/presentation/providers/fault_notifier.dart';
import '../../../vehicles/presentation/providers/vehicle_notifier.dart';
import '../../../vehicles/models/vehicle.dart';
import '../../../users/presentation/providers/user_notifier.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      final role = user?.role;

      ref.read(vehicleProvider.notifier).fetchVehicles();
      
      if (role == UserRole.ADMIN || role == UserRole.DIRECTEUR || role == UserRole.CHEF_ATELIER || role == UserRole.CHEF_CHAUFFEUR) {
        ref.read(userListProvider.notifier).loadUsers();
      }
      
      ref.read(faultProvider.notifier).fetchFaults();
      
      if (role == UserRole.ADMIN || role == UserRole.CHEF_ATELIER || role == UserRole.DIRECTEUR) {
        // Materials/Inventory
        ref.read(materielsProvider.notifier).refresh();
        ref.read(stockAlertsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? UserRole.CHAUFFEUR;
    final isMobile = MediaQuery.of(context).size.width < 1100;

    final vehicleState = ref.watch(vehicleProvider);
    final userState = ref.watch(userListProvider);
    final faultState = ref.watch(faultProvider);
    final materielsState = ref.watch(materielsProvider);
    final alertsState = ref.watch(stockAlertsProvider);

    // Pour les chauffeurs, on écoute l'identification du véhicule pour charger les alertes/pannes
    if (role == UserRole.CHAUFFEUR) {
      ref.listen(myVehicleProvider, (previous, next) {
        if (previous == null && next != null) {
          ref.read(faultProvider.notifier).fetchFaults(vehicleId: next.id);
        }
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) const SizedBox(height: 8),
          if (user != null) _buildWelcomeHeader(user),
          const SizedBox(height: 24),
          _buildSummaryCards(user, role, isMobile, vehicleState, userState, faultState, materielsState, alertsState),
          const SizedBox(height: 32),
          _buildQuickActions(context, role, isMobile),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, ${user?.displayName ?? 'Utilisateur'} !',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Rôle : ${user?.role.label ?? ''}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(User? user, UserRole role, bool isMobile, VehicleState vehicleState, UserListState userState, FaultState faultState, AsyncValue<List> materiels, AsyncValue<List> alerts) {
    final cards = _getCardsForRole(user, role, vehicleState, userState, faultState, materiels, alerts);
    
    if (isMobile) {
      return Column(
        children: cards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: c,
        )).toList(),
      );
    }

    return Row(
      children: cards.map((c) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: c,
        ),
      )).toList(),
    );
  }

  List<Widget> _getCardsForRole(User? user, UserRole role, VehicleState vehicleState, UserListState userState, FaultState faultState, AsyncValue<List> materiels, AsyncValue<List> alerts) {
    final totalVehicles = vehicleState.vehicles.length.toString();
    final totalUsers = userState.users.length.toString();
    final totalMateriels = (materiels.value?.length ?? 0).toString();
    final totalAlerts = (alerts.value?.length ?? 0).toString();
    final totalFaults = faultState.faults.length.toString();

    switch (role) {
      case UserRole.ADMIN:
        return [
          _StatCard(title: 'Utilisateurs', value: totalUsers, icon: Icons.people_alt_rounded, color: AppColors.primary),
          _StatCard(title: 'Véhicules', value: totalVehicles, icon: Icons.directions_car_rounded, color: AppColors.primaryMid),
          _StatCard(title: 'Matériels', value: totalMateriels, icon: Icons.inventory_2_rounded, color: Colors.blueGrey),
        ];
      case UserRole.DIRECTEUR:
        return [
          _StatCard(title: 'Parc Automobile', value: totalVehicles, icon: Icons.directions_car_rounded, color: AppColors.primary),
          _StatCard(title: 'Alertes Stock', value: totalAlerts, icon: Icons.notifications_active_rounded, color: AppColors.danger),
          const _StatCard(title: 'Consommation', value: '--', icon: Icons.local_gas_station_rounded, color: AppColors.warning),
        ];
      case UserRole.CHEF_ATELIER:
        return [
          _StatCard(title: 'Alertes Stock', value: totalAlerts, icon: Icons.warning_amber_rounded, color: AppColors.danger),
          _StatCard(title: 'Matériels', value: totalMateriels, icon: Icons.inventory_2_rounded, color: AppColors.primary),
          _StatCard(title: 'Véhicules', value: totalVehicles, icon: Icons.directions_car_rounded, color: AppColors.primaryMid),
        ];
      case UserRole.TECHNICIEN:
        return [
          const _StatCard(title: 'Mes OT', value: '0', icon: Icons.assignment_turned_in_rounded, color: AppColors.primary),
          const _StatCard(title: 'Urgent', value: '0', icon: Icons.new_releases_rounded, color: AppColors.danger),
          const _StatCard(title: 'Pièces', value: '0', icon: Icons.shopping_cart_outlined, color: AppColors.warning),
        ];
      case UserRole.CHAUFFEUR:
        final myVehicle = ref.watch(myVehicleProvider) ?? const Vehicle(id: '', immatriculation: 'N/A', marque: '', modele: '', annee: 0, categorie: VehicleCategorie.SERVICE, statut: VehicleStatut.DISPONIBLE);
        
        return [
          _StatCard(
            title: 'Mon Véhicule', 
            value: myVehicle.immatriculation, 
            icon: Icons.directions_car_rounded, 
            color: AppColors.primary,
            onTap: myVehicle.id.isNotEmpty ? () => Navigator.pushNamed(context, '/vehicles/detail', arguments: myVehicle.id) : null,
          ),
          const _StatCard(title: 'Prochaine Maintenance', value: '--', icon: Icons.event_note_rounded, color: AppColors.warning),
          _StatCard(
            title: 'Alertes', 
            value: totalFaults, 
            icon: Icons.warning_rounded, 
            color: AppColors.danger,
            onTap: () => Navigator.pushNamed(context, '/faults'),
          ),
        ];
      case UserRole.CHEF_CHAUFFEUR:
        final chauffeursCount = userState.users.where((u) => u.role == UserRole.CHAUFFEUR).length.toString();
        return [
          _StatCard(title: 'Chauffeurs', value: chauffeursCount, icon: Icons.badge_rounded, color: AppColors.primary),
          _StatCard(title: 'Véhicules', value: totalVehicles, icon: Icons.directions_car_rounded, color: AppColors.primaryMid),
          _StatCard(title: 'Alertes Pannes', value: totalFaults, icon: Icons.warning_amber_rounded, color: AppColors.danger),
        ];
    }
  }

  Widget _buildQuickActions(BuildContext context, UserRole role, bool isMobile) {
    final actions = _getActionsForRole(context, role);
    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions Rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.3 : 1.6,
          children: actions.map((a) => _QuickActionCard(
            title: a.title,
            icon: a.icon,
            color: a.color,
            onTap: a.onTap,
          )).toList(),
        ),
      ],
    );
  }

  List<_ActionData> _getActionsForRole(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.CHAUFFEUR:
        return [
          _ActionData(title: 'Déclarer Panne', icon: Icons.report_problem_rounded, color: AppColors.danger, onTap: () => Navigator.pushNamed(context, '/faults/declare')),
          _ActionData(title: 'Carburant', icon: Icons.local_gas_station_rounded, color: AppColors.primary, onTap: () => Navigator.pushNamed(context, '/demandes/create')),
        ];
      case UserRole.CHEF_CHAUFFEUR:
        return [
          _ActionData(title: 'Affecter Chauffeur', icon: Icons.person_add_rounded, color: AppColors.primary, onTap: () => Navigator.pushNamed(context, '/vehicles')),
          _ActionData(title: 'Déclarer Panne', icon: Icons.report_problem_rounded, color: AppColors.danger, onTap: () => Navigator.pushNamed(context, '/faults/declare')),
          _ActionData(title: 'Liste Chauffeurs', icon: Icons.people_outline_rounded, color: AppColors.primaryMid, onTap: () => Navigator.pushNamed(context, '/users')),
        ];
      case UserRole.TECHNICIEN:
        return [
          _ActionData(title: 'Pièces Stock', icon: Icons.inventory_2_rounded, color: AppColors.primary, onTap: () => Navigator.pushNamed(context, '/inventory')),
          _ActionData(title: 'Dépenses', icon: Icons.account_balance_wallet_rounded, color: AppColors.primaryMid, onTap: () => Navigator.pushNamed(context, '/depenses')),
          _ActionData(title: 'Nouvelle Demande', icon: Icons.add_circle_outline_rounded, color: Colors.blueGrey, onTap: () => Navigator.pushNamed(context, '/demandes/create')),
        ];
      case UserRole.CHEF_ATELIER:
        return [
          _ActionData(title: 'Sortie Pièce', icon: Icons.remove_circle_outline, color: AppColors.danger, onTap: () => Navigator.pushNamed(context, '/inventory')),
          _ActionData(title: 'Valider Demandes', icon: Icons.fact_check_rounded, color: AppColors.primary, onTap: () => Navigator.pushNamed(context, '/demandes')),
          _ActionData(title: 'Dépenses', icon: Icons.account_balance_wallet_rounded, color: AppColors.warning, onTap: () => Navigator.pushNamed(context, '/depenses')),
        ];
      case UserRole.ADMIN:
        return [
          _ActionData(title: 'Utilisateur', icon: Icons.person_add_rounded, color: AppColors.primary, onTap: () => Navigator.of(context).pushNamed('/users/add')),
          _ActionData(title: 'Véhicule', icon: Icons.add_road_rounded, color: AppColors.primaryMid, onTap: () => Navigator.of(context).pushNamed('/vehicles/add')),
          _ActionData(title: 'Stats Dépenses', icon: Icons.bar_chart_rounded, color: Colors.blueGrey, onTap: () => Navigator.pushNamed(context, '/depenses')),
        ];
      default:
        return [];
    }
  }
}

class _ActionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _ActionData({required this.title, required this.icon, required this.color, required this.onTap});
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
