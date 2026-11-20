import 'package:flutter/material.dart';

/// Colors from the site (`web/assets/css/design-tokens.css` and `chords.css`).
abstract final class MusnoteColors {
  static const green50 = Color(0xFFEEFBF6);
  static const green100 = Color(0xFFD5F5E9);
  static const green500 = Color(0xFF15C39A);
  static const green600 = Color(0xFF0E9F6E);
  static const green700 = Color(0xFF0B7A56);
  static const ink = Color(0xFF0F1F1A);
  static const inkSoft = Color(0xFF3D4F48);
  static const muted = Color(0xFF6B7C75);
  static const line = Color(0xFFDCE6E1);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF6FAF8);
  static const danger = Color(0xFFC23B3B);
  static const keyBlack = Color(0xFF1B2622);
  static const keyLit = Color(0xFFA7F3D0);
  static const keyLitBlack = Color(0xFF10B981);
  static const keyLine = Color(0xFFC3D1CB);
}

abstract final class MusnoteTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: MusnoteColors.surface2,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MusnoteColors.green500,
        primary: MusnoteColors.green500,
        onPrimary: Colors.white,
        surface: MusnoteColors.surface,
      ),
    );
    return base.copyWith(
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MusnoteColors.surface,
        indicatorColor: MusnoteColors.green100,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? MusnoteColors.green700 : MusnoteColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? MusnoteColors.green700 : MusnoteColors.muted,
          );
        }),
      ),
    );
  }
}
