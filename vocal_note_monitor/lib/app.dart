import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_tabs.dart';
import 'services/pitch_service.dart';
import 'services/settings_service.dart';
import 'theme/musnote_theme.dart';

class VocalNoteMonitorApp extends StatelessWidget {
  const VocalNoteMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      child: MaterialApp(
        title: 'Vocal Note Monitor',
        debugShowCheckedModeBanner: false,
        theme: MusnoteTheme.light(),
        home: const MainTabs(),
      ),
    );
  }
}
