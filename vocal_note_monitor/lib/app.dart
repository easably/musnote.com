import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/monitor_screen.dart';
import 'services/pitch_service.dart';
import 'services/settings_service.dart';

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
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: CupertinoColors.activeBlue,
            surface: Colors.black,
          ),
          sliderTheme: const SliderThemeData(
            activeTrackColor: CupertinoColors.activeBlue,
            thumbColor: Colors.white,
          ),
        ),
        home: const MonitorScreen(),
      ),
    );
  }
}
