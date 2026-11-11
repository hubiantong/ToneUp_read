import 'package:flutter/material.dart';
import 'go_tokens.dart';

ThemeData _buildTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? goDark : goLight;
  final scheme = ColorScheme.fromSeed(
    seedColor: p.primary,
    brightness: brightness,
  ).copyWith(
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.primary95,
    onPrimaryContainer: p.onPrimaryContainer,
    secondary: p.secondary,
    onSecondary: p.onSecondary,
    secondaryContainer: p.secondaryContainer,
    onSecondaryContainer: p.onSecondaryContainer,
    tertiary: p.tertiary,
    onTertiary: p.onTertiary,
    tertiaryContainer: p.tertiaryContainer,
    onTertiaryContainer: p.onTertiaryContainer,
    surface: p.surface,
    onSurface: p.onSurface,
    onSurfaceVariant: p.onSurface2,
    surfaceContainerLowest: p.bg,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface1,
    surfaceContainerHigh: p.surface2,
    surfaceContainerHighest: p.surface2,
    outline: p.outline,
    outlineVariant: p.surfaceVariant,
    error: p.error,
    onError: p.onDanger,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: p.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: p.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Go.rLg)),
    ),
    dividerColor: p.outline,
    dividerTheme: DividerThemeData(color: p.outline, thickness: 0.5, space: 0.5),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: Go.fsTitle, fontWeight: FontWeight.w600, color: p.onSurface),
      contentTextStyle: TextStyle(fontSize: Go.fsBodySm, height: Go.lhNormal, color: p.onSurface2),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surfaceRaised,
      modalBackgroundColor: p.surfaceRaised,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.surface2,
      contentTextStyle: TextStyle(fontSize: Go.fsBodySm, color: p.onSurface),
      actionTextColor: p.primary,
      behavior: SnackBarBehavior.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface1,
      hintStyle: TextStyle(fontSize: Go.fsBodySm, color: p.onSurface3),
      contentPadding: const EdgeInsets.symmetric(horizontal: Go.sp4, vertical: Go.sp3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Go.rMd),
        borderSide: BorderSide(color: p.outline, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Go.rMd),
        borderSide: BorderSide(color: p.outline, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Go.rMd),
        borderSide: BorderSide(color: p.primary, width: 1),
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: Go.fsBodySm, height: Go.lhNormal, color: p.onSurface),
      bodyLarge: TextStyle(fontSize: Go.fsBody, height: Go.lhNormal, color: p.onSurface),
      titleMedium: TextStyle(fontSize: Go.fsTitle, fontWeight: FontWeight.w600, color: p.onSurface),
      titleSmall: TextStyle(fontSize: Go.fsBodySm, fontWeight: FontWeight.w500, color: p.onSurface),
      labelMedium: TextStyle(fontSize: Go.fsMeta, color: p.onSurface3),
      labelSmall: TextStyle(fontSize: Go.fsCap, color: p.onSurface3),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

ThemeData buildLightTheme() => _buildTheme(Brightness.light);
ThemeData buildDarkTheme() => _buildTheme(Brightness.dark);
