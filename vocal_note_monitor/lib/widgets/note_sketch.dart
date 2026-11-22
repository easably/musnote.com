import 'package:flutter/material.dart';

import '../models/piano_note.dart';
import '../theme/musnote_theme.dart';

/// Small picture of notes by time and pitch, 54 px tall.
class NoteSketch extends StatelessWidget {
  const NoteSketch({super.key, required this.notes});

  final List<PianoNote> notes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: CustomPaint(
        painter: _SketchPainter(notes),
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  _SketchPainter(this.notes);

  final List<PianoNote> notes;

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty) return;
    var minMidi = notes.first.midi;
    var maxMidi = notes.first.midi;
    var end = 0.0;
    for (final note in notes) {
      if (note.midi < minMidi) minMidi = note.midi;
      if (note.midi > maxMidi) maxMidi = note.midi;
      if (note.end > end) end = note.end;
    }
    if (end <= 0) end = 1;
    final span = (maxMidi - minMidi).clamp(1, 127).toDouble();
    final paint = Paint()..color = MusnoteColors.green600;
    for (final note in notes) {
      final x = (note.start / end) * size.width;
      final w = ((note.end - note.start) / end) * size.width;
      final y = (1 - (note.midi - minMidi) / span) * (size.height - 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w.clamp(2, size.width), 4),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SketchPainter oldDelegate) =>
      oldDelegate.notes != notes;
}
