import 'dart:typed_data';

import '../models/piano_note.dart';

/// MIDI file, same timing as `web/assets/js/notes-export.js`.
///
/// One part is one track. Several parts are one file, format 1.
class NotesMidi {
  static const ticksPerQuarter = 480;
  static const ticksPerSecond = 960;

  static Uint8List encode(
    List<List<PianoNote>> tracks, {
    List<String> names = const [],
  }) {
    final bodies = [
      for (var i = 0; i < tracks.length; i++)
        _track(
          tracks[i],
          channel: i >= 9 ? i + 1 : i,
          name: i < names.length ? names[i] : 'Track ${i + 1}',
        ),
    ];
    final count = bodies.length;
    final bytes = <int>[
      0x4d, 0x54, 0x68, 0x64,
      0x00, 0x00, 0x00, 0x06,
      0x00, count == 1 ? 0x00 : 0x01,
      (count >> 8) & 0xff, count & 0xff,
      (ticksPerQuarter >> 8) & 0xff, ticksPerQuarter & 0xff,
    ];
    for (final track in bodies) {
      bytes.addAll(track);
    }
    return Uint8List.fromList(bytes);
  }

  static List<int> _track(
    List<PianoNote> notes, {
    required int channel,
    required String name,
  }) {
    final events = <({int t, int order, List<int> bytes})>[];
    for (final note in notes) {
      final on = (note.start * ticksPerSecond).round().clamp(0, 1 << 28);
      var off = (note.end * ticksPerSecond).round().clamp(0, 1 << 28);
      if (off <= on) off = on + 1;
      final midi = note.midi.clamp(0, 127);
      final vel = _velocity(note.velocity);
      events.add((t: on, order: 1, bytes: [0x90 | channel, midi, vel]));
      events.add((t: off, order: 0, bytes: [0x80 | channel, midi, 0]));
    }
    events.sort((a, b) {
      final byTime = a.t.compareTo(b.t);
      return byTime != 0 ? byTime : a.order.compareTo(b.order);
    });

    final nameBytes = name.codeUnits;
    final track = <int>[
      0x00, 0xff, 0x03, nameBytes.length, ...nameBytes,
      if (channel == 0) ...[0x00, 0xff, 0x51, 0x03, 0x07, 0xa1, 0x20],
      0x00, 0xc0 | channel, 0x00,
    ];
    var last = 0;
    for (final event in events) {
      track.addAll(_varLen(event.t - last));
      track.addAll(event.bytes);
      last = event.t;
    }
    track.addAll(const [0x00, 0xff, 0x2f, 0x00]);

    final len = track.length;
    return [
      0x4d, 0x54, 0x72, 0x6b,
      (len >> 24) & 0xff,
      (len >> 16) & 0xff,
      (len >> 8) & 0xff,
      len & 0xff,
      ...track,
    ];
  }

  static List<int> _varLen(int value) {
    final bytes = <int>[value & 0x7f];
    var n = value >> 7;
    while (n > 0) {
      bytes.insert(0, (n & 0x7f) | 0x80);
      n >>= 7;
    }
    return bytes;
  }

  static int _velocity(double velocity) {
    var vel = (velocity.clamp(0, 1) * 127).round();
    if (vel < 1) vel = 1;
    if (vel > 127) vel = 127;
    return vel;
  }
}
