import 'package:flutter/material.dart';

import 'musnote_tokens.g.dart';

/// Names screens already use. The numbers live in [MusnoteTokens].
abstract final class MusnoteColors {
  static const green50 = MusnoteTokens.green50;
  static const green400 = MusnoteTokens.green400;
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
      fontFamily: MusnoteTokens.fontSans,
      scaffoldBackgroundColor: MusnoteColors.surface2,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MusnoteColors.green500,
        primary: MusnoteColors.green500,
        onPrimary: Colors.white,
        surface: MusnoteColors.surface,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: MusnoteTokens.fontSans),
      appBarTheme: const AppBarTheme(
        backgroundColor: MusnoteColors.surface,
        foregroundColor: MusnoteColors.ink,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: MusnoteTokens.fontSans,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MusnoteColors.ink,
        ),
      ),
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

/// Screen text sizes from the mobile prototype.
abstract final class MusnoteType {
  static const pageWidth = 720.0;

  static const section = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.72,
    color: MusnoteColors.muted,
  );

  static const display = TextStyle(
    fontFamily: MusnoteTokens.fontDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
}

/// Keeps a phone screen full width and a tablet screen near 720 pt.
class MusnotePage extends StatelessWidget {
  const MusnotePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MusnoteType.pageWidth),
        child: child,
      ),
    );
  }
}
