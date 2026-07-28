import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pitch_service.dart';
import 'chord_templates.dart';
import 'idea_scaffold.dart';

class ProgressionIdeaScreen extends StatefulWidget {
  const ProgressionIdeaScreen({super.key});

  @override
  State<ProgressionIdeaScreen> createState() => _ProgressionIdeaScreenState();
}

class _ProgressionIdeaScreenState extends State<ProgressionIdeaScreen> {
  static const _symbols = ['C', 'G', 'Am', 'F'];
  int _step = 0;
  String _targetRole = '3rd';

  ChordTemplate get _chord =>
      ChordTemplate.catalog.firstWhere((c) => c.symbol == _symbols[_step]);

  @override
  Widget build(BuildContext context) {
    final note = context.watch<PitchService>().currentNote;
    final role = note.frequency > 0
        ? _chord.roleForMidi(note.midi.round())
        : null;
    final hit = role == _targetRole;

    return IdeaScaffold(
      title: 'Progression',
      ideaNumber: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Prototype of progression practice (I–V–vi–IV in C). Aim for a target role on each chord.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: List.generate(_symbols.length, (i) {
              final selected = i == _step;
              return ChoiceChip(
                label: Text(_symbols[i]),
                selected: selected,
                onSelected: (_) => setState(() => _step = i),
                selectedColor: Colors.blueGrey,
              );
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _targetRole,
            dropdownColor: const Color(0xFF222222),
            decoration: const InputDecoration(
              labelText: 'Target role',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'root', child: Text('root')),
              DropdownMenuItem(value: '3rd', child: Text('3rd')),
              DropdownMenuItem(value: '5th', child: Text('5th')),
            ],
            onChanged: (v) => setState(() => _targetRole = v ?? '3rd'),
          ),
          const SizedBox(height: 28),
          Text(
            'Chord ${_chord.symbol}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Colors.white70),
          ),
          Text(
            note.frequency > 0 ? note.displayName : '—',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 8),
          Text(
            hit
                ? 'on target ($_targetRole)'
                : 'need $_targetRole · heard ${role ?? '—'}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: hit ? const Color(0xFF81C784) : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _step > 0 ? () => setState(() => _step--) : null,
                child: const Text('Prev'),
              ),
              OutlinedButton(
                onPressed: _step < _symbols.length - 1
                    ? () => setState(() => _step++)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
