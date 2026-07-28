import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';
import 'chord_templates.dart';
import 'idea_scaffold.dart';
import 'widgets/mini_piano.dart';

class PianoStripIdeaScreen extends StatefulWidget {
  const PianoStripIdeaScreen({super.key});

  @override
  State<PianoStripIdeaScreen> createState() => _PianoStripIdeaScreenState();
}

class _PianoStripIdeaScreenState extends State<PianoStripIdeaScreen> {
  ChordTemplate _chord = ChordTemplate.catalog.firstWhere(
    (c) => c.symbol == 'C',
  );

  @override
  Widget build(BuildContext context) {
    final note = context.watch<PitchService>().currentNote;
    final activeMidi = note.frequency > 0 ? note.midi.round() : null;

    return IdeaScaffold(
      title: 'Piano strip',
      ideaNumber: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Inspired by the site piano / chord tutorial: chord tones on a keyboard, plus live voice.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _chord.symbol,
            dropdownColor: const Color(0xFF222222),
            decoration: const InputDecoration(
              labelText: 'Chord',
              border: OutlineInputBorder(),
            ),
            items: ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'G7']
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      ChordTemplate.catalog
                          .firstWhere((c) => c.symbol == s)
                          .label,
                    ),
                  ),
                )
                .toList(),
            onChanged: (symbol) {
              if (symbol == null) return;
              setState(() {
                _chord = ChordTemplate.catalog.firstWhere(
                  (c) => c.symbol == symbol,
                );
              });
            },
          ),
          const SizedBox(height: 28),
          Text(
            activeMidi != null ? note.displayName : '—',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 20),
          MiniPiano(
            chordPitchClasses: _chord.pitchClasses,
            activeMidi: activeMidi,
          ),
          const SizedBox(height: 12),
          const Text(
            'Blue = chord tones · Yellow = current voice',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
