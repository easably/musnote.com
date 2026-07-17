import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/musical_note.dart';
import '../models/pitch_point.dart';

class PitchGraph extends StatelessWidget {
  const PitchGraph({
    super.key,
    required this.history,
    required this.settings,
    this.centerMidi = 60,
  });

  final List<PitchPoint> history;
  final AppSettings settings;
  final double centerMidi;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: PitchGraphPainter(
            history: history,
            settings: settings,
            centerMidi: centerMidi,
          ),
        );
      },
    );
  }
}

class PitchGraphPainter extends CustomPainter {
  PitchGraphPainter({
    required this.history,
    required this.settings,
    required this.centerMidi,
  });

  final List<PitchPoint> history;
  final AppSettings settings;
  final double centerMidi;

  static const _semitonesVisible = 24;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _drawGrid(canvas, size);
    _drawPitchLine(canvas, size);
    _drawNoteLabels(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final zoom = settings.verticalZoom;
    final range = _semitonesVisible / zoom;
    final center = centerMidi > 0 ? centerMidi : 60;
    final minMidi = center - range / 2;
    final maxMidi = center + range / 2;

    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1;

    final cNotePaint = Paint()
      ..color = const Color(0xFF3D3D3D)
      ..strokeWidth = 1.5;

    final semitonePaint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..strokeWidth = 0.5;

    for (var midi = minMidi.floor(); midi <= maxMidi.ceil(); midi++) {
      final y = _midiToY(midi.toDouble(), size, minMidi, maxMidi);
      if (y < 0 || y > size.height) continue;

      final noteName = MusicalNote.nameForMidi(midi);
      final isC = noteName == 'C';
      final isSemitone = settings.showSemitoneLines;

      if (isC) {
        canvas.drawLine(Offset(40, y), Offset(size.width, y), cNotePaint);
      } else if (isSemitone) {
        canvas.drawLine(Offset(40, y), Offset(size.width, y), semitonePaint);
      } else {
        canvas.drawLine(Offset(40, y), Offset(size.width, y), gridPaint);
      }

      final degree = settings.scale.degreeForMidi(midi);
      if (degree > 0 && degree <= 4) {
        final degreePaint = Paint()
          ..color = settings.colorForScaleDegree(degree).withValues(alpha: 0.3)
          ..strokeWidth = 2;
        canvas.drawLine(Offset(40, y), Offset(size.width, y), degreePaint);
      }
    }
  }

  void _drawNoteLabels(Canvas canvas, Size size) {
    final zoom = settings.verticalZoom;
    final range = _semitonesVisible / zoom;
    final center = centerMidi > 0 ? centerMidi : 60;
    final minMidi = center - range / 2;
    final maxMidi = center + range / 2;

    for (var midi = minMidi.floor(); midi <= maxMidi.ceil(); midi++) {
      final y = _midiToY(midi.toDouble(), size, minMidi, maxMidi);
      if (y < 10 || y > size.height - 10) continue;

      final noteName = MusicalNote.nameForMidi(midi);
      final octave = MusicalNote.octaveForMidi(midi);
      final text = '$noteName$octave';

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: noteName == 'C' ? Colors.white70 : Colors.white38,
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(4, y - textPainter.height / 2));
    }
  }

  void _drawPitchLine(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final zoom = settings.verticalZoom;
    final hZoom = settings.horizontalZoom;
    final range = _semitonesVisible / zoom;
    final center = centerMidi > 0 ? centerMidi : 60;
    final minMidi = center - range / 2;
    final maxMidi = center + range / 2;

    final linePaint = Paint()
      ..color = settings.pitchColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final visibleDuration = Duration(milliseconds: (15000 / hZoom).round());
    final now = history.last.timestamp;
    final cutoff = now.subtract(visibleDuration);

    final visiblePoints = history
        .where((p) => p.timestamp.isAfter(cutoff))
        .toList();
    if (visiblePoints.length < 2) return;

    final path = Path();
    var started = false;

    for (var i = 0; i < visiblePoints.length; i++) {
      final point = visiblePoints[i];
      final elapsed = point.timestamp.difference(cutoff).inMilliseconds;
      final totalMs = visibleDuration.inMilliseconds;
      final x = 40 + (size.width - 40) * elapsed / totalMs;
      final y = _midiToY(point.midi, size, minMidi, maxMidi);

      if (y < 0 || y > size.height) continue;

      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  double _midiToY(double midi, Size size, double minMidi, double maxMidi) {
    final ratio = (midi - minMidi) / (maxMidi - minMidi);
    return size.height * (1 - ratio);
  }

  @override
  bool shouldRepaint(covariant PitchGraphPainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.settings != settings ||
        oldDelegate.centerMidi != centerMidi;
  }
}
