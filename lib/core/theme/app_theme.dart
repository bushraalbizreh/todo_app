import 'package:flutter/material.dart';

/// Semantic colors used by the application. The legacy static constants are
/// retained for the light reference design, while widgets should prefer
/// [AppColors.of] so the same component also works in dark mode.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.ink,
    required this.slate,
    required this.muted,
    required this.border,
    required this.borderLight,
    required this.coral,
    required this.rose,
    required this.emerald,
    required this.emeraldSoft,
    required this.focusPrimary,
    required this.focusSecondary,
    required this.focusSurface,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.surfaceContainer,
  });

  final Color background;
  final Color surface;
  final Color ink;
  final Color slate;
  final Color muted;
  final Color border;
  final Color borderLight;
  final Color coral;
  final Color rose;
  final Color emerald;
  final Color emeraldSoft;
  final Color focusPrimary;
  final Color focusSecondary;
  final Color focusSurface;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color surfaceContainer;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? slate,
    Color? muted,
    Color? border,
    Color? borderLight,
    Color? coral,
    Color? rose,
    Color? emerald,
    Color? emeraldSoft,
    Color? focusPrimary,
    Color? focusSecondary,
    Color? focusSurface,
    Color? surfaceContainerLow,
    Color? surfaceContainerHigh,
    Color? surfaceContainer,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      slate: slate ?? this.slate,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      coral: coral ?? this.coral,
      rose: rose ?? this.rose,
      emerald: emerald ?? this.emerald,
      emeraldSoft: emeraldSoft ?? this.emeraldSoft,
      focusPrimary: focusPrimary ?? this.focusPrimary,
      focusSecondary: focusSecondary ?? this.focusSecondary,
      focusSurface: focusSurface ?? this.focusSurface,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      slate: Color.lerp(slate, other.slate, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      emerald: Color.lerp(emerald, other.emerald, t)!,
      emeraldSoft: Color.lerp(emeraldSoft, other.emeraldSoft, t)!,
      focusPrimary: Color.lerp(focusPrimary, other.focusPrimary, t)!,
      focusSecondary: Color.lerp(focusSecondary, other.focusSecondary, t)!,
      focusSurface: Color.lerp(focusSurface, other.focusSurface, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
    );
  }
}

class AppColors {
  const AppColors._();

  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const slate = Color(0xFF64748B);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);
  static const coral = Color(0xFFFF5E4D);
  static const rose = Color(0xFFF43F5E);
  static const emerald = Color(0xFF10B981);
  static const emeraldSoft = Color(0xFFECFDF5);
  static const focusPurple = Color(0xFF630ED4);
  static const focusLavender = Color(0xFFEADDFF);

  static AppPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? _darkPalette : _lightPalette);
  }
}

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  const AppRadii._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
  static const double pill = 999;
}

const _lightPalette = AppPalette(
  background: AppColors.background,
  surface: AppColors.surface,
  ink: AppColors.ink,
  slate: AppColors.slate,
  muted: AppColors.muted,
  border: AppColors.border,
  borderLight: AppColors.borderLight,
  coral: AppColors.coral,
  rose: AppColors.rose,
  emerald: AppColors.emerald,
  emeraldSoft: AppColors.emeraldSoft,
  focusPrimary: AppColors.focusPurple,
  focusSecondary: Color(0xFF9A7BEA),
  focusSurface: Color(0xFFF2F0FF),
  surfaceContainerLow: Color(0xFFF8FAFC),
  surfaceContainerHigh: Color(0xFFE8EEF5),
  surfaceContainer: Color(0xFFF1F5F9),
);

