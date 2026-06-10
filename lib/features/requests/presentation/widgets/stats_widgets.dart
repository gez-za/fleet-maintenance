import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RequestStatsDashboard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const RequestStatsDashboard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tableau de Bord Dépenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        isMobile ? _buildVertical(context) : _buildHorizontal(context),
      ],
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Total Dépenses', value: '${stats['total'] ?? 0} XAF', icon: Icons.account_balance_wallet, color: AppColors.primary)),
        const SizedBox(width: 16),
        Expanded(child: _StatTile(label: 'Carburant', value: '${stats['carburant'] ?? 0} XAF', icon: Icons.local_gas_station, color: Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _StatTile(label: 'Pièces', value: '${stats['pieces'] ?? 0} XAF', icon: Icons.settings, color: Colors.blue)),
      ],
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Column(
      children: [
        _StatTile(label: 'Total Dépenses', value: '${stats['total'] ?? 0} XAF', icon: Icons.account_balance_wallet, color: AppColors.primary),
        const SizedBox(height: 12),
        _StatTile(label: 'Carburant', value: '${stats['carburant'] ?? 0} XAF', icon: Icons.local_gas_station, color: Colors.orange),
        const SizedBox(height: 12),
        _StatTile(label: 'Pièces', value: '${stats['pieces'] ?? 0} XAF', icon: Icons.settings, color: Colors.blue),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
