import 'piano_note.dart';

/// Where a falling note sits, and which keys the keyboard shows.
///
/// Same numbers as `web/assets/js/falling-notes.js`. Keep both copies in step,
/// including [blackKeyWidth], [whiteBarWidth] and [blackBarWidth].
class FallingKey {
  const FallingKey({
    required this.midi,
    required this.black,
    required this.centerWhites,
    required this.widthWhites,
  });

  final int midi;
  final bool black;

  /// Center of the key, measured in white-key widths from the left.
  final double centerWhites;

  /// Width of the key, in white-key widths. A white key is 1.
  final double widthWhites;
}

class FallingKeyboardRange {
  const FallingKeyboardRange({required this.start, required this.whites});

  /// MIDI number of the first key. Always a white key.
  final int start;

  /// How many white keys to draw.
  final int whites;
}

class FallingBar {
  const FallingBar({
    required this.midi,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
    required this.active,
    required this.black,
  });

  final int midi;
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;
  final bool active;
  final bool black;
}

class FallingNotes {
  /// A black key is this fraction of a white key, and sits in the crack.
  static const blackKeyWidth = 0.6;

  /// Falling bar width, as a fraction of a white key.
  static const whiteBarWidth = 0.72;
  static const blackBarWidth = 0.48;

  static FallingKeyboardRange rangeForMidis(
    Iterable<int> midis, {
    int pad = 2,
    int minWhites = 8,
    int maxWhites = 24,
    int lowest = 21,
    int highest = 108,
  }) {
    var lo = 48;
    var hi = 72;
    final list = midis.toList();
    if (list.isNotEmpty) {
      lo = list.reduce((a, b) => a < b ? a : b);
      hi = list.reduce((a, b) => a > b ? a : b);
      lo = (lo - pad).clamp(lowest, highest);
      hi = (hi + pad).clamp(lowest, highest);
      if (hi < lo) hi = lo;
    }
    var start = lo;
    while (midiIsBlack(start) && start > 0) {
      start--;
    }
    var whites = 0;
    var midi = start;
    while (midi <= hi && whites < maxWhites) {
      if (!midiIsBlack(midi)) whites++;
      midi++;
    }
    while (whites < minWhites && midi < 128) {
      if (!midiIsBlack(midi)) whites++;
      midi++;
    }
    return FallingKeyboardRange(start: start, whites: whites);
  }

  static List<FallingKey> keyLayout(int start, int whites) {
    final keys = <FallingKey>[];
    var whiteIndex = 0;
    var midi = start;
    while (whiteIndex < whites) {
      if (midiIsBlack(midi)) {
        keys.add(FallingKey(
          midi: midi,
          black: true,
          centerWhites: whiteIndex.toDouble(),
          widthWhites: blackKeyWidth,
        ));
      } else {
        keys.add(FallingKey(
          midi: midi,
          black: false,
          centerWhites: whiteIndex + 0.5,
          widthWhites: 1,
        ));
        whiteIndex++;
      }
      midi++;
    }
    return keys;
  }

  /// Bars overlapping the lane. [y] grows downward; the bottom of the lane is now.
  static List<FallingBar> barsAtTime(
    List<({int midi, double start, double end})> notes,
    double time, {
    required double lookAhead,
    required double laneHeight,
    required double whiteKeyWidth,
    required List<FallingKey> keys,
  }) {
    final pixelsPerSecond = laneHeight / lookAhead;
    final byMidi = {for (final key in keys) key.midi: key};
    final out = <FallingBar>[];
    for (final note in notes) {
      if (note.end <= time) continue;
      if (note.start >= time + lookAhead) continue;
      final key = byMidi[note.midi];
      if (key == null) continue;
      final bottom = laneHeight - (note.start - time) * pixelsPerSecond;
      final top = laneHeight - (note.end - time) * pixelsPerSecond;
      final y = top < 0 ? 0.0 : top;
      final y1 = bottom > laneHeight ? laneHeight : bottom;
      final height = y1 - y;
      if (height < 0.5) continue;
      final width = (key.black ? blackBarWidth : whiteBarWidth) * whiteKeyWidth;
      out.add(FallingBar(
        midi: note.midi,
        x: key.centerWhites * whiteKeyWidth - width / 2,
        y: y,
        width: width,
        height: height,
        label: PianoNote.letterForMidi(note.midi),
        active: note.start <= time && time < note.end,
        black: key.black,
      ));
    }
    return out;
  }
}