const _darkPalette = AppPalette(
  background: Color(0xFF0B1120),
  surface: Color(0xFF151E31),
  ink: Color(0xFFF8FAFC),
  slate: Color(0xFFB2BED0),
  muted: Color(0xFF7F8DA3),
  border: Color(0xFF334155),
  borderLight: Color(0xFF263449),
  coral: Color(0xFFFF8A7A),
  rose: Color(0xFFFF7890),
  emerald: Color(0xFF5EEAD4),
  emeraldSoft: Color(0xFF123B36),
  focusPrimary: Color(0xFFC4A7FF),
  focusSecondary: Color(0xFF9F7AEA),
  focusSurface: Color(0xFF292348),
  surfaceContainerLow: Color(0xFF182338),
  surfaceContainerHigh: Color(0xFF24324A),
  surfaceContainer: Color(0xFF1D2940),
);

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final palette = isDark ? _darkPalette : _lightPalette;
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.coral,
        onPrimary: isDark ? const Color(0xFF3B0905) : Colors.white,
        primaryContainer: isDark
            ? const Color(0xFF7A241A)
            : const Color(0xFFFFDAD4),
        onPrimaryContainer:
            isDark ? const Color(0xFFFFDAD4) : const Color(0xFF3B0905),
        secondary: palette.rose,
        onSecondary: isDark ? const Color(0xFF3B0711) : Colors.white,
        secondaryContainer:
            isDark ? const Color(0xFF6B1730) : const Color(0xFFFFE1E6),
        onSecondaryContainer:
            isDark ? const Color(0xFFFFE1E6) : const Color(0xFF3B0711),
        tertiary: palette.focusPrimary,
        onTertiary: isDark ? const Color(0xFF25104D) : Colors.white,
        tertiaryContainer:
            isDark ? const Color(0xFF4C2B85) : const Color(0xFFEADDFF),
        onTertiaryContainer:
            isDark ? const Color(0xFFEADDFF) : const Color(0xFF25104D),
        error: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
        onError: isDark ? const Color(0xFF690005) : Colors.white,
        errorContainer:
            isDark ? const Color(0xFF93000A) : const Color(0xFFFFDAD6),
        onErrorContainer:
            isDark ? const Color(0xFFFFDAD6) : const Color(0xFF410002),
        surface: palette.surface,
        onSurface: palette.ink,
        surfaceContainerLowest:
            isDark ? const Color(0xFF101827) : Colors.white,
        surfaceContainerLow: isDark
            ? const Color(0xFF182338)
            : const Color(0xFFF8FAFC),
        surfaceContainer:
            isDark ? const Color(0xFF1D2940) : const Color(0xFFF1F5F9),
        surfaceContainerHigh:
            isDark ? const Color(0xFF24324A) : const Color(0xFFE8EEF5),
        surfaceContainerHighest:
            isDark ? const Color(0xFF2B3A54) : const Color(0xFFDDE5EF),
        onSurfaceVariant: palette.slate,
        outline: palette.border,
        outlineVariant: palette.borderLight,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: isDark ? palette.surface : const Color(0xFF1E293B),
        onInverseSurface: isDark ? palette.ink : Colors.white,
        inversePrimary: isDark
            ? const Color(0xFF9A6BFF)
            : const Color(0xFFB69BFF),
      ),
    );

    final textColor = palette.ink;
    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      extensions: <ThemeExtension<dynamic>>[palette],
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      textTheme: base.textTheme
          .apply(fontFamily: 'Inter', bodyColor: textColor, displayColor: textColor)
          .copyWith(
            headlineSmall: base.textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: -0.8,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.35,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.15,
            ),
            titleSmall: base.textTheme.titleSmall?.copyWith(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
            bodyLarge: base.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontSize: 15,
              height: 1.35,
            ),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: 13,
              height: 1.3,
            ),
            bodySmall: base.textTheme.bodySmall?.copyWith(
              color: palette.slate,
              fontSize: 12,
              height: 1.25,
            ),
            labelLarge: base.textTheme.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            labelMedium: base.textTheme.labelMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1D2940) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: palette.coral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFFE2E8F0) : palette.ink,
        contentTextStyle: TextStyle(
          color: isDark ? palette.ink : Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.coral,
        foregroundColor: isDark ? const Color(0xFF3B0905) : Colors.white,
        elevation: 5,
        focusElevation: 7,
        hoverElevation: 7,
        shape: const StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: palette.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
