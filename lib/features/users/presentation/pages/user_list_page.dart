import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/user_notifier.dart';
import 'user_form_page.dart';

class UserListPage extends ConsumerWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userState.error != null
              ? Center(child: Text('Erreur: ${userState.error}'))
              : RefreshIndicator(
                  onRefresh: () => ref.read(userListProvider.notifier).loadUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingHorizontal),
                    itemCount: userState.users.length,
                    itemBuilder: (context, index) {
                      final user = userState.users[index];
                      return _UserCard(user: user);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserFormPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: UserAvatar(user: user, radius: 24),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.role.label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserFormPage(user: user)),
              );
            } else if (value == 'delete') {
              _confirmDelete(context, ref);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined, size: 20),
                title: Text('Modifier'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text('Voulez-vous vraiment supprimer ${user.displayName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userListProvider.notifier).deleteUser(user.uuid);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
