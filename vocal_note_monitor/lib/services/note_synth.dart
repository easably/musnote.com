import 'dart:math';
import 'dart:typed_data';

import '../models/piano_note.dart';

/// Short triangle-plus-sine tones, timed like the site keyboard.
class NoteSynth {
  static const sampleRate = 22050;
  static const maxSeconds = 90.0;

  /// True when the piece is longer than [maxSeconds], so playback stops early.
  static bool longerThanPlayback(List<PianoNote> notes) {
    if (notes.length < 2) return false;
    return notes.last.start - notes.first.start > maxSeconds;
  }

  static Uint8List wav(List<PianoNote> notes) {
    if (notes.isEmpty) return Uint8List(0);
    final t0 = notes.first.start;
    final samples = Float64List((maxSeconds * sampleRate).ceil() + sampleRate);
    var used = 0;

    for (final note in notes) {
      final startAt = note.start - t0;
      if (startAt < 0 || startAt >= maxSeconds) continue;
      final freq = 440 * pow(2, (note.midi - 69) / 12);
      final startSample = (startAt * sampleRate).round();
      final length = (1.6 * sampleRate).round();
      var phase = 0.0;
      final step = freq / sampleRate;
      for (var i = 0; i < length; i++) {
        final index = startSample + i;
        if (index >= samples.length) break;
        final env = _env(i, length);
        final tri = _tri(phase);
        final sine = sin(2 * pi * phase);
        samples[index] += (tri * 0.7 + sine * 0.3) * env * 0.12;
        phase += step;
        if (phase >= 1) phase -= phase.floor();
        if (index + 1 > used) used = index + 1;
      }
    }

    if (used < sampleRate ~/ 10) used = sampleRate ~/ 10;
    var peak = 0.0;
    for (var i = 0; i < used; i++) {
      final amp = samples[i].abs();
      if (amp > peak) peak = amp;
    }
    final gain = peak > 0.9 ? 0.9 / peak : 1.0;
    final pcm = Int16List(used);
    for (var i = 0; i < used; i++) {
      pcm[i] = (samples[i] * gain * 32767).round().clamp(-32767, 32767);
    }
    return _wav(pcm);
  }

  static double _tri(double phase) {
    final p = phase % 1;
    return p < 0.5 ? 4 * p - 1 : 3 - 4 * p;
  }

  static double _env(int i, int length) {
    const attack = 0.012;
    final t = i / sampleRate;
    if (t < attack) return t / attack;
    final rest = max(0.05, length / sampleRate - attack);
    final x = ((t - attack) / rest).clamp(0.0, 1.0);
    return pow(0.001, x).toDouble();
  }

  static Uint8List _wav(Int16List pcm) {
    final dataSize = pcm.length * 2;
    final bytes = BytesBuilder();
    void addString(String value) => bytes.add(value.codeUnits);
    void add32(int value) {
      bytes.add([
        value & 0xff,
        (value >> 8) & 0xff,
        (value >> 16) & 0xff,
        (value >> 24) & 0xff,
      ]);
    }

    void add16(int value) {
      bytes.add([value & 0xff, (value >> 8) & 0xff]);
    }

    addString('RIFF');
    add32(36 + dataSize);
    addString('WAVE');
    addString('fmt ');
    add32(16);
    add16(1);
    add16(1);
    add32(sampleRate);
    add32(sampleRate * 2);
    add16(2);
    add16(16);
    addString('data');
    add32(dataSize);
    bytes.add(pcm.buffer.asUint8List(pcm.offsetInBytes, pcm.lengthInBytes));
    return bytes.toBytes();
  }
}
