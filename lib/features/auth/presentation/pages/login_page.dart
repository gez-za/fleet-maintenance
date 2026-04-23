/// ============================================================
/// AutoPark IUC - Page de Connexion
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/auth/login/app_strings.dart';

import '../providers/auth_notifier.dart';
import '../validators/app_validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/header_widget.dart';
import '../widgets/primary_button.dart';
// import '../widgets/social_button.dart'; // Supprimé car inutilisé

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {

  // ── Controllers ───────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ── States ────────────────────────────────────────────
  bool _isLoading = false;
  String? _globalError;

  // ── Animations ────────────────────────────────────────
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

    _slideAnimations = List.generate(5, (i) {
      final start = (i * 0.12).clamp(0.0, 0.7);
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

    _fadeAnimations = List.generate(5, (i) {
      final start = (i * 0.12).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── LOGIN LOGIC (RIVERPOD) ───────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _globalError = null;
    });

    try {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      final authState = ref.read(authProvider);

      if (!mounted) return;

      if (authState.user != null) {
        _showSuccessSnackbar();
        if (authState.user?.profile == null) {
          Navigator.of(context).pushReplacementNamed('/profile-setup');
        } else {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } else if (authState.error != null) {
        setState(() {
          _globalError = authState.error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _globalError = AppStrings.errorLoginFailed;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ── UI ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── HEADER ────────────────────────────────
              _buildAnimated(
                index: 0,
                child: HeaderWidget(
                  title: AppStrings.loginTitle,
                  subtitle: AppStrings.loginSubtitle,
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

                      // EMAIL
                      _buildAnimated(
                        index: 1,
                        child: CustomTextField(
                          label: AppStrings.email,
                          hintText: AppStrings.emailHint,
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                          validator: AppValidators.validateEmail,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space20),

                      // PASSWORD
                      _buildAnimated(
                        index: 2,
                        child: CustomTextField(
                          label: AppStrings.password,
                          hintText: AppStrings.passwordHint,
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _passwordController,
                          isPassword: true,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          validator: AppValidators.validatePassword,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space24),

                      // ERROR GLOBAL
                      if (_globalError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
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

                      const SizedBox(height: AppDimensions.space24),

                      // BUTTON LOGIN
                      _buildAnimated(
                        index: 3,
                        child: PrimaryButton(
                          text: AppStrings.loginButton,
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          prefixIcon: Icons.login_rounded,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space16),

                      // REGISTER LINK
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: "Pas encore de compte ? "),
                              TextSpan(
                                text: AppStrings.loginCreate,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .pushNamed('/register');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // ── ANIMATION WRAPPER ────────────────────────────────
  Widget _buildAnimated({required int index, required Widget child}) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }

  // ── SNACKBAR SUCCESS ────────────────────────────────
  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion réussie !'),
        backgroundColor: Colors.green,
      ),
    );
  }
}