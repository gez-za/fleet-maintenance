// ============================================================
// AutoPark IUC — Barre supérieure du dashboard
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../core/widgets/user_avatar.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String       pageTitle;
  final VoidCallback onMenuTap;

  const AppTopBar({super.key, required this.pageTitle, required this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).user;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SafeArea(
      child: Container(
        height:  64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color:  AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          // Bouton ☰ uniquement sur mobile
          if (isMobile) ...[
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              tooltip: 'Menu',
            ),
            const SizedBox(width: 4),
          ],

          Text(pageTitle, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),

          // Recherche masquée sur mobile
          if (!isMobile) ...[
            _SearchBar(),
            const SizedBox(width: 16),
          ],

          if (user != null) ...[
            _NotificationBell(),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/profile'),
              child: UserAvatar(user: user, radius: 18),
            ),
          ],
        ]),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:  220,
      height: 36,
      decoration: BoxDecoration(
        color:        AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border:       const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText:       'Rechercher...',
          hintStyle:      TextStyle(fontSize: 13, color: AppColors.textHint),
          prefixIcon:     Icon(Icons.search_rounded, size: 18, color: AppColors.textHint),
          border:         InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.notifications_outlined,
          color: AppColors.textSecondary, size: 22,
        ),
      ),
      Positioned(
        right: 8, top: 8,
        child: Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(
            color: AppColors.unavailable, shape: BoxShape.circle,
          ),
        ),
      ),
    ]);
  }
}
