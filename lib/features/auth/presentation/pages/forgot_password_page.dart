import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../providers/auth_notifier.dart';
import '../validators/app_validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/header_widget.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  static const String routeName = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).forgotPassword(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _isSuccess = true);
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
              title: 'Mot de passe oublié',
              subtitle: 'Récupérez l\'accès à votre compte',
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingHorizontal),
              child: _isSuccess ? _buildSuccessState() : _buildForm(authState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Entrez votre adresse email pour recevoir un code de réinitialisation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'Email',
            hintText: 'votre@email.com',
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: AppValidators.validateEmail,
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
            text: 'Envoyer le code',
            onPressed: _handleSubmit,
            isLoading: authState.isLoading,
            prefixIcon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'Email envoyé !',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Si un compte existe pour cet email, vous recevrez un code de réinitialisation.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          text: 'Saisir le code',
          onPressed: () => Navigator.pushReplacementNamed(
            context, 
            '/reset-password',
            arguments: _emailController.text.trim(),
          ),
          prefixIcon: Icons.lock_reset_rounded,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Retour à la connexion'),
        ),
      ],
    );
  }
}
