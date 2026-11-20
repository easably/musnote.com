import 'dart:math';

import 'package:flutter/material.dart';

import '../models/piano_note.dart';
import '../theme/musnote_theme.dart';

/// White keys wide enough to show the notes, plus a key or two on each side.
class PianoKeyboardRange {
  PianoKeyboardRange({required this.whiteMidis});

  final List<int> whiteMidis;

  factory PianoKeyboardRange.forMidis(Iterable<int> midis) {
    var lo = 48;
    var hi = 72;
    final list = midis.toList();
    if (list.isNotEmpty) {
      lo = (list.reduce(min) - 2).clamp(21, 108);
      hi = (list.reduce(max) + 2).clamp(21, 108);
      if (hi < lo) hi = lo;
    }
    var start = lo;
    while (midiIsBlack(start) && start > 0) {
      start--;
    }
    final whites = <int>[];
    var midi = start;
    while (midi <= hi && whites.length < 24) {
      if (!midiIsBlack(midi)) whites.add(midi);
      midi++;
    }
    while (whites.length < 8 && midi < 128) {
      if (!midiIsBlack(midi)) whites.add(midi);
      midi++;
    }
    return PianoKeyboardRange(whiteMidis: whites);
  }
}

/// Piano strip for the Notes tab. Green keys are the notes heard in the audio.
class NotesPiano extends StatelessWidget {
  const NotesPiano({super.key, required this.midis, required this.litMidi});

  /// Every note in the piece, so the keyboard can span them.
  final List<int> midis;

  /// MIDI numbers of keys to paint green right now.
  final Set<int> litMidi;

  @override
  Widget build(BuildContext context) {
    final range = PianoKeyboardRange.forMidis(midis.isEmpty ? litMidi : midis);
    final whites = range.whiteMidis;
    const height = 150.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MusnoteColors.surface2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final whiteWidth = max(32.0, constraints.maxWidth / whites.length);
            final boardWidth = max(constraints.maxWidth, whiteWidth * whites.length);
            final blackWidth = whiteWidth * 0.58;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: boardWidth,
                height: height,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        for (final midi in whites)
                          _WhiteKey(
                            width: whiteWidth,
                            height: height,
                            midi: midi,
                            lit: litMidi.contains(midi),
                          ),
                      ],
                    ),
                    for (var i = 0; i < whites.length - 1; i++)
                      if (whites[i + 1] - whites[i] == 2)
                        Positioned(
                          left: (i + 1) * whiteWidth - blackWidth / 2,
                          top: 0,
                          child: _BlackKey(
                            width: blackWidth,
                            height: height * 0.62,
                            lit: litMidi.contains(whites[i] + 1),
                          ),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WhiteKey extends StatelessWidget {
  const _WhiteKey({
    required this.width,
    required this.height,
    required this.midi,
    required this.lit,
  });

  final double width;
  final double height;
  final int midi;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final letter = PianoNote.letterForMidi(midi);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: lit ? MusnoteColors.keyLit : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
        border: Border.all(color: MusnoteColors.keyLine),
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: MusnoteColors.muted,
        ),
      ),
    );
  }
}

class _BlackKey extends StatelessWidget {
  const _BlackKey({
    required this.width,
    required this.height,
    required this.lit,
  });

  final double width;
  final double height;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: lit ? MusnoteColors.keyLitBlack : MusnoteColors.keyBlack,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
      ),
    );
  }
}
