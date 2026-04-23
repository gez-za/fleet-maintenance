// ============================================================
// AutoPark IUC — Onglet d'accueil (Résumé des activités)
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'map_placeholder.dart';
import 'performance_line_chart.dart';
import 'placeholder_tabs.dart'; // Pour StatusDonutChart s'il est là ou ailleurs

// Note: StatusDonutChart a été déplacé dans map_placeholder.dart ou dashboard_widgets.dart 
// dans les versions précédentes. Vérifions où il est.
// D'après mes lectures, il est dans status_donut_chart.dart ou placeholder_tabs.dart (erroné).
// Je vais l'importer de status_donut_chart.dart.

import 'status_donut_chart.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: AppDimensions.space24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const PerformanceLineChart(),
                    const SizedBox(height: AppDimensions.space24),
                    _buildChartsRow(),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space24),
              const Expanded(
                flex: 1,
                child: Column(
                  children: [
                    MapPlaceholder(),
                    SizedBox(height: AppDimensions.space24),
                    _RemindersSection(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Véhicules Disponibles',
            value: '116',
            subValue: '- 1',
            icon: Icons.directions_car_rounded,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Nouvelles Réservations',
            value: '28',
            icon: Icons.calendar_month_rounded,
            color: AppColors.primaryMid,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Pannes Signalées',
            value: '5',
            icon: Icons.warning_amber_rounded,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return Row(
      children: [
        Expanded(
          child: StatusDonutChart(
            title: 'Statut des Véhicules',
            centerText: '52',
            data: [
              StatusData(label: 'Disponible', value: 30, count: 30, percentage: 57.7, color: AppColors.available),
              StatusData(label: 'En Mission', value: 12, count: 12, percentage: 23.1, color: AppColors.inMission),
              StatusData(label: 'En Panne', value: 10, count: 10, percentage: 19.2, color: AppColors.unavailable),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatusDonutChart(
            title: 'Ordres de Travail',
            centerText: '72',
            data: [
              StatusData(label: 'Nouveau', value: 12, count: 12, percentage: 16.7, color: AppColors.primaryLight),
              StatusData(label: 'En Cours', value: 40, count: 40, percentage: 55.6, color: AppColors.primaryMid),
              StatusData(label: 'Terminé', value: 20, count: 20, percentage: 27.8, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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
                Row(
                  children: [
                    Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    if (subValue != null) ...[
                      const SizedBox(width: 8),
                      Text(subValue!, style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemindersSection extends StatelessWidget {
  const _RemindersSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rappels & Alertes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildItem(context, 'Assurance à renouveler', 'Véhicule LT-123-AA', Icons.security_rounded, AppColors.danger),
          _buildItem(context, 'Maintenance préventive', 'Dans 2 jours', Icons.build_rounded, AppColors.warning),
          _buildItem(context, 'Nouveau message chauffeur', 'Il y a 10 min', Icons.chat_bubble_rounded, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, String sub, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
