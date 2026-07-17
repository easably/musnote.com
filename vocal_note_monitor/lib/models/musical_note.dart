import 'dart:math';

const _noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

class MusicalNote {
  const MusicalNote({
    required this.name,
    required this.octave,
    required this.frequency,
    required this.midi,
    required this.cents,
  });

  final String name;
  final int octave;
  final double frequency;
  final double midi;
  final double cents;

  String get displayName => '$name $octave';

  String get sharpName {
    final flatMap = {
      'C#': 'D♭',
      'D#': 'E♭',
      'F#': 'G♭',
      'G#': 'A♭',
      'A#': 'B♭',
    };
    return flatMap[name] ?? name;
  }

  static String nameForMidi(int midi) => _noteNames[midi % 12];

  static int octaveForMidi(int midi) => (midi ~/ 12) - 1;

  static double frequencyForMidi(double midi, {double a4Frequency = 440}) {
    return a4Frequency * pow(2, (midi - 69) / 12);
  }

  static MusicalNote fromFrequency(double frequency, {double a4Frequency = 440}) {
    if (frequency <= 0) {
      return const MusicalNote(
        name: '—',
        octave: 0,
        frequency: 0,
        midi: 0,
        cents: 0,
      );
    }

    final midi = 69 + 12 * (log(frequency / a4Frequency) / ln2);
    final roundedMidi = midi.round();
    final cents = (midi - roundedMidi) * 100;
    final noteIndex = ((roundedMidi % 12) + 12) % 12;
    final octave = (roundedMidi ~/ 12) - 1;

    return MusicalNote(
      name: _noteNames[noteIndex],
      octave: octave,
      frequency: frequency,
      midi: midi,
      cents: cents,
    );
  }

  static List<String> labelsAround(double midi) {
    final center = midi.round();
    return [
      nameForMidi(center - 1),
      nameForMidi(center),
      nameForMidi(center + 1),
    ];
  }
}
