import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';


/// Champ de saisie réutilisable — AutoPark
///
/// Supporte :
/// - Label au-dessus du champ
/// - Icône de préfixe
/// - Icône de suffixe (ex: afficher/masquer mdp)
/// - Mode mot de passe (obscureText)
/// - Validation intégrée
/// - Keyboard types multiples
/// - Formatters personnalisés
class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final int? maxLines;
  final int? maxLength;
  final Widget? suffixWidget; // Suffix personnalisé (remplace celui par défaut)
  final String? errorText;    // Erreur externe (depuis le parent)

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isPassword           = false,
    this.keyboardType         = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization   = TextCapitalization.none,
    this.enabled              = true,
    this.focusNode,
    this.textInputAction      = TextInputAction.next,
    this.maxLines             = 1,
    this.maxLength,
    this.suffixWidget,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused   = false;
  late FocusNode _focusNode;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize:   AppDimensions.fontBase,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: _isFocused ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),

        // ── Champ de saisie avec animation ──────────────
        ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            height: AppDimensions.inputHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: _isFocused
                  ? [
                BoxShadow(
                  color:       AppColors.primary.withOpacity(0.12),
                  blurRadius:  12,
                  spreadRadius: 0,
                  offset:      const Offset(0, 4),
                ),
              ]
                  : [
                BoxShadow(
                  color:       Colors.black.withOpacity(0.05),
                  blurRadius:  6,
                  spreadRadius: 0,
                  offset:      const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller:         widget.controller,
              focusNode:          _focusNode,
              obscureText:        widget.isPassword ? _obscureText : false,
              keyboardType:       widget.keyboardType,
              textInputAction:    widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              inputFormatters:    widget.inputFormatters,
              maxLines:           widget.maxLines,
              maxLength:          widget.maxLength,
              enabled:            widget.enabled,
              validator:          widget.validator,
              onChanged:          widget.onChanged,
              onFieldSubmitted:   widget.onSubmitted,
              style: const TextStyle(
                fontSize:   AppDimensions.fontBase,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color:      AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText:  widget.hintText,
                errorText: widget.errorText,

                // Icône préfixe
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                  ),
                  child: Icon(
                    widget.prefixIcon,
                    size:  AppDimensions.iconSize,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 52,
                  minHeight: AppDimensions.inputHeight,
                ),

                // Icône suffixe
                suffixIcon: widget.suffixWidget ??
                    (widget.isPassword ? _buildPasswordToggle() : null),

                // Override borders pour état d'erreur externe
                filled:    true,
                fillColor: widget.enabled ? AppColors.surface : AppColors.divider,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide:   const BorderSide(color: AppColors.border, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide:   const BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide:   const BorderSide(color: AppColors.primary, width: 2.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide:   const BorderSide(color: AppColors.danger, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide:   const BorderSide(color: AppColors.danger, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical:   AppDimensions.space16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordToggle() {
    return GestureDetector(
      onTap: () => setState(() => _obscureText = !_obscureText),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            key:   ValueKey(_obscureText),
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size:  AppDimensions.iconSize,
            color: _isFocused ? AppColors.primary : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}