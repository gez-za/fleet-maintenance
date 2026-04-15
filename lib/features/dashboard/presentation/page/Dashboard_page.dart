/// ============================================================
/// AutoPark IUC - Dashboard (Page principale post-login)
/// ============================================================
/// Affiche le profil utilisateur et adapte l'UI selon le rôle.
/// Les rôles contrôlent l'accès aux fonctionnalités.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/domain/entities/user_entity.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoPark IUC'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Profil ───────────────────────────────────
            _ProfileCard(user: user),

            const SizedBox(height: 28),

            Text(
              'Accès rapide',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ── Modules selon le rôle ─────────────────────────
            _RoleBasedModules(role: user.role),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserEntity user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBasedModules extends StatelessWidget {
  final UserRole role;

  const _RoleBasedModules({required this.role});

  List<_ModuleItem> _getModulesForRole(UserRole role) {
    // Modules disponibles pour tous
    final common = [
      _ModuleItem(Icons.directions_car_rounded, 'Véhicules', 'Parc automobile'),
      _ModuleItem(Icons.assignment_rounded, 'Missions', 'Mes affectations'),
    ];

    // Modules spécifiques par rôle
    final byRole = {
      UserRole.admin: [
        _ModuleItem(Icons.people_rounded, 'Utilisateurs', 'Gestion des comptes'),
        _ModuleItem(Icons.bar_chart_rounded, 'Rapports', 'Statistiques'),
        _ModuleItem(Icons.settings_rounded, 'Paramètres', 'Configuration'),
      ],
      UserRole.directeur: [
        _ModuleItem(Icons.bar_chart_rounded, 'Rapports', 'Tableau de bord'),
        _ModuleItem(Icons.approval_rounded, 'Approbations', 'En attente'),
      ],
      UserRole.chefChauffeur: [
        _ModuleItem(Icons.group_rounded, 'Chauffeurs', 'Mon équipe'),
        _ModuleItem(Icons.route_rounded, 'Planning', 'Tournées'),
      ],
      UserRole.responsableAtelier: [
        _ModuleItem(Icons.build_rounded, 'Maintenance', 'Interventions'),
        _ModuleItem(Icons.inventory_2_rounded, 'Pièces', 'Stock'),
      ],
      UserRole.technicien: [
        _ModuleItem(Icons.build_circle_rounded, 'Interventions', 'Mes tâches'),
      ],
      UserRole.chauffeur: [
        _ModuleItem(Icons.map_rounded, 'Itinéraires', 'Mes trajets'),
      ],
    };

    return [...common, ...(byRole[role] ?? [])];
  }

  @override
  Widget build(BuildContext context) {
    final modules = _getModulesForRole(role);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _ModuleCard(module: module);
      },
    );
  }
}

class _ModuleItem {
  final IconData icon;
  final String title;
  final String subtitle;

  _ModuleItem(this.icon, this.title, this.subtitle);
}

class _ModuleCard extends StatelessWidget {
  final _ModuleItem module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {}, // Navigation vers le module
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                module.icon,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  module.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}