import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/app_gate.dart';
import 'services/app_language.dart';
import 'services/note_spelling.dart';
import 'services/pitch_service.dart';
import 'services/recording_store.dart';
import 'services/settings_service.dart';
import 'services/store_review_service.dart';
import 'theme/musnote_theme.dart';

class VocalNoteMonitorApp extends StatelessWidget {
  const VocalNoteMonitorApp({
    super.key,
    required this.language,
    required this.spelling,
  });

  final AppLanguage language;
  final NoteSpelling spelling;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordingStore()),
        ChangeNotifierProvider(create: (_) => StoreReviewService()),
        ChangeNotifierProvider.value(value: spelling),
        ChangeNotifierProvider.value(value: language),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProxyProvider<SettingsService, PitchService>(
          create: (_) => PitchService(),
          update: (_, settings, pitch) {
            pitch ??= PitchService(a4Frequency: settings.settings.a4Frequency);
            pitch.a4Frequency = settings.settings.a4Frequency;
            return pitch;
          },
        ),
      ],
      child: const _LocalizedApp(),
    );
  }
}

class _LocalizedApp extends StatefulWidget {
  const _LocalizedApp();

  @override
  State<_LocalizedApp> createState() => _LocalizedAppState();
}

class _LocalizedAppState extends State<_LocalizedApp> {
  @override
  void initState() {
    super.initState();
    context.read<AppLanguage>().addListener(_followNotes);
  }

  void _followNotes() {
    if (!mounted) return;
    context.read<NoteSpelling>().followLanguage(
      context.read<AppLanguage>().resolved,
    );
  }

  @override
  void dispose() {
    context.read<AppLanguage>().removeListener(_followNotes);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguage>();
    return MaterialApp(
      title: 'Audio to Piano Notes - MusNote',
      debugShowCheckedModeBanner: false,
      theme: MusnoteTheme.light(),
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppGate(),
    );
  }
}
