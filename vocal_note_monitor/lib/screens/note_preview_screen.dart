import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../l10n/ui_text.dart';
import '../models/recording.dart';
import '../models/stem_notes.dart';
import '../services/note_files.dart';
import '../services/note_spelling.dart';
import '../services/note_synth.dart';
import '../theme/musnote_theme.dart';
import 'offer_note_file.dart';

/// Opens the note file before saving it.
/// MIDI can be played. A letter sheet and plain text are shown as text.
class NotePreviewScreen extends StatefulWidget {
  const NotePreviewScreen({
    super.key,
    required this.recording,
    required this.stems,
    required this.kind,
    required this.allStems,
  });

  final Recording recording;
  final List<StemNotes> stems;
  final NoteFileKind kind;
  final bool allStems;

  @override
  State<NotePreviewScreen> createState() => _NotePreviewScreenState();
}

class _NotePreviewScreenState extends State<NotePreviewScreen> {
  final _player = AudioPlayer();
  var _busy = false;
  var _playing = false;
  Duration _position = Duration.zero;
  Duration _length = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.kind == NoteFileKind.midi) {
      _player.onPositionChanged.listen((position) {
        if (mounted) setState(() => _position = position);
      });
      _player.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _length = duration);
      });
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playing = false);
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<File> _file() {
    return writeNoteFile(
      recording: widget.recording,
      stems: widget.stems,
      spelling: context.read<NoteSpelling>(),
      kind: widget.kind,
      allStems: widget.allStems,
      text: t(context),
    );
  }

  Future<void> _share(BuildContext origin) async {
    final shareOrigin = shareButtonOrigin(origin);
    final file = await _file();
    if (!mounted) return;
    await offerNoteFile(context, file, widget.kind, origin: shareOrigin);
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
      return;
    }
    if (_position > Duration.zero) {
      await _player.resume();
      setState(() => _playing = true);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final notes = [for (final stem in widget.stems) ...stem.notes];
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/musnote-preview.wav';
      await compute(synthWavFile, (notes: notes, path: path));
      final played = File(path);
      if (!played.existsSync() || played.lengthSync() < 1000) {
        setState(() => _error = t(context).noNotes);
        return;
      }
      await _player.play(DeviceFileSource(path));
      setState(() => _playing = true);
    } catch (_) {
      setState(() => _error = t(context).playFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spelling = context.watch<NoteSpelling>();
    final name = noteFileName(
      widget.recording,
      stemId: widget.allStems ? null : widget.stems.first.id,
      extension: extensionFor(widget.kind),
      fallback: t(context).fileFallback,
    );
    final progress = _length.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _length.inMilliseconds;
    return Scaffold(
      backgroundColor: MusnoteColors.surface2,
      appBar: AppBar(
        backgroundColor: MusnoteColors.surface,
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: t(context).share,
              onPressed: () => _share(buttonContext),
              icon: const Icon(Icons.ios_share),
            ),
          ),
        ],
      ),
      body: widget.kind == NoteFileKind.midi
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    if (_busy)
                      const CircularProgressIndicator()
                    else
                      IconButton.filled(
                        onPressed: _toggle,
                        iconSize: 36,
                        icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                      ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_error!, style: const TextStyle(color: MusnoteColors.danger)),
                      ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final stem in widget.stems)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recording.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stemName(t(context), stem.id)} · ${formatRecordingDate(widget.recording.createdAt)} · musnote.com',
                          style: const TextStyle(color: MusnoteColors.muted),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          spelling.notesText(stem.notes),
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
