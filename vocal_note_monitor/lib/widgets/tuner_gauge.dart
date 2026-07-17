import 'package:flutter/material.dart';

import '../models/musical_note.dart';

class TunerGauge extends StatelessWidget {
  const TunerGauge({super.key, required this.note, this.visible = true});

  final MusicalNote note;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible || note.frequency <= 0) {
      return const SizedBox(height: 36);
    }

    final labels = MusicalNote.labelsAround(note.midi);
    final cents = note.cents.clamp(-50.0, 50.0);
    final needleOffset = cents / 50;

    return SizedBox(
      height: 36,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(200, 24), painter: _TunerPainter()),
          Positioned(
            top: 0,
            left: 100 + needleOffset * 60 - 6,
            child: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF9E9E9E),
              size: 16,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels
                  .map(
                    (label) => Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 11,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TunerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF616161)
      ..strokeWidth = 1;

    const tickCount = 21;
    for (var i = 0; i < tickCount; i++) {
      final x = size.width * i / (tickCount - 1);
      final height = i == tickCount ~/ 2 ? 10.0 : 6.0;
      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
