/// One piano key from the audio service: which key, and when it sounds.
class PianoNote {
  const PianoNote({
    required this.midi,
    required this.name,
    required this.start,
    required this.end,
    required this.velocity,
  });

  final int midi;
  final String name;
  final double start;
  final double end;
  final double velocity;

  factory PianoNote.fromJson(Map<String, dynamic> json) {
    final midi = (json['midi'] as num).round();
    return PianoNote(
      midi: midi,
      name: json['name'] as String? ?? nameForMidi(midi),
      start: (json['start'] as num?)?.toDouble() ?? 0,
      end: (json['end'] as num?)?.toDouble() ?? 0,
      velocity: (json['velocity'] as num?)?.toDouble() ?? 0,
    );
  }

  static const letters = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// Letter on the key, without the octave. C4 → C, F#3 → F#.
  static String letterForMidi(int midi) => letters[_pitchClass(midi)];

  static String nameForMidi(int midi) => '${letterForMidi(midi)}${midi ~/ 12 - 1}';

  static int _pitchClass(int midi) {
    final pitch = midi % 12;
    return pitch < 0 ? pitch + 12 : pitch;
  }
}

const blackPitchClasses = {1, 3, 6, 8, 10};

bool midiIsBlack(int midi) {
  final pitch = midi % 12;
  return blackPitchClasses.contains(pitch < 0 ? pitch + 12 : pitch);
}
