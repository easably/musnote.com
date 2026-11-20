import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/models/piano_note.dart';
import 'package:vocal_note_monitor/services/note_synth.dart';
import 'package:vocal_note_monitor/widgets/notes_piano.dart';

void main() {
  test('note json keeps midi and start time', () {
    final note = PianoNote.fromJson({
      'midi': 60,
      'name': 'C4',
      'start': 0.5,
      'end': 1.2,
      'velocity': 0.8,
    });
    expect(note.midi, 60);
    expect(note.name, 'C4');
    expect(note.start, 0.5);
    expect(midiIsBlack(61), isTrue);
    expect(midiIsBlack(60), isFalse);
  });

  test('keyboard covers the notes and stays on white keys', () {
    final range = PianoKeyboardRange.forMidis([61, 72]);
    expect(range.whiteMidis.first % 12, isNot(anyOf(1, 3, 6, 8, 10)));
    expect(range.whiteMidis.first, lessThanOrEqualTo(61));
    expect(range.whiteMidis.last, greaterThanOrEqualTo(72));
  });

  test('playback wav is a short wave file', () {
    final wav = NoteSynth.wav(const [
      PianoNote(midi: 60, name: 'C4', start: 0, end: 0.4, velocity: 0.8),
      PianoNote(midi: 64, name: 'E4', start: 0.5, end: 0.9, velocity: 0.8),
    ]);
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(wav.length, greaterThan(1000));
  });
}
