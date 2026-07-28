import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';
import 'chord_templates.dart';
import 'idea_scaffold.dart';

class ChordDetectIdeaScreen extends StatelessWidget {
  const ChordDetectIdeaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pitch = context.watch<PitchService>();
    final recent = pitch.history.length > 80
        ? pitch.history.sublist(pitch.history.length - 80)
        : pitch.history;
    final heard = recent
        .where((p) => p.amplitude >= 1)
        .map((p) => ((p.midi.round() % 12) + 12) % 12)
        .toSet();
    final match = ChordTemplate.matchPitchClasses(heard);

    return IdeaScaffold(
      title: 'Detect chord',
      ideaNumber: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Arpeggiate a chord while Listen is on. The app matches recent pitch classes to major / minor / 7 templates.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 28),
          Text(
            match?.symbol ?? '—',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w300),
          ),
          Text(
            match?.label ?? 'not enough notes yet',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 28),
          const Text(
            'Heard pitch classes',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: heard.isEmpty
                ? [
                    const Chip(
                      label: Text('empty'),
                      backgroundColor: Color(0xFF2A2A2A),
                    ),
                  ]
                : heard
                      .map(
                        (pc) => Chip(
                          label: Text(ChordTemplate.nameForPitchClass(pc)),
                          backgroundColor: const Color(0xFF2A2A2A),
                        ),
                      )
                      .toList(),
          ),
        ],
      ),
    );
  }
}
