// ============================================================
// AutoPark IUC — Onglets placeholder (réadaptés)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class PlaceholderTab extends ConsumerWidget {
  final String   title;
  final IconData icon;
  final Color    color;

  const PlaceholderTab({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 8),
          const Text('Module en cours de développement',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          if (isAdmin)
            ElevatedButton.icon(
              onPressed: () {},
              icon:  const Icon(Icons.add_rounded),
              label: Text('Ajouter un(e) $title'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class VehiclesTab extends StatelessWidget {
  const VehiclesTab({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderTab(
    title: 'Véhicule',
    icon:  Icons.directions_car_rounded,
    color: AppColors.primary,
  );
}

class PannesTab extends StatelessWidget {
  const PannesTab({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderTab(
    title: 'Panne',
    icon:  Icons.warning_amber_rounded,
    color: AppColors.danger,
  );
}

class AtelierTab extends StatelessWidget {
  const AtelierTab({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderTab(
    title: 'Ordre de travail',
    icon:  Icons.build_rounded,
    color: AppColors.textSecondary,
  );
}

class DepensesTab extends StatelessWidget {
  const DepensesTab({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderTab(
    title: 'Bon de depenses',
    icon:  Icons.local_gas_station_rounded,
    color: AppColors.primaryMid,
  );
}

class ChauffeursTab extends StatelessWidget {
  const ChauffeursTab({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderTab(
    title: 'Chauffeur',
    icon:  Icons.badge_rounded,
    color: AppColors.primary,
  );
}

class MaterielsTab extends StatelessWidget {
  const MaterielsTab({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderTab(
    title: 'Matériel',
    icon:  Icons.inventory_2_rounded,
    color: AppColors.textSecondary,
  );
}

class FournisseursTab extends StatelessWidget {
  const FournisseursTab({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderTab(
    title: 'Fournisseur',
    icon:  Icons.store_rounded,
    color: AppColors.primaryLight,
  );
}
