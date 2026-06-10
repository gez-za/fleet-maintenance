import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../providers/auth_notifier.dart';
import '../validators/app_validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/header_widget.dart';
import '../widgets/primary_button.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  static const String routeName = '/reset-password';

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _email ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur : Email manquant. Veuillez recommencer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).resetPassword(
      email: _email!,
      token: _tokenController.text.trim(),
      newPassword: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe réinitialisé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderWidget(
              title: 'Réinitialisation',
              subtitle: 'Définissez votre nouveau mot de passe',
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingHorizontal),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    if (_email != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Réinitialisation pour : $_email',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    CustomTextField(
                      label: 'Code de réinitialisation',
                      hintText: 'Entrez le code reçu par email',
                      prefixIcon: Icons.vpn_key_outlined,
                      controller: _tokenController,
                      validator: (v) => v!.isEmpty ? 'Le code est requis' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Nouveau mot de passe',
                      hintText: 'Min. 6 car., 1 Maj., 1 Chiffre',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: AppValidators.validatePassword,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Confirmer le mot de passe',
                      hintText: 'Répétez le mot de passe',
                      prefixIcon: Icons.lock_reset_outlined,
                      controller: _confirmPasswordController,
                      isPassword: true,
                      validator: (value) => AppValidators.validateConfirmPassword(value, _passwordController.text),
                    ),
                    const SizedBox(height: 32),
                    if (authState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          authState.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    PrimaryButton(
                      text: 'Réinitialiser',
                      onPressed: _handleSubmit,
                      isLoading: authState.isLoading,
                      prefixIcon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
