import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  const brandGold = Color(0xFFDA8C1F);
  const brandNavy = Color(0xFF1E2A44);
  const paper = Color(0xFFFEF7EB);
  const outline = Color.fromARGB(255, 213, 174, 95);

  final baseScheme = ColorScheme.fromSeed(
    seedColor: brandGold,
    brightness: Brightness.light,
  ).copyWith(
    primary: brandGold,
    onPrimary: Colors.white,
    secondary: brandNavy,
    onSecondary: Colors.white,
    surface: paper,
    background: paper,
    onSurface: const Color(0xFF1B1B1B),
    onBackground: const Color(0xFF1B1B1B),
    outline: outline,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: baseScheme,
    brightness: Brightness.light,
    visualDensity: VisualDensity.comfortable,
  );

  return base.copyWith(
    textTheme: GoogleFonts.tajawalTextTheme(base.textTheme),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: baseScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: baseScheme.onSurface),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: baseScheme.surface.withOpacity(0.9),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandGold, width: 1.6),
      ),
      labelStyle: TextStyle(color: baseScheme.onSurface.withOpacity(0.75)),
      prefixIconColor: baseScheme.onSurface.withOpacity(0.75),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandGold,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandNavy,
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brandNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    chipTheme: base.chipTheme.copyWith(
      side: const BorderSide(color: outline),
      backgroundColor: baseScheme.surface.withOpacity(0.7),
      labelStyle: TextStyle(color: baseScheme.onSurface),
      selectedColor: const Color.fromARGB(255, 250, 248, 246).withOpacity(0.1),
    ),

    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: brandGold.withOpacity(0.15),
      surfaceTintColor: Colors.transparent,
      backgroundColor: paper,
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.tajawal(fontWeight: FontWeight.w600),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? brandGold : brandNavy,
        ),
      ),
    ),

// Cards
// cardTheme: CardTheme(
//   color: Colors.white,
//   elevation: 0,
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//   surfaceTintColor: Colors.transparent,
// ),

    dividerTheme: const DividerThemeData(
      color: outline,
      thickness: 1,
      space: 16,
    ),
  );
}
