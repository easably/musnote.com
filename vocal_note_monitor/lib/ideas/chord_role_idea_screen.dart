import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';
import 'chord_templates.dart';
import 'idea_scaffold.dart';

class ChordRoleIdeaScreen extends StatefulWidget {
  const ChordRoleIdeaScreen({super.key});

  @override
  State<ChordRoleIdeaScreen> createState() => _ChordRoleIdeaScreenState();
}

class _ChordRoleIdeaScreenState extends State<ChordRoleIdeaScreen> {
  ChordTemplate _chord = ChordTemplate.catalog.firstWhere(
    (c) => c.symbol == 'C',
  );

  @override
  Widget build(BuildContext context) {
    final note = context.watch<PitchService>().currentNote;
    final midi = note.midi.round();
    final role = note.frequency > 0 ? _chord.roleForMidi(midi) : null;

    return IdeaScaffold(
      title: 'Chord role',
      ideaNumber: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pick a chord. While listening, see if your note is a chord tone and which role.',
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
            items: ChordTemplate.catalog
                .where((c) => c.symbol.length <= 3)
                .map(
                  (c) =>
                      DropdownMenuItem(value: c.symbol, child: Text(c.label)),
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
          const SizedBox(height: 32),
          Text(
            note.frequency > 0 ? note.displayName : '—',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 12),
          Text(
            role ??
                (note.frequency > 0
                    ? 'non-chord tone'
                    : 'sing or press Listen'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              color: role == null
                  ? Colors.orangeAccent
                  : const Color(0xFF81C784),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _chord.intervals.map((interval) {
              final pc = (_chord.rootPitchClass + interval) % 12;
              final name = ChordTemplate.nameForPitchClass(pc);
              final roles = ['root', '3rd', '5th', '7th'];
              final idx = _chord.intervals.indexOf(interval);
              return Chip(
                label: Text('$name · ${roles[idx.clamp(0, roles.length - 1)]}'),
                backgroundColor: const Color(0xFF2A2A2A),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
