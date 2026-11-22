import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/ui_text.dart';
import '../models/recording.dart';
import '../models/stem_notes.dart';
import 'note_spelling.dart';
import 'notes_midi.dart';
import 'notes_sheet_pdf.dart';

/// Which note file the person asked for.
enum NoteFileKind { midi, pdf, text }

String mimeFor(NoteFileKind kind) {
  switch (kind) {
    case NoteFileKind.midi:
      return 'audio/midi';
    case NoteFileKind.pdf:
      return 'application/pdf';
    case NoteFileKind.text:
      return 'text/plain';
  }
}

String extensionFor(NoteFileKind kind) {
  switch (kind) {
    case NoteFileKind.midi:
      return 'mid';
    case NoteFileKind.pdf:
      return 'pdf';
    case NoteFileKind.text:
      return 'txt';
  }
}

String noteFileName(
  Recording recording, {
  required String? stemId,
  required String extension,
  required String fallback,
}) {
  final safe = recording.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '-').trim();
  final base = safe.isEmpty ? fallback : safe;
  final part = stemId == null || stemId.isEmpty ? '' : '-$stemId';
  return '$base$part-musnote.$extension';
}

/// MIDI track name: "piano" becomes "Piano". An empty id stays "Track".
String trackTitle(String stemId) {
  if (stemId.isEmpty) return 'Track';
  return '${stemId[0].toUpperCase()}${stemId.substring(1)}';
}

String notesPlainText(
  List<StemNotes> stems,
  NoteSpelling spelling,
  AppLocalizations text,
) {
  return stems.map((stem) {
    return '${stemName(text, stem.id)}\n${spelling.notesText(stem.notes)}';
  }).join('\n\n');
}

/// Writes one MIDI, PDF, or text file into the temp folder and returns it.
Future<File> writeNoteFile({
  required Recording recording,
  required List<StemNotes> stems,
  required NoteSpelling spelling,
  required NoteFileKind kind,
  required bool allStems,
  required AppLocalizations text,
}) async {
  final dir = await getTemporaryDirectory();
  final name = noteFileName(
    recording,
    stemId: allStems ? null : stems.first.id,
    extension: extensionFor(kind),
    fallback: text.fileFallback,
  );
  final file = File('${dir.path}/$name');
  switch (kind) {
    case NoteFileKind.midi:
      await file.writeAsBytes(
        NotesMidi.encode(
          [for (final stem in stems) stem.notes],
          names: [for (final stem in stems) trackTitle(stem.id)],
        ),
        flush: true,
      );
    case NoteFileKind.pdf:
      await file.writeAsBytes(
        await notesSheetPdf(
          recording: recording,
          stems: stems,
          spelling: spelling,
          titleOf: (stem) => stemName(text, stem.id),
        ),
        flush: true,
      );
    case NoteFileKind.text:
      await file.writeAsString(notesPlainText(stems, spelling, text), flush: true);
  }
  return file;
}
