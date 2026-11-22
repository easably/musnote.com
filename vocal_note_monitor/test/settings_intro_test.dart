import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_note_monitor/l10n/app_localizations.dart';
import 'package:vocal_note_monitor/screens/musnote_settings_screen.dart';
import 'package:vocal_note_monitor/services/app_language.dart';
import 'package:vocal_note_monitor/services/note_spelling.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings opens the introduction again', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppLanguage()),
          ChangeNotifierProvider(create: (_) => NoteSpelling()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MusnoteSettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('How it works'), findsOneWidget);

    await tester.tap(find.text('How it works'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('From sound to notes on the keys'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('From sound to notes on the keys'), findsNothing);
    expect(find.text('How it works'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
