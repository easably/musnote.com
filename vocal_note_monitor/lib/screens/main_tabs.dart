import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';
import '../theme/musnote_theme.dart';
import 'monitor_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';

/// The three bottom tabs: live voice, notes from audio, settings.
class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  void _select(int index) {
    if (index != 0) {
      context.read<PitchService>().stop();
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _index == 0 ? Colors.black : MusnoteColors.surface2,
      body: IndexedStack(
        index: _index,
        children: [
          const MonitorScreen(),
          NotesScreen(tabVisible: _index == 1),
          const SettingsScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_none),
            selectedIcon: Icon(Icons.mic),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.piano_outlined),
            selectedIcon: Icon(Icons.piano),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
