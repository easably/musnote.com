/// Chord helpers for Ideas / preview screens only.
/// Not wired into the main monitor.
class ChordTemplate {
  const ChordTemplate({
    required this.symbol,
    required this.rootPitchClass,
    required this.intervals,
    required this.label,
  });

  final String symbol;
  final int rootPitchClass;
  final List<int> intervals;
  final String label;

  Set<int> get pitchClasses =>
      intervals.map((i) => (rootPitchClass + i) % 12).toSet();

  String? roleForMidi(int midi) {
    final pc = ((midi % 12) + 12) % 12;
    final offset = (pc - rootPitchClass + 12) % 12;
    final index = intervals.indexOf(offset);
    if (index < 0) return null;
    const roles = ['root', '3rd', '5th', '7th', '9th'];
    return index < roles.length ? roles[index] : 'tone';
  }

  static const roots = [
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

  static String nameForPitchClass(int pc) => roots[((pc % 12) + 12) % 12];

  static List<ChordTemplate> get catalog {
    const qualities = <String, List<int>>{
      '': [0, 4, 7],
      'm': [0, 3, 7],
      '7': [0, 4, 7, 10],
    };
    final list = <ChordTemplate>[];
    for (var root = 0; root < 12; root++) {
      qualities.forEach((suffix, intervals) {
        final symbol = '${roots[root]}$suffix';
        list.add(
          ChordTemplate(
            symbol: symbol,
            rootPitchClass: root,
            intervals: intervals,
            label: suffix.isEmpty
                ? '${roots[root]} major'
                : suffix == 'm'
                ? '${roots[root]} minor'
                : '${roots[root]} dominant 7',
          ),
        );
      });
    }
    return list;
  }

  static ChordTemplate? matchPitchClasses(Set<int> heard) {
    if (heard.length < 3) return null;
    ChordTemplate? best;
    var bestExtra = 99;
    for (final chord in catalog) {
      if (!chord.pitchClasses.every(heard.contains)) continue;
      final extra = heard.length - chord.pitchClasses.length;
      if (extra < bestExtra) {
        bestExtra = extra;
        best = chord;
      }
    }
    return best;
  }
}
