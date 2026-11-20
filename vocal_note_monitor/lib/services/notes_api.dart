import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/piano_note.dart';

class NotesApiException implements Exception {
  const NotesApiException(this.message);

  final String message;
}

class NotesTranscription {
  const NotesTranscription({required this.notes, required this.clipped});

  final List<PianoNote> notes;
  final bool clipped;
}

/// File in, piano notes out. Same service as the site.
///
/// Override the host with `--dart-define=NOTES_API_BASE=https://…`.
/// The default is the local Docker port; a phone cannot reach it until a
/// public address exists.
class NotesApi {
  NotesApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? defaultBaseUrl;

  static const defaultBaseUrl = String.fromEnvironment(
    'NOTES_API_BASE',
    defaultValue: 'http://127.0.0.1:8095',
  );

  static const maxBytes = 15 * 1024 * 1024;

  final http.Client _client;
  final String baseUrl;

  void close() => _client.close();

  /// Upload one audio file and read the piano-note list.
  Future<NotesTranscription> pianoNotes({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (bytes.isEmpty) {
      throw const NotesApiException('Choose an audio file first.');
    }
    if (bytes.length > maxBytes) {
      throw const NotesApiException('File is larger than 15 MB.');
    }

    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$root/v1/piano-notes'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final http.StreamedResponse streamed;
    try {
      streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 120));
    } catch (_) {
      throw const NotesApiException('Note service is unavailable right now.');
    }

    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode == 413) {
      throw const NotesApiException('File is larger than 15 MB.');
    }
    if (streamed.statusCode != 200) {
      throw const NotesApiException('Could not read notes from this audio.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw const NotesApiException('Could not read notes from this audio.');
    }
    if (decoded is! Map) {
      throw const NotesApiException('Could not read notes from this audio.');
    }

    final notes = <PianoNote>[];
    final raw = decoded['notes'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          notes.add(PianoNote.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    notes.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      return byStart != 0 ? byStart : a.midi.compareTo(b.midi);
    });
    return NotesTranscription(notes: notes, clipped: decoded['clipped'] == true);
  }
}
