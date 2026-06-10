import 'package:flutter/material.dart';
import '../models/user.dart';

class NavItem {
  final String   label;
  final IconData icon;
  final int      index;
  const NavItem({required this.label, required this.icon, required this.index});

  static List<NavItem> getItemsByRole(UserRole? role) {
    const allItems = [
      NavItem(label: 'Tableau de bord', icon: Icons.dashboard_rounded,       index: 0),
      NavItem(label: 'Véhicules',       icon: Icons.directions_car_rounded,   index: 1),
      NavItem(label: 'Pannes',          icon: Icons.warning_amber_rounded,    index: 2),
      NavItem(label: 'Atelier',         icon: Icons.build_rounded,            index: 3),
      NavItem(label: 'Depenses',       icon: Icons.local_gas_station_rounded, index: 4),
      NavItem(label: 'Chauffeurs',      icon: Icons.badge_rounded,            index: 5),
      NavItem(label: 'Matériels',       icon: Icons.inventory_2_rounded,      index: 6),
      NavItem(label: 'Fournisseurs',    icon: Icons.store_rounded,            index: 7),
      NavItem(label: 'Utilisateurs',    icon: Icons.people_alt_rounded,       index: 8),
    ];

    if (role == null) return [allItems[0]];

    return allItems.where((item) {
      switch (role) {
        case UserRole.ADMIN:
          return [0, 1, 5, 6, 7, 8].contains(item.index);
        case UserRole.DIRECTEUR:
          return [0, 1, 4, 5, 8].contains(item.index);
        case UserRole.CHEF_ATELIER:
          return [0, 1, 2, 3, 4, 6, 7].contains(item.index);
        case UserRole.TECHNICIEN:
          return [0, 2, 3, 6].contains(item.index);
        case UserRole.CHAUFFEUR:
          return [0, 1, 2, 4].contains(item.index);
      }
    }).toList();
  }
}
