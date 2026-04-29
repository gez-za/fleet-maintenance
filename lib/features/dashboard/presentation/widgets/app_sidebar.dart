// ============================================================
// AutoPark IUC — Sidebar de navigation
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../core/widgets/user_avatar.dart';

// ── Modèle d'un item de navigation ────────────────────────────
class NavItem {
  final String   label;
  final IconData icon;
  final int      index;
  const NavItem({required this.label, required this.icon, required this.index});
}

const _navItems = [
  NavItem(label: 'Tableau de bord', icon: Icons.dashboard_rounded,       index: 0),
  NavItem(label: 'Véhicules',       icon: Icons.directions_car_rounded,   index: 1),
  NavItem(label: 'Pannes',          icon: Icons.warning_amber_rounded,    index: 2),
  NavItem(label: 'Atelier',         icon: Icons.build_rounded,            index: 3),
  NavItem(label: 'Carburant',       icon: Icons.local_gas_station_rounded, index: 4),
  NavItem(label: 'Chauffeurs',      icon: Icons.badge_rounded,            index: 5),
  NavItem(label: 'Matériels',       icon: Icons.inventory_2_rounded,      index: 6),
  NavItem(label: 'Fournisseurs',    icon: Icons.store_rounded,            index: 7),
];

class AppSidebar extends ConsumerWidget {
  final int            selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback?  onClose;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Container(
      width:  240,
      height: double.infinity,
      color:  AppColors.sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(child: _buildNavList()),
            _buildUserProfile(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color:        AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('AutoPark',
              style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
              )),
        ),
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.sidebarText, size: 20),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
      ]),
    );
  }

  Widget _buildNavList() {
    return ListView.builder(
      padding:     const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount:   _navItems.length,
      itemBuilder: (_, i) => _NavTile(
        item:     _navItems[i],
        isActive: selectedIndex == _navItems[i].index,
        onTap:    () => onSelect(_navItems[i].index),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, WidgetRef ref, User? user) {
    final displayName = user?.displayName ?? 'Utilisateur';

    return GestureDetector(
      onTap: () {
        debugPrint('Navigating to profile from Sidebar');
        Navigator.of(context).pushNamed('/profile');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A3547))),
        ),
        child: Row(children: [
          UserAvatar(user: user, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                displayName.isEmpty ? 'Utilisateur' : displayName,
                style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              Text(
                user?.role.label ?? '',
                style: const TextStyle(color: AppColors.sidebarText, fontSize: 11),
              ),
            ]),
          ),
          IconButton(
            onPressed: () {
              debugPrint('Logout clicked');
              _confirmLogout(context, ref);
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.sidebarText, size: 18),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            tooltip: 'Déconnexion',
          ),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Déconnexion'),
        content: const Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.unavailable),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final NavItem  item;
  final bool     isActive;
  final VoidCallback onTap;

  const _NavTile({required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color:        isActive ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor:   Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Icon(item.icon,
                size:  18,
                color: isActive ? Colors.white : AppColors.sidebarText,
              ),
              const SizedBox(width: 12),
              Text(item.label,
                  style: TextStyle(
                    color:      isActive ? Colors.white : AppColors.sidebarText,
                    fontSize:   13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  )),
            ]),
          ),
        ),
      ),
    );
  }
}
