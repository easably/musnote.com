class PitchPoint {
  const PitchPoint({
    required this.timestamp,
    required this.midi,
    required this.frequency,
    required this.amplitude,
  });

  final DateTime timestamp;
  final double midi;
  final double frequency;
  final double amplitude;
}
