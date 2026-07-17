class MusicalScale {
  const MusicalScale({
    required this.root,
    required this.mode,
    required this.displayName,
    required this.degrees,
  });

  final String root;
  final String mode;
  final String displayName;
  final List<int> degrees;

  static const scales = [
    MusicalScale(
      root: 'C',
      mode: 'Major',
      displayName: 'C Major',
      degrees: [0, 2, 4, 5, 7, 9, 11],
    ),
    MusicalScale(
      root: 'G',
      mode: 'Major',
      displayName: 'G Major',
      degrees: [7, 9, 11, 0, 2, 4, 6],
    ),
    MusicalScale(
      root: 'D',
      mode: 'Major',
      displayName: 'D Major',
      degrees: [2, 4, 6, 7, 9, 11, 1],
    ),
    MusicalScale(
      root: 'A',
      mode: 'Minor',
      displayName: 'A Minor',
      degrees: [9, 11, 0, 2, 4, 5, 7],
    ),
    MusicalScale(
      root: 'E',
      mode: 'Minor',
      displayName: 'E Minor',
      degrees: [4, 6, 7, 9, 11, 0, 2],
    ),
  ];

  static const defaultScale = MusicalScale(
    root: 'C',
    mode: 'Major',
    displayName: 'C Major',
    degrees: [0, 2, 4, 5, 7, 9, 11],
  );

  int degreeForMidi(int midi) {
    final note = ((midi % 12) + 12) % 12;
    final index = degrees.indexOf(note);
    return index >= 0 ? index + 1 : 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicalScale &&
          root == other.root &&
          mode == other.mode &&
          displayName == other.displayName;

  @override
  int get hashCode => Object.hash(root, mode, displayName);
}
