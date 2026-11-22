import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_note_monitor/models/piano_note.dart';
import 'package:vocal_note_monitor/models/recording.dart';
import 'package:vocal_note_monitor/models/stem_notes.dart';
import 'package:vocal_note_monitor/services/notes_midi.dart';
import 'package:vocal_note_monitor/services/recording_store.dart';

void main() {
  test('a recording saved from the old media library still opens as a file', () {
    final recording = Recording.fromJson({
      'id': '1',
      'name': 'Song',
      'source': 'library',
      'created_at': '2026-01-01T00:00:00.000',
      'file_name': 'audio.mp3',
    });
    expect(recording.source, RecordingSource.file);
  });

  test('import keeps the file and rejects a file over 100 MB', () async {
    final root = await Directory.systemTemp.createTemp('musnote-store');
    final store = RecordingStore(directory: root);
    final source = File('${root.path}/song.mp3')..writeAsStringSync('notes');

    final saved = await store.importFile(
      source: source,
      kind: RecordingSource.file,
      displayName: 'Песня',
    );

    expect(store.items, hasLength(1));
    expect(saved.name, 'Песня');
    expect(saved.status, RecordingStatus.raw);
    final copied = await store.audioFile(saved);
    expect(await copied.readAsString(), 'notes');

    final huge = File('${root.path}/huge.mp3');
    final sink = huge.openSync(mode: FileMode.write);
    sink.writeFromSync(List<int>.filled(1024, 1));
    // The store checks length, so a stub over the limit is enough.
    await huge.writeAsBytes(List<int>.filled(RecordingStore.maxBytes + 1, 1));
    expect(
      () => store.importFile(source: huge, kind: RecordingSource.file),
      throwsA(isA<RecordingStoreException>()),
    );
  });

  test('default stem is piano, otherwise the fullest part', () {
    StemNotes stem(String id, int count, {bool empty = false}) {
      return StemNotes(
        id: id,
        loudnessDb: empty ? -60 : -10,
        empty: empty,
        clipped: false,
        notes: [
          for (var i = 0; i < count; i++)
            PianoNote(midi: 60, name: 'C4', start: i.toDouble(), end: i + 0.2, velocity: 0.8),
        ],
      );
    }

    expect(
      defaultStemId([stem('vocals', 3), stem('piano', 2), stem('drums', 9)]),
      'piano',
    );
    expect(
      defaultStemId([stem('vocals', 2), stem('guitar', 5), stem('piano', 0, empty: true)]),
      'guitar',
    );
    expect(defaultStemId([stem('drums', 4), stem('bass', 0, empty: true)]), isNull);
  });

  test('midi file has one track, or one track per part', () {
    final note = PianoNote(
      midi: 60,
      name: 'C4',
      start: 0,
      end: 0.5,
      velocity: 0.8,
    );
    final one = NotesMidi.encode([
      [note],
    ]);
    expect(String.fromCharCodes(one.sublist(0, 4)), 'MThd');
    expect(one[9], 0); // format 0

    final two = NotesMidi.encode([
      [note],
      [note],
    ]);
    expect(two[9], 1); // format 1
    expect(two[11], 2); // two tracks
  });

  test('a reading that was interrupted comes back as not processed', () async {
    final root = await Directory.systemTemp.createTemp('musnote-store');
    final store = RecordingStore(directory: root);
    final source = File('${root.path}/a.wav')..writeAsStringSync('a');
    final saved = await store.importFile(source: source, kind: RecordingSource.mic);
    await store.update(saved.copyWith(status: RecordingStatus.reading));

    final again = RecordingStore(directory: root);
    await again.load();
    expect(again.items.single.status, RecordingStatus.raw);
  });
}
