import 'piano_note.dart';

/// One separated part from POST /v1/separated-notes.
class StemNotes {
  const StemNotes({
    required this.id,
    required this.loudnessDb,
    required this.empty,
    required this.clipped,
    required this.notes,
  });

  final String id;
  final double? loudnessDb;
  final bool empty;
  final bool clipped;
  final List<PianoNote> notes;

  /// Drums and quiet parts cannot be played or chosen.
  bool get playable => id != 'drums' && !empty && notes.isNotEmpty;

  factory StemNotes.fromJson(Map<String, dynamic> json) {
    final raw = json['notes'];
    final notes = <PianoNote>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          notes.add(PianoNote.fromJson(item));
        } else if (item is Map) {
          notes.add(PianoNote.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return StemNotes(
      id: json['id'] as String? ?? '',
      loudnessDb: (json['loudness_db'] as num?)?.toDouble(),
      empty: json['empty'] == true,
      clipped: json['clipped'] == true,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'loudness_db': loudnessDb,
    'empty': empty,
    'clipped': clipped,
    'notes': [
      for (final note in notes)
        {
          'midi': note.midi,
          'name': note.name,
          'start': note.start,
          'end': note.end,
          'velocity': note.velocity,
        },
    ],
  };
}

/// Piano if it has notes, otherwise the part with the most notes.
String? defaultStemId(List<StemNotes> stems) {
  final playable = stems.where((stem) => stem.playable).toList();
  if (playable.isEmpty) return null;
  for (final stem in playable) {
    if (stem.id == 'piano') return stem.id;
  }
  playable.sort((a, b) => b.notes.length.compareTo(a.notes.length));
  return playable.first.id;
}

StemNotes? stemById(List<StemNotes> stems, String? id) {
  if (id == null) return null;
  for (final stem in stems) {
    if (stem.id == id) return stem;
  }
  return null;
}
