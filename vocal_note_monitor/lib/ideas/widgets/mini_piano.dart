import 'package:flutter/material.dart';

/// Compact piano strip used only in Ideas screens.
class MiniPiano extends StatelessWidget {
  const MiniPiano({
    super.key,
    this.startMidi = 48,
    this.whiteKeyCount = 14,
    this.chordPitchClasses = const {},
    this.activeMidi,
  });

  final int startMidi;
  final int whiteKeyCount;
  final Set<int> chordPitchClasses;
  final int? activeMidi;

  static const _whiteOffsets = [0, 2, 4, 5, 7, 9, 11];

  @override
  Widget build(BuildContext context) {
    final whiteMidis = <int>[];
    var midi = startMidi;
    while (whiteMidis.length < whiteKeyCount) {
      if (_whiteOffsets.contains(midi % 12)) {
        whiteMidis.add(midi);
      }
      midi++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final whiteWidth = constraints.maxWidth / whiteKeyCount;
        final blackWidth = whiteWidth * 0.62;
        final height = 88.0;

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Row(
                children: whiteMidis.map((m) {
                  final inChord = chordPitchClasses.contains(m % 12);
                  final isActive =
                      activeMidi != null &&
                      activeMidi! % 12 == m % 12 &&
                      (activeMidi! - m).abs() <= 1;
                  return Container(
                    width: whiteWidth,
                    height: height,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFFEB3B)
                          : inChord
                          ? const Color(0xFF4A6FA5)
                          : Colors.white,
                      border: Border.all(color: Colors.black26),
                    ),
                  );
                }).toList(),
              ),
              ..._blackKeys(whiteMidis, whiteWidth, blackWidth, height),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _blackKeys(
    List<int> whiteMidis,
    double whiteWidth,
    double blackWidth,
    double height,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < whiteMidis.length - 1; i++) {
      final left = whiteMidis[i];
      final right = whiteMidis[i + 1];
      if (right - left != 2) continue;
      final blackMidi = left + 1;
      final inChord = chordPitchClasses.contains(blackMidi % 12);
      final isActive =
          activeMidi == blackMidi ||
          (activeMidi != null && activeMidi! % 12 == blackMidi % 12);
      widgets.add(
        Positioned(
          left: (i + 1) * whiteWidth - blackWidth / 2,
          top: 0,
          child: Container(
            width: blackWidth,
            height: height * 0.58,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFFEB3B)
                  : inChord
                  ? const Color(0xFF6B8FC4)
                  : const Color(0xFF222222),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(3),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
