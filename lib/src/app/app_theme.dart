import 'package:flutter/material.dart';

abstract final class AppColors {
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo200 = Color(0xFFC7D2FE);
  static const indigo300 = Color(0xFFA5B4FC);
  static const indigo400 = Color(0xFF818CF8);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo700 = Color(0xFF4338CA);

  static const emerald50 = Color(0xFFECFDF5);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald300 = Color(0xFF6EE7B7);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald700 = Color(0xFF047857);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber200 = Color(0xFFFDE68A);
  static const amber500 = Color(0xFFF59E0B);
  static const amber700 = Color(0xFFB45309);
  static const purple50 = Color(0xFFFAF5FF);
  static const purple200 = Color(0xFFE9D5FF);
  static const purple500 = Color(0xFFA855F7);
  static const violet600 = Color(0xFF7C3AED);
  static const rose50 = Color(0xFFFFF1F2);
  static const rose600 = Color(0xFFE11D48);

  static const textPrimary = Color(0xFF18181B);
  static const textSecondary = Color(0xFF71717A);
  static const border = Color(0xFFE4E4E7);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8FAFC);
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF4F4F5);
  static const neutral200 = Color(0xFFE4E4E7);
  static const neutral400 = Color(0xFFA1A1AA);
  static const neutral600 = Color(0xFF52525B);
  static const neutral800 = Color(0xFF27272A);
  static const neutral900 = Color(0xFF18181B);
  static const neutral950 = Color(0xFF09090B);

  static const darkBackground = Color(0xFF09090B);
  static const darkSurface = Color(0xFF18181B);
  static const darkSurfaceRaised = Color(0xFF202024);
  static const darkBorder = Color(0xFF3F3F46);
  static const darkTextPrimary = Color(0xFFFAFAFA);
  static const darkTextSecondary = Color(0xFFD4D4D8);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;

  static const screenPadding = EdgeInsetsDirectional.symmetric(horizontal: 16);
  static const cardPadding = EdgeInsetsDirectional.all(20);
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;

  static final smBorder = BorderRadius.circular(sm);
  static final mdBorder = BorderRadius.circular(md);
  static final lgBorder = BorderRadius.circular(lg);
}

abstract final class AppMotion {
  static const press = Duration(milliseconds: 120);
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const progress = Duration(milliseconds: 600);
  static const ring = Duration(milliseconds: 1000);
  static const curve = Curves.easeOut;
}

abstract final class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: primary,
      height: 1.25,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: primary,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: primary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
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
      color: secondary,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: secondary,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: secondary,
      height: 1.3,
    ),
  );
}

abstract final class ProkopaPalette {
  static const brand = AppColors.indigo500;
  static const success = AppColors.emerald600;
  static const successLight = AppColors.emerald50;
  static const successDark = AppColors.emerald700;
  static const momentum = AppColors.amber700;
  static const momentumLight = AppColors.amber50;
  static const momentumDark = AppColors.amber700;
  static const reflection = AppColors.violet600;
  static const reflectionLight = AppColors.purple50;
  static const rest = AppColors.violet600;
  static const restLight = AppColors.purple50;
  static const attention = AppColors.amber500;
  static const attentionLight = AppColors.amber50;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textMuted = AppColors.neutral400;
  static const backgroundLight = AppColors.background;
  static const surfaceLight = AppColors.surface;
  static const borderLight = AppColors.border;
  static const backgroundDark = AppColors.darkBackground;
  static const surfaceDark = AppColors.darkSurface;
  static const borderDark = AppColors.darkBorder;
  static const textPrimaryDark = AppColors.darkTextPrimary;
  static const textSecondaryDark = AppColors.darkTextSecondary;
}

