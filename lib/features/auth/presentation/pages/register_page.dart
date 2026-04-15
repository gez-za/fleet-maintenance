/// ============================================================
/// AutoPark IUC - Page d'Inscription
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/auth/register/app_strings.dart';

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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // ── States ──────────────────────────────────
  bool _isLoading = false;
  String? _globalError;

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

    _slideAnimations = List.generate(6, (i) {
      final start = (i * 0.1).clamp(0.0, 0.7);
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

    _fadeAnimations = List.generate(6, (i) {
      final start = (i * 0.1).clamp(0.0, 0.7);
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
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
      final success = await ref
          .read(authNotifierProvider.notifier)
          .register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        final authState = ref.read(authNotifierProvider);
        setState(() {
          _globalError = authState.errorMessage;
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
    final authState = ref.watch(authNotifierProvider);

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

                      const SizedBox(height: AppDimensions.space32),

                      _buildAnimated(
                        index: 1,
                        child: CustomTextField(
                          label: AppStrings.name,
                          hintText: AppStrings.nameHint,
                          prefixIcon: Icons.person_outline,
                          controller: _nameController,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _emailFocus.requestFocus(),
                          validator: AppValidators.validateName,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space20),

                      _buildAnimated(
                        index: 2,
                        child: CustomTextField(
                          label: AppStrings.email,
                          hintText: AppStrings.emailHint,
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                          validator: AppValidators.validateEmail,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space20),

                      _buildAnimated(
                        index: 3,
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

                      const SizedBox(height: AppDimensions.space20),

                      _buildAnimated(
                        index: 4,
                        child: CustomTextField(
                          label: AppStrings.confirmPassword,
                          hintText: AppStrings.passwordHint,
                          prefixIcon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          focusNode: _confirmPasswordFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleRegister(),
                          validator: AppValidators
                              .validateConfirmPassword(
                              _passwordController.text),
                        ),
                      ),

                      if (_globalError != null ||
                          authState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _globalError ?? authState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.space24),

                      _buildAnimated(
                        index: 5,
                        child: PrimaryButton(
                          text: AppStrings.registerButton,
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                          prefixIcon: Icons.person_add,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space20),

                      _buildLoginLink(),

                      const SizedBox(height: AppDimensions.space40),
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
          TextSpan(text: AppStrings.alreadyHaveAccount),
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