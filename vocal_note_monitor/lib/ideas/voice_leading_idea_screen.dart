import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';
import 'chord_templates.dart';
import 'idea_scaffold.dart';

class VoiceLeadingIdeaScreen extends StatefulWidget {
  const VoiceLeadingIdeaScreen({super.key});

  @override
  State<VoiceLeadingIdeaScreen> createState() => _VoiceLeadingIdeaScreenState();
}

class _VoiceLeadingIdeaScreenState extends State<VoiceLeadingIdeaScreen> {
  ChordTemplate _from = ChordTemplate.catalog.firstWhere(
    (c) => c.symbol == 'C',
  );
  ChordTemplate _to = ChordTemplate.catalog.firstWhere((c) => c.symbol == 'G');

  @override
  Widget build(BuildContext context) {
    final note = context.watch<PitchService>().currentNote;
    final hint = note.frequency > 0
        ? _nearestHint(note.midi.round(), _to)
        : 'Listen, then see the nearest tone on the next chord';

    return IdeaScaffold(
      title: 'Voice leading',
      ideaNumber: 5,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'From current note toward the next chord — nearest chord-tone hint (evaluation prototype).',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          _chordDropdown('From', _from.symbol, (s) {
            setState(() {
              _from = ChordTemplate.catalog.firstWhere((c) => c.symbol == s);
            });
          }),
          const SizedBox(height: 12),
          _chordDropdown('To', _to.symbol, (s) {
            setState(() {
              _to = ChordTemplate.catalog.firstWhere((c) => c.symbol == s);
            });
          }),
          const SizedBox(height: 28),
          Text(
            note.frequency > 0 ? note.displayName : '—',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 12),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Color(0xFF90CAF9)),
          ),
          const SizedBox(height: 20),
          Text(
            'Current chord tones: ${_from.pitchClasses.map(ChordTemplate.nameForPitchClass).join(', ')}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38),
          ),
          Text(
            'Next chord tones: ${_to.pitchClasses.map(ChordTemplate.nameForPitchClass).join(', ')}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _chordDropdown(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF222222),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: const [
        'C',
        'Dm',
        'Em',
        'F',
        'G',
        'Am',
        'G7',
      ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  String _nearestHint(int midi, ChordTemplate next) {
    var bestMidi = midi;
    var bestDist = 99;
    for (final pc in next.pitchClasses) {
      for (final candidate in [midi - 6, midi, midi + 6]) {
        final base = candidate - (candidate % 12) + pc;
        for (final m in [base - 12, base, base + 12]) {
          final dist = (m - midi).abs();
          if (dist < bestDist) {
            bestDist = dist;
            bestMidi = m;
          }
        }
      }
    }
    if (bestDist == 0) {
      return 'Already on ${ChordTemplate.nameForPitchClass(bestMidi % 12)} of ${_to.symbol}';
    }
    final direction = bestMidi > midi ? 'up' : 'down';
    return 'Move $direction to ${ChordTemplate.nameForPitchClass(bestMidi % 12)} '
        '($bestDist semitone${bestDist == 1 ? '' : 's'}) for ${_to.symbol}';
  }
}
