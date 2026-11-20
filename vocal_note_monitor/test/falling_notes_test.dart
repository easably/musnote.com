import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/models/falling_notes.dart';
import 'package:vocal_note_monitor/widgets/notes_piano.dart';

void main() {
  test('keyboard range stays on white keys and covers the notes', () {
    final range = FallingNotes.rangeForMidis([61, 72]);
    expect(range.start % 12, isNot(anyOf(1, 3, 6, 8, 10)));
    expect(range.start, lessThanOrEqualTo(61));
    expect(range.whites, inInclusiveRange(8, 24));
    final whites = FallingNotes.keyLayout(range.start, range.whites).where((key) => !key.black);
    expect(whites.last.midi, greaterThanOrEqualTo(72));
  });

  test('the notes screen uses the same key range', () {
    final keys = PianoKeyboardRange.forMidis([61, 72]);
    final range = FallingNotes.rangeForMidis([61, 72]);
    expect(keys.whiteMidis.first, range.start);
    expect(keys.whiteMidis.length, range.whites);
  });

  test('a note falls onto its key and shortens while it is held', () {
    final keys = FallingNotes.keyLayout(60, 1);
    final before = FallingNotes.barsAtTime(
      [(midi: 60, start: 1.0, end: 2.0)],
      0,
      lookAhead: 4,
      laneHeight: 200,
      whiteKeyWidth: 40,
      keys: keys,
    );
    expect(before, hasLength(1));
    expect(before.single.label, 'C');
    expect(before.single.active, isFalse);
    expect(before.single.y, closeTo(100, 0.001));
    expect(before.single.height, closeTo(50, 0.001));
    expect(before.single.x, closeTo(5.6, 0.001));

    final held = FallingNotes.barsAtTime(
      [(midi: 60, start: 1.0, end: 2.0)],
      1.5,
      lookAhead: 4,
      laneHeight: 200,
      whiteKeyWidth: 40,
      keys: keys,
    );
    expect(held.single.active, isTrue);
    expect(held.single.y, closeTo(175, 0.001));
    expect(held.single.height, closeTo(25, 0.001));

    final gone = FallingNotes.barsAtTime(
      [(midi: 60, start: 0.0, end: 1.0)],
      1,
      lookAhead: 4,
      laneHeight: 200,
      whiteKeyWidth: 40,
      keys: keys,
    );
    expect(gone, isEmpty);
  });

  test('black key sits on the crack between white keys', () {
    final keys = FallingNotes.keyLayout(60, 2);
    expect(keys.map((key) => (key.midi, key.centerWhites)).toList(), [
      (60, 0.5),
      (61, 1.0),
      (62, 1.5),
    ]);
  });
}
