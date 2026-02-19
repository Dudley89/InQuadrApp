import 'package:flutter/material.dart';

const _seedColor = Color(0xFF345B73);

ThemeData get lightTheme {
  final scheme = ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: Typography.blackMountainView,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
  );
}

ThemeData get darkTheme {
  final scheme = ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: Typography.whiteMountainView,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
  );
}
