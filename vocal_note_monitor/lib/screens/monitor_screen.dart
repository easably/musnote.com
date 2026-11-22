import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../l10n/ui_text.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';
import '../services/settings_service.dart';
import '../widgets/control_bar.dart';
import '../widgets/pitch_graph.dart';
import '../widgets/tuner_gauge.dart';
import '../ideas/ideas_hub_screen.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  @override
  void deactivate() {
    context.read<PitchService>().stop();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HeaderSection(),
            Expanded(child: const _GraphSection()),
            Consumer<PitchService>(
              builder: (context, pitchService, _) {
                return ControlBar(
                  state: pitchService.state,
                  onStop: () => pitchService.stop(),
                  onRecord: () {
                    if (pitchService.state == RecordingState.recording) {
                      pitchService.stop();
                    } else {
                      pitchService.startRecording();
                    }
                  },
                  onPlay: pitchService.play,
                  onMenu: () => _showMenu(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showMonitorActionSheet(
      context,
      onIdeas: () {
        Navigator.of(context).push(
          CupertinoPageRoute<void>(builder: (_) => const IdeasHubScreen()),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>().settings;
    final pitchService = context.watch<PitchService>();
    final note = pitchService.currentNote;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: t(context).cancel,
                onPressed: () {
                  context.read<PitchService>().stop();
                  Navigator.of(context).pop();
                },
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                  fixedSize: const Size(44, 44),
                ),
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 8),
              Text(
                settings.scale.displayName,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            note.frequency > 0 ? note.displayName : '—',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          TunerGauge(note: note, visible: settings.displayTuner),
        ],
      ),
    );
  }
}

class _GraphSection extends StatelessWidget {
  const _GraphSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>().settings;
    final pitchService = context.watch<PitchService>();

    final centerMidi = pitchService.currentNote.midi > 0
        ? pitchService.currentNote.midi
        : 60.0;

    return PitchGraph(
      history: pitchService.history,
      settings: settings,
      centerMidi: centerMidi,
    );
  }
}