abstract final class ProkopaSpacing {
  static const xs = AppSpacing.xxs;
  static const sm = AppSpacing.xs;
  static const md = AppSpacing.sm;
  static const lg = AppSpacing.md;
  static const xl = AppSpacing.lg;
  static const xxl = AppSpacing.xl;
  static const xxxl = AppSpacing.xxl;
  static const huge = AppSpacing.huge;
  static const screenPadding = AppSpacing.screenPadding;
  static const cardPadding = AppSpacing.cardPadding;
}

abstract final class ProkopaRadius {
  static const sm = AppRadius.sm;
  static const md = AppRadius.md;
  static const lg = AppRadius.lg;
  static const xl = AppRadius.lg;
  static final smBorder = AppRadius.smBorder;
  static final mdBorder = AppRadius.mdBorder;
  static final lgBorder = AppRadius.lgBorder;
  static final xlBorder = AppRadius.lgBorder;
}

abstract final class ProkopaAnimation {
  static const fast = AppMotion.fast;
  static const normal = AppMotion.normal;
  static const slow = Duration(milliseconds: 400);
  static const curve = AppMotion.curve;
}

abstract final class AppTheme {
  static final light = _theme(
    brightness: Brightness.light,
    background: AppColors.background,
    surface: AppColors.surface,
    raisedSurface: AppColors.neutral50,
    border: AppColors.border,
    primaryText: AppColors.textPrimary,
    secondaryText: AppColors.textSecondary,
    primary: AppColors.indigo600,
    primaryContainer: AppColors.indigo50,
    onPrimaryContainer: AppColors.indigo700,
  );

  static final dark = _theme(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    raisedSurface: AppColors.darkSurfaceRaised,
    border: AppColors.darkBorder,
    primaryText: AppColors.darkTextPrimary,
    secondaryText: AppColors.darkTextSecondary,
    primary: AppColors.indigo300,
    primaryContainer: const Color(0xFF27265A),
    onPrimaryContainer: AppColors.indigo100,
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color raisedSurface,
    required Color border,
    required Color primaryText,
    required Color secondaryText,
    required Color primary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: brightness == Brightness.light
          ? Colors.white
          : AppColors.neutral900,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: AppColors.emerald600,
      onSecondary: Colors.white,
      secondaryContainer: brightness == Brightness.light
          ? AppColors.emerald50
          : const Color(0xFF11352C),
      onSecondaryContainer: brightness == Brightness.light
          ? AppColors.emerald700
          : AppColors.emerald200,
      tertiary: AppColors.violet600,
      onTertiary: Colors.white,
      tertiaryContainer: brightness == Brightness.light
          ? AppColors.purple50
          : const Color(0xFF34204F),
      onTertiaryContainer: brightness == Brightness.light
          ? AppColors.violet600
          : AppColors.purple200,
      error: brightness == Brightness.light
          ? AppColors.rose600
          : const Color(0xFFFFB4AB),
      onError: brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF690005),
      errorContainer: brightness == Brightness.light
          ? AppColors.rose50
          : const Color(0xFF4B1018),
      onErrorContainer: brightness == Brightness.light
          ? AppColors.rose600
          : const Color(0xFFFFDAD6),
      surface: surface,
      onSurface: primaryText,
      surfaceContainerLow: background,
      surfaceContainer: raisedSurface,
      surfaceContainerHigh: raisedSurface,
      surfaceContainerHighest: border,
      onSurfaceVariant: secondaryText,
      outline: secondaryText,
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: primaryText,
      onInverseSurface: surface,
      inversePrimary: AppColors.indigo300,
      surfaceTint: Colors.transparent,
    );
    final textTheme = AppTypography.textTheme(primaryText, secondaryText);
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      useMaterial3: true,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? primary
                : secondaryText,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? primary
                : secondaryText,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          backgroundColor: brightness == Brightness.light
              ? AppColors.indigo600
              : AppColors.indigo300,
          foregroundColor: brightness == Brightness.light
              ? Colors.white
              : AppColors.neutral900,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          foregroundColor: primaryText,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          side: BorderSide(color: border),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        hintStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }
}
