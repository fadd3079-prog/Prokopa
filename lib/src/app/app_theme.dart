import 'package:flutter/material.dart';
import 'package:prokopa/src/core/constants/brand_constants.dart';

abstract final class ProkopaPalette {
  static const brand = Color(0xFF3949AB);

  static const success = Color(0xFF2E7D32);
  static const successLight = Color(0xFFE8F5E9);
  static const successDark = Color(0xFF1B5E20);

  static const momentum = Color(0xFFEF6C00);
  static const momentumLight = Color(0xFFFFF3E0);
  static const momentumDark = Color(0xFFE65100);

  static const reflection = Color(0xFF7B1FA2);
  static const reflectionLight = Color(0xFFF3E5F5);

  static const rest = Color(0xFF5C6BC0);
  static const restLight = Color(0xFFE8EAF6);

  static const attention = Color(0xFFF9A825);
  static const attentionLight = Color(0xFFFFF8E1);

  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecondary = Color(0xFF5F6368);
  static const textMuted = Color(0xFF9AA0A6);

  static const backgroundLight = Color(0xFFF5F6FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE8EBF0);

  static const backgroundDark = Color(0xFF09090B);
  static const surfaceDark = Color(0xFF18181B);
  static const borderDark = Color(0xFF2B2B31);
  static const textPrimaryDark = Color(0xFFF4F4F5);
  static const textSecondaryDark = Color(0xFFA1A1AA);
}

abstract final class ProkopaSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 48.0;

  static const screenPadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const cardPadding = EdgeInsets.all(20.0);
}

abstract final class ProkopaRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 22.0;

  static final smBorder = BorderRadius.circular(sm);
  static final mdBorder = BorderRadius.circular(md);
  static final lgBorder = BorderRadius.circular(lg);
  static final xlBorder = BorderRadius.circular(xl);
}

abstract final class ProkopaAnimation {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 400);
  static const curve = Curves.easeInOut;
}

abstract final class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrandConstants.primaryColor,
      primary: ProkopaPalette.brand,
      surface: ProkopaPalette.surfaceLight,
      surfaceContainerHighest: ProkopaPalette.borderLight,
      surfaceContainerLow: ProkopaPalette.backgroundLight,
      onSurface: ProkopaPalette.textPrimary,
      onSurfaceVariant: ProkopaPalette.textSecondary,
      outline: ProkopaPalette.textMuted,
      outlineVariant: ProkopaPalette.borderLight,
    ),
    scaffoldBackgroundColor: ProkopaPalette.backgroundLight,
    useMaterial3: true,
    textTheme: _textTheme(ProkopaPalette.textPrimary),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: ProkopaPalette.surfaceLight,
      surfaceTintColor: Colors.transparent,
      indicatorColor: ProkopaPalette.brand.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? ProkopaPalette.brand : ProkopaPalette.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? ProkopaPalette.brand : ProkopaPalette.textSecondary,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: ProkopaRadius.mdBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: ProkopaRadius.mdBorder),
        side: const BorderSide(color: ProkopaPalette.borderLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ProkopaPalette.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: ProkopaRadius.mdBorder,
        borderSide: const BorderSide(color: ProkopaPalette.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: ProkopaRadius.mdBorder,
        borderSide: const BorderSide(color: ProkopaPalette.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: ProkopaRadius.mdBorder,
        borderSide: const BorderSide(color: ProkopaPalette.brand, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: ProkopaPalette.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: ProkopaRadius.lgBorder,
        side: const BorderSide(color: ProkopaPalette.borderLight),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: ProkopaPalette.borderLight,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ProkopaPalette.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  static final dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrandConstants.primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF8C9EFF),
      surface: ProkopaPalette.surfaceDark,
      surfaceContainerHighest: const Color(0xFF27272A),
      surfaceContainerLow: ProkopaPalette.backgroundDark,
      onSurface: ProkopaPalette.textPrimaryDark,
      onSurfaceVariant: ProkopaPalette.textSecondaryDark,
      outline: const Color(0xFF71717A),
      outlineVariant: ProkopaPalette.borderDark,
    ),
    scaffoldBackgroundColor: ProkopaPalette.backgroundDark,
    useMaterial3: true,
    textTheme: _textTheme(ProkopaPalette.textPrimaryDark),
    navigationBarTheme: NavigationBarThemeData(
      height: 80,
      backgroundColor: const Color(0xFF111113),
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFF8C9EFF).withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected
              ? const Color(0xFF8C9EFF)
              : ProkopaPalette.textSecondaryDark,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected
              ? const Color(0xFF8C9EFF)
              : ProkopaPalette.textSecondaryDark,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: ProkopaRadius.mdBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: ProkopaRadius.mdBorder),
        side: const BorderSide(color: ProkopaPalette.borderDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF202024),
      border: OutlineInputBorder(
        borderRadius: ProkopaRadius.mdBorder,
        borderSide: const BorderSide(color: ProkopaPalette.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: ProkopaRadius.mdBorder,
        borderSide: const BorderSide(color: ProkopaPalette.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: ProkopaRadius.mdBorder,
        borderSide: const BorderSide(color: Color(0xFF8C9EFF), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: ProkopaPalette.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: ProkopaRadius.xlBorder,
        side: const BorderSide(color: ProkopaPalette.borderDark),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: ProkopaPalette.borderDark,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ProkopaPalette.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  static TextTheme _textTheme(Color primary) => TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: primary,
      height: 1.2,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: primary,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: primary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: primary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: primary.withValues(alpha: 0.7),
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: primary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: primary.withValues(alpha: 0.6),
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: primary.withValues(alpha: 0.5),
      letterSpacing: 0.5,
    ),
  );
}
