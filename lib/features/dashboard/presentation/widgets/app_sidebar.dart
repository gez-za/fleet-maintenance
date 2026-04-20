import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onClose;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AutoPark',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onClose != null) ...[
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildMenuItem(0, Icons.dashboard_rounded, 'Tableau de bord'),
          _buildMenuItem(1, Icons.directions_car_rounded, 'Véhicules'),
          _buildMenuItem(2, Icons.warning_amber_rounded, 'Pannes'),
          _buildMenuItem(3, Icons.build_rounded, 'Atelier'),
          _buildMenuItem(4, Icons.local_gas_station_rounded, 'Carburant'),
          _buildMenuItem(5, Icons.badge_rounded, 'Chauffeurs'),
          _buildMenuItem(6, Icons.inventory_2_rounded, 'Matériels'),
          _buildMenuItem(7, Icons.store_rounded, 'Fournisseurs'),
          const Spacer(),
          _buildMenuItem(-1, Icons.settings_rounded, 'Paramètres'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isActive = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: ListTile(
        onTap: () => onSelect(index),
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.sidebarText,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
