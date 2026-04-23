import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/auth_notifier.dart';

class ProfileViewPage extends ConsumerWidget {
  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final profile = user.profile;
    final displayName = profile != null ? '${profile.prenom} ${profile.nom}'.trim() : user.name;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ── Carte Profil ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  UserAvatar(
                    user: user,
                    radius: 60,
                    showBorder: true,
                    borderColor: AppColors.primary.withOpacity(0.1),
                    borderWidth: 4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName.isEmpty ? 'Utilisateur' : displayName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1D2939)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.role.label,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 12),
                  // Badge rôle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(user.role.icon, size: 16, color: const Color(0xFF3570F4)),
                        const SizedBox(width: 8),
                        Text(
                          user.role.label,
                          style: const TextStyle(color: Color(0xFF3570F4), fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Informations Générales ────────────────────
            _buildSectionTitle('Informations Générales'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoTile(Icons.email_outlined, 'Email', user.email),
                  _buildDivider(),
                  _buildInfoTile(Icons.phone_outlined, 'Téléphone', profile?.telephone ?? 'Non renseigné'),
                  _buildDivider(),
                  _buildInfoTile(Icons.location_on_outlined, 'Adresse', profile?.adresse ?? 'Non renseigné'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Informations Spécifiques ──────────────────
            _buildSectionTitle('Informations Spécifiques'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (user.role == UserRole.TECHNICIEN) ...[
                    _buildSpecTile(Icons.build_outlined, 'Spécialité', user.roleInfo?['specialite'] ?? 'Mécanique', isTag: true),
                    _buildDivider(),
                  ],
                  _buildSpecTile(Icons.check_circle_outline, 'Statut', user.isActive ? 'Disponible' : 'Indisponible', isTag: true, tagColor: user.isActive ? const Color(0xFFE7F7EF) : const Color(0xFFFFEBEE), textColor: user.isActive ? const Color(0xFF0D9488) : Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Actions ──────────────────────────────────
            _buildSectionTitle('Actions'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildActionTile(Icons.edit_outlined, 'Modifier le profil', () {
                    Navigator.of(context).pushNamed('/profile-setup');
                  }),
                  _buildDivider(),
                  _buildActionTile(Icons.lock_outline, 'Changer le mot de passe', () {}),
                  _buildDivider(),
                  _buildActionTile(Icons.power_settings_new, 'Déconnexion', () {
                    _confirmLogout(context, ref);
                  }, isDestructive: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475467)),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF667085)),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2939)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF475467)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile(IconData icon, String label, String value, {bool isTag = false, Color? tagColor, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF667085)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2939)),
            ),
          ),
          if (isTag)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor ?? const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(color: textColor ?? const Color(0xFF3570F4), fontWeight: FontWeight.w600, fontSize: 13),
              ),
            )
          else
            Text(value, style: const TextStyle(color: Color(0xFF475467))),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF98A2B3)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFEBEE) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: isDestructive ? Colors.red : const Color(0xFF667085)),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : const Color(0xFF1D2939),
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF98A2B3)),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16);
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
