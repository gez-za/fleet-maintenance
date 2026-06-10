// ============================================================
// AutoPark IUC - Page d'Inscription
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/auth/register/app_strings.dart';
import '../../../../core/models/user.dart';

import '../providers/auth_notifier.dart';
import '../validators/app_validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/header_widget.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  static const String routeName = '/register';

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {

  // ── Controllers ─────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nomFocus = FocusNode();
  final _prenomFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // ── States ──────────────────────────────────
  bool _isLoading = false;
  String? _globalError;
  UserRole _selectedRole = UserRole.CHAUFFEUR;

  // ── Animations ─────────────────────────────
  late AnimationController _animController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    const totalAnimatedWidgets = 9;
    _slideAnimations = List.generate(totalAnimatedWidgets, (i) {
      final start = (i * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _fadeAnimations = List.generate(totalAnimatedWidgets, (i) {
      final start = (i * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _animController.forward(),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nomFocus.dispose();
    _prenomFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _animController.dispose();
    super.dispose();
  }

  // ── REGISTER LOGIC (RIVERPOD) ─────────────────
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _globalError = null;
    });

    try {
      await ref.read(authProvider.notifier).register(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            role: _selectedRole,
            telephone: _phoneController.text.trim(),
          );

      final authState = ref.read(authProvider);

      if (!mounted) return;

      if (authState.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      } else {
        setState(() {
          _globalError = authState.error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _globalError = AppStrings.errorRegisterFailed;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ── UI ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [

              _buildAnimated(
                index: 0,
                child: HeaderWidget(
                  title: AppStrings.registerTitle,
                  subtitle: AppStrings.registerSubtitle,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingHorizontal,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      const SizedBox(height: 16),

                      _buildAnimated(
                        index: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: AppStrings.nom,
                                hintText: AppStrings.nomHint,
                                prefixIcon: Icons.person_outline,
                                controller: _nomController,
                                focusNode: _nomFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => _prenomFocus.requestFocus(),
                                validator: AppValidators.validateName,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: AppStrings.prenom,
                                hintText: AppStrings.prenomHint,
                                prefixIcon: Icons.person_outline,
                                controller: _prenomController,
                                focusNode: _prenomFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => _emailFocus.requestFocus(),
                                validator: AppValidators.validateName,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildAnimated(
                        index: 2,
                        child: CustomTextField(
                          label: AppStrings.email,
                          hintText: AppStrings.emailHint,
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _phoneFocus.requestFocus(),
                          validator: AppValidators.validateEmail,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildAnimated(
                        index: 3,
                        child: CustomTextField(
                          label: AppStrings.telephone,
                          hintText: AppStrings.telephoneHint,
                          prefixIcon: Icons.phone_outlined,
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildAnimated(
                        index: 4,
                        child: _buildRoleDropdown(),
                      ),

                      const SizedBox(height: 12),

                      _buildAnimated(
                        index: 5,
                        child: CustomTextField(
                          label: AppStrings.password,
                          hintText: AppStrings.passwordHint,
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _passwordController,
                          isPassword: true,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              _confirmPasswordFocus.requestFocus(),
                          validator: AppValidators.validatePassword,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildAnimated(
                        index: 6,
                        child: CustomTextField(
                          label: AppStrings.confirmPassword,
                          hintText: AppStrings.passwordHint,
                          prefixIcon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          focusNode: _confirmPasswordFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleRegister(),
                          validator: (value) => AppValidators
                              .validateConfirmPassword(
                              value, _passwordController.text),
                        ),
                      ),

                      if (_globalError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _globalError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.space24),

                      _buildAnimated(
                        index: 7,
                        child: PrimaryButton(
                          text: AppStrings.registerButton,
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                          prefixIcon: Icons.person_add,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildLoginLink(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
          "Choisissez votre rôle",
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
              items: [UserRole.CHAUFFEUR, UserRole.TECHNICIEN, UserRole.CHEF_ATELIER]
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

  // ── ANIMATION WRAPPER ───────────────────────
  Widget _buildAnimated({required int index, required Widget child}) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }

  // ── LOGIN LINK ──────────────────────────────
  Widget _buildLoginLink() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Poppins',
        ),
        children: [
          const TextSpan(text: AppStrings.alreadyHaveAccount),
          TextSpan(
            text: AppStrings.login,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacementNamed(context, '/login');
              },
          ),
        ],
      ),
    );
  }
}