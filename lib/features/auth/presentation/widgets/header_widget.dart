import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';


/// Widget header de la page de connexion.
/// Affiche un fond dégradé en forme de vague avec une illustration SVG/image,
/// un titre et un sous-titre centrés.
class HeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? illustration;
  final double height;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.illustration,
    this.height = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      width: double.infinity,
      child: Stack(
        children: [
          // ── Fond dégradé avec vague ──────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _WavePainter(),
            ),
          ),

          // ── Contenu centré ───────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingHorizontal,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimensions.space16),

                  // Illustration (icône par défaut si non fournie)
                  _buildIllustration(),

                  const SizedBox(height: AppDimensions.space12),

                  // Titre
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color:      AppColors.white,
                      fontSize:   22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      height:     1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Sous-titre
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:      AppColors.white.withOpacity(0.85),
                      fontSize:   13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    if (illustration != null) {
      return illustration!;
    }
    // Illustration par défaut : icône voiture dans cercle blanc semi-transparent
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const _CarIllustration(),
    );
  }
}

// ── Illustration SVG inline (voiture + bus scolaire) ──────
class _CarIllustration extends StatelessWidget {
  const _CarIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Bus scolaire (gauche, plus petit)
        Positioned(
          left: 6,
          bottom: 12,
          child: Icon(
            Icons.directions_bus_rounded,
            size: 24,
            color: Colors.amber.shade300,
          ),
        ),
        // Véhicule principal (centre)
        const Positioned(
          right: 4,
          bottom: 14,
          child: Icon(
            Icons.directions_car_filled_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
        // Technicien (centre haut)
        Positioned(
          top: 8,
          child: Icon(
            Icons.engineering_rounded,
            size: 30,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        // Pin de localisation
        Positioned(
          top: 6,
          left: 10,
          child: Icon(
            Icons.location_on_rounded,
            size: 14,
            color: Colors.red.shade300,
          ),
        ),
      ],
    );
  }
}

// ── Peintre de la vague en bas du header ──────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fond dégradé vert
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A6B3A),
          Color(0xFF2D8653),
          Color(0xFF3DA06A),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Rectangle principal avec coins arrondis en bas
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, size.height),
        bottomLeft:  const Radius.circular(AppDimensions.radiusXL),
        bottomRight: const Radius.circular(AppDimensions.radiusXL),
      ),
      gradientPaint,
    );

    // Vague décorative en bas
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePaint.color = Colors.white.withOpacity(0.06);
    wavePath.moveTo(0, size.height * 0.75);
    wavePath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.60,
      size.width * 0.50, size.height * 0.75,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.75, size.height * 0.90,
      size.width,        size.height * 0.75,
    );
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);

    // Cercles décoratifs
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      60,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.10, size.height * 0.80),
      40,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}