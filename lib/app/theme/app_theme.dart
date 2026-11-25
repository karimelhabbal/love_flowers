import 'package:flutter/material.dart';

/// Luxury Botanical palette derived from the supplied brand identity.
/// Text/action shades are darkened variants that meet WCAG AA on cream/white;
/// the lighter rose remains available for decorative fills only.
abstract final class AppColors {
  static const Color cream = Color(0xFFF7F3EC);
  static const Color rose = Color(0xFFD996A2);
  static const Color roseInk = Color(0xFF9E5564);
  static const Color sage = Color(0xFF5F6D54);
  static const Color ink = Color(0xFF48738B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color blush = Color(0xFFF3E4E1);
  static const Color sand = Color(0xFFEDE3D6);
  static const Color muted = Color(0xFF6E6E63);
  static const Color star = Color(0xFF8D5A00);
  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);

  static const Color darkCanvas = Color(0xFF171B18);
  static const Color darkSurface = Color(0xFF232A24);
  static const Color darkOutline = Color(0xFF3A443A);
  static const Color darkText = Color(0xFFF2EFE8);
  static const Color darkMuted = Color(0xFFB8BDB3);
  static const Color darkSage = Color(0xFFA8B99C);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), cream],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  const AppTheme._();

  static TextStyle get _body => const TextStyle(fontFamily: 'IBMPlexSansArabic');
  static TextStyle get _display => const TextStyle(fontFamily: 'PlayfairDisplay');

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.sage,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.sage,
      onPrimary: AppColors.white,
      secondary: AppColors.roseInk,
      onSecondary: AppColors.white,
      tertiary: AppColors.ink,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
      surfaceTint: AppColors.sage,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: _body.fontFamily,
      textTheme: TextTheme(
        displayLarge: _display.copyWith(
          fontSize: 42,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        displayMedium: _display.copyWith(
          fontSize: 34,
          height: 1.15,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        headlineMedium: _display.copyWith(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleLarge: _display.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleMedium: _body.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: _body.copyWith(fontSize: 16, color: AppColors.ink),
        bodyMedium: _body.copyWith(fontSize: 14, color: AppColors.ink),
        bodySmall: _body.copyWith(fontSize: 12, color: AppColors.muted),
        labelLarge: _body.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: scheme.onPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.ink),
        titleTextStyle: _display.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.sand.withValues(alpha: 0.7)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sage,
          side: const BorderSide(color: AppColors.sage),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: _body.copyWith(color: AppColors.muted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.sage,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: _body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: _body.copyWith(fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.blush,
        labelTextStyle: WidgetStatePropertyAll(_body.copyWith(fontSize: 12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.sage,
        side: const BorderSide(color: AppColors.sand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.sand,
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sage,
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.sage,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.darkSage,
      onPrimary: AppColors.darkCanvas,
      secondary: const Color(0xFFE3A7B2),
      onSecondary: AppColors.darkCanvas,
      tertiary: const Color(0xFF9CC3DA),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceTint: Colors.transparent,
      error: const Color(0xFFFFB4AB),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      fontFamily: _body.fontFamily,
      textTheme: TextTheme(
        displayLarge: _display.copyWith(fontSize: 42, height: 1.1, color: AppColors.darkText),
        displayMedium: _display.copyWith(fontSize: 34, height: 1.15, color: AppColors.darkText),
        headlineMedium: _display.copyWith(fontSize: 26, height: 1.2, color: AppColors.darkText),
        titleLarge: _display.copyWith(fontSize: 21, fontWeight: FontWeight.w600, color: AppColors.darkText),
        titleMedium: _body.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkText),
        bodyLarge: _body.copyWith(fontSize: 16, color: AppColors.darkText),
        bodyMedium: _body.copyWith(fontSize: 14, color: AppColors.darkText),
        bodySmall: _body.copyWith(fontSize: 12, color: AppColors.darkMuted),
        labelLarge: _body.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: scheme.onPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCanvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        titleTextStyle: _display.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkOutline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkSage,
          foregroundColor: AppColors.darkCanvas,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: _body.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkSage,
          foregroundColor: AppColors.darkCanvas,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkSage,
          side: const BorderSide(color: AppColors.darkSage),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: _body.copyWith(color: AppColors.darkMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkSage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkSage,
        unselectedItemColor: AppColors.darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: _body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: _body.copyWith(fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(_body.copyWith(fontSize: 12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.darkSage,
        side: const BorderSide(color: AppColors.darkOutline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutline,
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkSage,
      ),
    );
  }
}
