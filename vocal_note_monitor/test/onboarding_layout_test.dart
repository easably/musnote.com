import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vocal_note_monitor/l10n/app_localizations.dart';
import 'package:vocal_note_monitor/screens/onboarding_screen.dart';
import 'package:vocal_note_monitor/services/app_language.dart';

void main() {
  for (final size in const [
    Size(600, 960),
    Size(744, 1133),
    Size(834, 1194),
    Size(1194, 834),
  ]) {
    testWidgets('tablet ${size.width.toInt()}×${size.height.toInt()} stays centered', (
      tester,
    ) async {
      await _pump(tester, size);
      expect(tester.takeException(), isNull);

      final screen = Offset.zero & size;
      final title = tester.getRect(find.text('From sound to notes on the keys'));
      final button = tester.getRect(find.widgetWithText(FilledButton, 'Next'));
      final animation = tester.getRect(find.byType(LottieBuilder));
      final chip = tester.getRect(find.widgetWithText(TextButton, 'English'));

      expect((title.center.dx - screen.center.dx).abs(), lessThan(1));
      expect((button.center.dx - screen.center.dx).abs(), lessThan(1));
      expect((animation.center.dx - screen.center.dx).abs(), lessThan(1));
      expect(animation.width, lessThanOrEqualTo(screen.width - 32));
      expect(button.bottom, greaterThan(screen.bottom - 80));
      expect(title.bottom, lessThan(button.top));

      expect(chip.top, lessThan(48));
      expect(screen.right - chip.right, lessThan(48));
      expect(chip.bottom, lessThan(animation.top));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('phone onboarding title stays centered', (tester) async {
    const size = Size(390, 844);
    await _pump(tester, size);

    final screen = Offset.zero & size;
    final title = tester.getRect(find.text('From sound to notes on the keys'));
    final button = tester.getRect(find.widgetWithText(FilledButton, 'Next'));

    expect((title.center.dx - screen.center.dx).abs(), lessThan(1));
    expect((button.center.dx - screen.center.dx).abs(), lessThan(1));
    expect(button.width, greaterThan(screen.width - 80));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppLanguage(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(onDone: () {}),
      ),
    ),
  );
  await tester.pump();
}
