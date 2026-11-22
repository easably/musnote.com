import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/stem_notes.dart';

class SeparatedNotesException implements Exception {
  const SeparatedNotesException(this.message);

  final String message;
}

/// Upload one recording, get six stems back.
///
/// Same host as the site. Override with `--dart-define=NOTES_API_BASE=https://…`.
class SeparatedNotesApi {
  SeparatedNotesApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? defaultBaseUrl;

  static const defaultBaseUrl = String.fromEnvironment(
    'NOTES_API_BASE',
    defaultValue: 'https://api.musnote.com',
  );

  static const maxBytes = 100 * 1024 * 1024;

  final http.Client _client;
  final String baseUrl;

  void close() => _client.close();

  Future<List<StemNotes>> separatedNotes(File file) async {
    final length = await file.length();
    if (length == 0) {
      throw const SeparatedNotesException('empty');
    }
    if (length > maxBytes) {
      throw const SeparatedNotesException('tooBig');
    }

    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$root/v1/separated-notes'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final http.StreamedResponse streamed;
    try {
      streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 180));
    } catch (_) {
      throw const SeparatedNotesException('network');
    }

    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode == 413) {
      throw const SeparatedNotesException('tooBig');
    }
    if (streamed.statusCode != 200) {
      throw const SeparatedNotesException('read');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const SeparatedNotesException('bad');
    }
    final raw = decoded['stems'];
    if (raw is! List || raw.length != 6) {
      throw const SeparatedNotesException('stems');
    }
    return [
      for (final item in raw)
        StemNotes.fromJson(
          item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item as Map),
        ),
    ];
  }
}
