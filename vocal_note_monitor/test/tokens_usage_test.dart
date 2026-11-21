import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/theme/musnote_tokens.g.dart';

void main() {
  test('tokens drop into Flutter widgets', () {
    final padding = EdgeInsets.all(MusnoteTokens.space4);
    final style = TextStyle(
      fontFamily: MusnoteTokens.fontSans,
      fontFamilyFallback: MusnoteTokens.fontSansFallback,
      fontSize: MusnoteTokens.fsMd,
    );
    final deco = BoxDecoration(boxShadow: MusnoteTokens.shadowSoft);
    final curve = MusnoteTokens.ease;
    final dur = MusnoteTokens.dur;

    expect(padding.left, 16);
    expect(style.fontFamily, 'Outfit');
    expect(style.fontSize, 17);
    expect(deco.boxShadow, isNotEmpty);
    expect(curve, isA<Cubic>());
    expect(dur, const Duration(milliseconds: 420));
  });
}
