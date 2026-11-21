import 'package:flutter/material.dart';

import 'musnote_tokens.g.dart';

/// Names screens already use. The numbers live in [MusnoteTokens].
abstract final class MusnoteColors {
  static const green50 = MusnoteTokens.green50;
  static const green100 = MusnoteTokens.green100;
  static const green500 = MusnoteTokens.green500;
  static const green600 = MusnoteTokens.green600;
  static const green700 = MusnoteTokens.green700;
  static const ink = MusnoteTokens.ink;
  static const inkSoft = MusnoteTokens.inkSoft;
  static const muted = MusnoteTokens.muted;
  static const line = MusnoteTokens.line;
  static const surface = MusnoteTokens.surface;
  static const surface2 = MusnoteTokens.surface2;
  static const danger = MusnoteTokens.danger;
  static const keyBlack = MusnoteTokens.keyBlack;
  static const keyLit = MusnoteTokens.keyLit;
  static const keyLitBlack = MusnoteTokens.keyLitBlack;
  static const keyLine = MusnoteTokens.keyLine;
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
