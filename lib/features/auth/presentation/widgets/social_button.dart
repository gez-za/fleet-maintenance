import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Bouton de connexion sociale (Facebook, Google, etc.)
///
/// Deux variantes :
/// - [SocialButton] : icône seule dans un cercle
/// - [SocialButtonWide] : icône + label en pleine largeur
class SocialButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final String tooltip;
  final double size;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.white,
    this.borderColor     = AppColors.border,
    this.tooltip         = '',
    this.size            = AppDimensions.socialButtonSize,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTapDown:   (_) => _controller.forward(),
          onTapUp:     (_) => _controller.reverse(),
          onTapCancel: ()  => _controller.reverse(),
          onTap:       widget.onPressed,
          child: Container(
            width:  widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color:        widget.backgroundColor,
              shape:        BoxShape.circle,
              border:       Border.all(color: widget.borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color:       Colors.black.withOpacity(0.08),
                  blurRadius:  10,
                  spreadRadius: 0,
                  offset:      const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: widget.icon),
          ),
        ),
      ),
    );
  }
}

/// Variante large avec icône + label
class SocialButtonWide extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const SocialButtonWide({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.white,
    this.borderColor     = AppColors.border,
    this.textColor       = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      width:  double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppDimensions.space12),
            Text(
              label,
              style: TextStyle(
                color:      textColor,
                fontSize:   AppDimensions.fontBase,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icônes SVG inline des réseaux sociaux ──────────────────

/// Icône Facebook inline (pas de dépendance externe)
class FacebookIcon extends StatelessWidget {
  final double size;
  const FacebookIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  size,
      height: size,
      child: CustomPaint(
        painter: _FacebookPainter(),
      ),
    );
  }
}

class _FacebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1877F2);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'f',
        style: TextStyle(
          color:      Colors.white,
          fontSize:   20,
          fontWeight: FontWeight.w900,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2 + 1,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Icône Google inline
class GoogleIcon extends StatelessWidget {
  final double size;
  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Quart rouge
    _drawArc(canvas, center, radius, -10, 95,  const Color(0xFFEA4335));
    // Quart vert
    _drawArc(canvas, center, radius,  95, 95,  const Color(0xFF34A853));
    // Quart bleu
    _drawArc(canvas, center, radius, 190, 85,  const Color(0xFF4285F4));
    // Quart jaune
    _drawArc(canvas, center, radius, 275, 85,  const Color(0xFFFBBC05));

    // Centre blanc
    canvas.drawCircle(center, radius * 0.60, Paint()..color = Colors.white);

    // Barre bleue
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.20,
          radius * 0.85, radius * 0.40),
      barPaint,
    );
  }

  void _drawArc(Canvas c, Offset center, double r, double startDeg,
      double sweepDeg, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final rect  = Rect.fromCircle(center: center, radius: r);
    final path  = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
          rect,
          startDeg  * (3.14159 / 180),
          sweepDeg  * (3.14159 / 180),
          false)
      ..close();
    c.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}