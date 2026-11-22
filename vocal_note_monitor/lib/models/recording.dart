import 'stem_notes.dart';

enum RecordingSource { mic, file, library }

enum RecordingStatus { raw, reading, ready }

class Recording {
  const Recording({
    required this.id,
    required this.name,
    required this.source,
    required this.duration,
    required this.createdAt,
    required this.status,
    required this.fileName,
    this.stems = const [],
    this.selectedStemId,
    this.error,
  });

  final String id;
  final String name;
  final RecordingSource source;
  final Duration duration;
  final DateTime createdAt;
  final RecordingStatus status;
  final String fileName;
  final List<StemNotes> stems;
  final String? selectedStemId;
  final String? error;

  StemNotes? get selected {
    final current = stemById(stems, selectedStemId);
    if (current != null && current.playable) return current;
    return stemById(stems, defaultStemId(stems));
  }

  bool get hasPlayableNotes => stems.any((stem) => stem.playable);

  Recording copyWith({
    String? name,
    RecordingStatus? status,
    Duration? duration,
    List<StemNotes>? stems,
    String? selectedStemId,
    String? error,
    bool clearError = false,
  }) {
    return Recording(
      id: id,
      name: name ?? this.name,
      source: source,
      duration: duration ?? this.duration,
      createdAt: createdAt,
      status: status ?? this.status,
      fileName: fileName,
      stems: stems ?? this.stems,
      selectedStemId: selectedStemId ?? this.selectedStemId,
      error: clearError ? null : (error ?? this.error),
    );
  }

  factory Recording.fromJson(Map<String, dynamic> json) {
    final rawStems = json['stems'];
    final stems = <StemNotes>[];
    if (rawStems is List) {
      for (final item in rawStems) {
        if (item is Map<String, dynamic>) {
          stems.add(StemNotes.fromJson(item));
        } else if (item is Map) {
          stems.add(StemNotes.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return Recording(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'audio',
      source: RecordingSource.values.byName(json['source'] as String? ?? 'file'),
      duration: Duration(milliseconds: (json['duration_ms'] as num?)?.round() ?? 0),
      createdAt: DateTime.parse(json['created_at'] as String),
      status: RecordingStatus.values.byName(json['status'] as String? ?? 'raw'),
      fileName: json['file_name'] as String? ?? 'audio.m4a',
      stems: stems,
      selectedStemId: json['selected_stem_id'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'source': source.name,
    'duration_ms': duration.inMilliseconds,
    'created_at': createdAt.toIso8601String(),
    'status': status.name,
    'file_name': fileName,
    'stems': [for (final stem in stems) stem.toJson()],
    'selected_stem_id': selectedStemId,
    'error': error,
  };
}

String formatDuration(Duration duration) {
  final total = duration.inSeconds;
  final minutes = total ~/ 60;
  final seconds = total % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String formatRecordingDate(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.day)}.${two(local.month)}.${local.year}';
}

