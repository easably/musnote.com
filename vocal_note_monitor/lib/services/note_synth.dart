import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../models/piano_note.dart';

/// Short triangle-plus-sine tones, timed like the recording.
class NoteSynth {
  static const sampleRate = 22050;

  static Uint8List wav(List<PianoNote> notes) => _wav(_mix(notes));

  static void writeFile(List<PianoNote> notes, String path) {
    File(path).writeAsBytesSync(wav(notes), flush: true);
  }

  static Int16List _mix(List<PianoNote> notes) {
    if (notes.isEmpty) return Int16List(sampleRate ~/ 10);
    final sorted = [...notes]..sort((a, b) => a.start.compareTo(b.start));
    var endAt = 0.1;
    for (final note in sorted) {
      final stop = note.start + _lengthSec(note);
      if (stop > endAt) endAt = stop;
    }
    final total = (endAt * sampleRate).ceil();
    final pcm = Int16List(total);
    const chunk = 22050;
    var next = 0;
    final active = <int>[];
    for (var start = 0; start < total; start += chunk) {
      final stop = min(start + chunk, total);
      final t0 = start / sampleRate;
      final t1 = stop / sampleRate;
      while (next < sorted.length && sorted[next].start < t1) {
        active.add(next);
        next++;
      }
      active.removeWhere((index) {
        final note = sorted[index];
        return note.start + _lengthSec(note) <= t0;
      });
      for (final index in active) {
        final note = sorted[index];
        final lengthSec = _lengthSec(note);
        final length = (lengthSec * sampleRate).round();
        final startSample = (note.start * sampleRate).round();
        if (startSample >= stop) continue;
        final freq = 440 * pow(2, (note.midi - 69) / 12);
        final step = freq / sampleRate;
        var phase = ((start - startSample).clamp(0, 1 << 30)) * step;
        phase = phase - phase.floor();
        final from = max(start, startSample);
        final to = min(stop, startSample + length);
        for (var sample = from; sample < to; sample++) {
          final i = sample - startSample;
          final env = _env(i, length);
          final tri = _tri(phase);
          final sine = sin(2 * pi * phase);
          final mixed = pcm[sample] / 32767 + (tri * 0.7 + sine * 0.3) * env * 0.1;
          pcm[sample] = (mixed.clamp(-1.0, 1.0) * 32767).round();
          phase += step;
          if (phase >= 1) phase -= phase.floor();
        }
      }
    }
    return pcm;
  }

  static double _lengthSec(PianoNote note) {
    final held = note.end - note.start;
    if (held.isNaN || held < 0.08) return 0.08;
    return held;
  }

  static double _tri(double phase) {
    final p = phase % 1;
    return p < 0.5 ? 4 * p - 1 : 3 - 4 * p;
  }

  static double _env(int i, int length) {
    const attack = 0.012;
    final t = i / sampleRate;
    if (t < attack) return t / attack;
    final total = max(attack + 0.02, length / sampleRate);
    final release = min(0.05, total * 0.25);
    final sustain = total - release;
    if (t < sustain) return 1;
    final x = ((t - sustain) / release).clamp(0.0, 1.0);
    return 1 - x;
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

/// Notes plus the wav path. An isolate can take this record.
typedef SynthWavJob = ({List<PianoNote> notes, String path});

/// Isolate entry. Writes a wav and returns its path.
String synthWavFile(SynthWavJob job) {
  NoteSynth.writeFile(job.notes, job.path);
  return job.path;
}
