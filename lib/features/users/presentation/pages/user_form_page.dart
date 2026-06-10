import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../providers/user_notifier.dart';

class UserFormPage extends ConsumerStatefulWidget {
  final User? user;

  const UserFormPage({super.key, this.user});

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _matriculeController;
  late final TextEditingController _specialiteController;
  late final TextEditingController _permisController;
  late UserRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.user?.profile?.nom ?? '');
    _prenomController = TextEditingController(text: widget.user?.profile?.prenom ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _matriculeController = TextEditingController(text: widget.user?.roleInfo?['matricule'] ?? '');
    _specialiteController = TextEditingController(text: widget.user?.roleInfo?['specialite'] ?? '');
    _permisController = TextEditingController(text: widget.user?.roleInfo?['numero_permis'] ?? '');
    _selectedRole = widget.user?.role ?? UserRole.CHAUFFEUR;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _matriculeController.dispose();
    _specialiteController.dispose();
    _permisController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(userServiceProvider);
      final userData = {
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole.name,
      };

      if (_selectedRole == UserRole.TECHNICIEN) {
        userData['matricule'] = _matriculeController.text.trim();
        userData['specialite'] = _specialiteController.text.trim();
      } else if (_selectedRole == UserRole.CHAUFFEUR) {
        userData['numero_permis'] = _permisController.text.trim();
      }

      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }

      if (widget.user != null) {
        await service.updateUser(widget.user!.uuid, userData);
      } else {
        await service.createUser(userData);
      }

      if (mounted) {
        ref.read(userListProvider.notifier).loadUsers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user != null ? 'Utilisateur modifié' : 'Utilisateur ajouté'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user != null ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Nom',
                hintText: 'Nom de l\'utilisateur',
                prefixIcon: Icons.person_outline,
                controller: _nomController,
                validator: (v) => v!.isEmpty ? 'Le nom est requis' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Prénom',
                hintText: 'Prénom de l\'utilisateur',
                prefixIcon: Icons.person_outline,
                controller: _prenomController,
                validator: (v) => v!.isEmpty ? 'Le prénom est requis' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hintText: 'email@exemple.com',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'L\'email est requis' : null,
              ),
              const SizedBox(height: 16),
              if (widget.user == null)
                CustomTextField(
                  label: 'Mot de passe',
                  hintText: 'Mot de passe initial',
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  validator: (v) => v!.isEmpty ? 'Le mot de passe est requis' : null,
                ),
              const SizedBox(height: 16),
              _buildRoleDropdown(),
              const SizedBox(height: 16),
              if (_selectedRole == UserRole.TECHNICIEN) ...[
                CustomTextField(
                  label: 'Matricule',
                  hintText: 'Ex: TECH-001',
                  prefixIcon: Icons.badge_outlined,
                  controller: _matriculeController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Spécialité',
                  hintText: 'Ex: Mécanique',
                  prefixIcon: Icons.handyman_outlined,
                  controller: _specialiteController,
                ),
              ] else if (_selectedRole == UserRole.CHAUFFEUR) ...[
                CustomTextField(
                  label: 'Numéro de Permis',
                  hintText: 'Ex: PER-123456',
                  prefixIcon: Icons.credit_card_outlined,
                  controller: _permisController,
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Enregistrer',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rôle de l'utilisateur",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: _selectedRole,
              isExpanded: true,
              items: UserRole.values
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r.label),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
          ),
        ),
      ],
    );
  }
}
