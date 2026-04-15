import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Thème Material 3 — AutoPark
/// Couleurs : Vert principal · Rouge danger · Gris neutre
class AppTheme {
  AppTheme._(); // Classe non instanciable

  // ── ColorScheme Material 3 ────────────────────────────
  static const ColorScheme _colorScheme = ColorScheme(
    brightness:        Brightness.light,
    primary:           AppColors.primary,
    onPrimary:         AppColors.white,
    primaryContainer:  AppColors.primarySurface,
    onPrimaryContainer:AppColors.primary,
    secondary:         AppColors.primaryMid,
    onSecondary:       AppColors.white,
    secondaryContainer:AppColors.primarySurface,
    onSecondaryContainer: AppColors.primaryMid,
    error:             AppColors.danger,
    onError:           AppColors.white,
    errorContainer:    AppColors.dangerLight,
    onErrorContainer:  AppColors.danger,
    surface:           AppColors.background,
    onSurface:         AppColors.textPrimary,
    onSurfaceVariant:  AppColors.textSecondary,
    outline:           AppColors.border,
    outlineVariant:    AppColors.divider,
  );

  // ── Thème clair (principal) ───────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3:    true,
    colorScheme:     _colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily:      'Poppins',

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor:  AppColors.primary,
      foregroundColor:  AppColors.white,
      elevation:        0,
      centerTitle:      false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color:      AppColors.white,
        fontSize:   AppDimensions.fontLG,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled:       true,
      fillColor:    AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical:   AppDimensions.space16,
      ),
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
      hintStyle: const TextStyle(
        color:      AppColors.textHint,
        fontSize:   AppDimensions.fontBase,
        fontFamily: 'Poppins',
      ),
      labelStyle: const TextStyle(
        color:      AppColors.textSecondary,
        fontSize:   AppDimensions.fontBase,
        fontFamily: 'Poppins',
      ),
      errorStyle: const TextStyle(
        color:    AppColors.danger,
        fontSize: AppDimensions.fontSM,
      ),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize:     const Size.fromHeight(AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        elevation:       AppDimensions.elevationMedium,
        textStyle: const TextStyle(
          fontSize:   AppDimensions.fontMD,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize:   AppDimensions.fontBase,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation:  AppDimensions.elevationLow,
      color:      AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      margin: EdgeInsets.zero,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color:     AppColors.divider,
      thickness: 1.0,
      space:     1.0,
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: 'Poppins'),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary, fontFamily: 'Poppins'),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textHint, fontFamily: 'Poppins'),
    ),
  );
}