import 'package:flutter/material.dart';

import '../l10n/ui_text.dart';
import '../theme/musnote_theme.dart';
import 'monitor_screen.dart';
import 'site_tool_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    return Scaffold(
      backgroundColor: MusnoteColors.surface2,
      appBar: AppBar(
        backgroundColor: MusnoteColors.surface,
        title: Text(text.tools),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 4
              : constraints.maxWidth >= 700
                  ? 3
                  : 2;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _Group(
                title: text.groupInApp,
                columns: columns,
                tiles: [
                  _Tile(
                    title: text.toolMonitor,
                    subtitle: text.toolMonitorHint,
                    icon: Icons.graphic_eq,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MonitorScreen()),
                      );
                    },
                  ),
                ],
              ),
              _Group(
                title: text.groupChords,
                columns: columns,
                tiles: [
                  _web(context, text.toolPiano, text.toolPianoHint, Icons.piano, '/piano'),
                  _web(context, text.toolChart, text.toolChartHint, Icons.grid_view, '/chords/chart/'),
                  _web(context, text.toolClock, text.toolClockHint, Icons.schedule, '/chords/clock/'),
                  _web(context, text.toolHops, text.toolHopsHint, Icons.linear_scale, '/chords/hops/'),
                  _web(context, text.toolPatterns, text.toolPatternsHint, Icons.account_tree, '/chords/patterns/'),
                ],
              ),
              _Group(
                title: text.groupVoice,
                columns: columns,
                tiles: [
                  _web(context, text.toolSpeech, text.toolSpeechHint, Icons.subtitles, '/tools/audio-to-text'),
                  _web(context, text.toolSlow, text.toolSlowHint, Icons.slow_motion_video, '/tools/slow-pronunciation'),
                  _web(context, text.toolOctave, text.toolOctaveHint, Icons.record_voice_over, '/tools/find-my-octave'),
                  _web(context, text.toolShadow, text.toolShadowHint, Icons.campaign, '/tools/shadow-phrase'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  _Tile _web(BuildContext context, String title, String subtitle, IconData icon, String path) {
    return _Tile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      web: true,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SiteToolScreen(title: title, path: path),
          ),
        );
      },
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.columns, required this.tiles});

  final String title;
  final int columns;
  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(title.toUpperCase(), style: MusnoteType.section),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: tiles,
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.web = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool web;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MusnoteColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: MusnoteColors.green700),
                  const Spacer(),
                  if (web)
                    Text(
                      t(context).webMark,
                      style: const TextStyle(
                        color: MusnoteColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: MusnoteColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
