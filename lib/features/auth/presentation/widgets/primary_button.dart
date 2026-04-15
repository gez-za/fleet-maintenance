import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';


/// Bouton principal avec dégradé vert, coins arrondis et états de chargement.
///
/// Usage :
/// ```dart
/// PrimaryButton(
///   text: 'Se Connecter',
///   onPressed: _handleLogin,
///   isLoading: _isLoading,
/// )
/// ```
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double borderRadius;
  final LinearGradient? gradient;
  final double height;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading    = false,
    this.isDisabled   = false,
    this.borderRadius = AppDimensions.radiusFull,
    this.gradient,
    this.height       = AppDimensions.buttonHeight,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _isInteractable =>
      !widget.isLoading && !widget.isDisabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown:   _isInteractable ? (_) => _pressController.forward() : null,
        onTapUp:     _isInteractable ? (_) => _pressController.reverse() : null,
        onTapCancel: _isInteractable ?  ()  => _pressController.reverse() : null,
        onTap:       _isInteractable ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height:   widget.height,
          width:    double.infinity,
          decoration: BoxDecoration(
            gradient: _isInteractable
                ? (widget.gradient ?? AppColors.primaryGradient)
                : const LinearGradient(
              colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isInteractable
                ? [
              BoxShadow(
                color:       AppColors.primary.withOpacity(0.35),
                blurRadius:  16,
                spreadRadius: 0,
                offset:      const Offset(0, 6),
              ),
            ]
                : [],
          ),
          child: Center(
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const SizedBox(
        width:  24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth:  2.5,
          valueColor:   AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: const TextStyle(
        color:       AppColors.white,
        fontSize:    AppDimensions.fontMD,
        fontWeight:  FontWeight.w700,
        fontFamily:  'Poppins',
        letterSpacing: 0.5,
      ),
    );

    if (widget.prefixIcon == null && widget.suffixIcon == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize:     MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null) ...[
          Icon(widget.prefixIcon, color: AppColors.white, size: 20),
          const SizedBox(width: AppDimensions.space8),
        ],
        textWidget,
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: AppDimensions.space8),
          Icon(widget.suffixIcon, color: AppColors.white, size: 20),
        ],
      ],
    );
  }
}

/// Bouton secondaire (contour vert, fond transparent)
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double borderRadius;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderRadius = AppDimensions.radiusFull,
    this.height       = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width:  double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side:  const BorderSide(color: AppColors.primary, width: 1.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize:   AppDimensions.fontMD,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}