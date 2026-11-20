import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/piano_note.dart';
import '../services/audio_path.dart';
import '../services/note_synth.dart';
import '../services/notes_api.dart';
import '../services/pitch_service.dart';
import '../theme/musnote_theme.dart';
import '../widgets/notes_piano.dart';

const _allowedExtensions = ['wav', 'mp3', 'm4a', 'ogg', 'flac', 'webm', 'aac'];

/// One job: a short recording becomes lit piano keys. Same steps as the site home.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.tabVisible});

  /// False when another bottom tab is showing, so recording and playback stop.
  final bool tabVisible;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NotesApi _api = NotesApi();
  AudioRecorder? _recorder;
  AudioPlayer? _player;

  Uint8List? _bytes;
  String? _filename;
  bool _recording = false;
  bool _busy = false;
  String _status = '';
  bool _statusBad = false;
  List<PianoNote> _notes = [];
  Set<int> _litMidi = {};
  int _playbackRun = 0;
  int _notesRequest = 0;

  @override
  void didUpdateWidget(NotesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabVisible && !widget.tabVisible) {
      _playbackRun++;
      if (_recording) {
        unawaited(_finishRecording());
      } else {
        unawaited(_player?.stop());
      }
    }
  }

  @override
  void dispose() {
    _playbackRun++;
    _notesRequest++;
    unawaited(_stopSound());
    _player?.dispose();
    _recorder?.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _stopSound() async {
    if (_recording) {
      try {
        await _recorder?.stop();
      } catch (_) {}
      if (mounted) setState(() => _recording = false);
    }
    try {
      await _player?.stop();
    } catch (_) {}
  }

  void _setStatus(String text, {bool bad = false}) {
    setState(() {
      _status = text;
      _statusBad = bad;
    });
  }

  Future<void> _toggleRecord() async {
    if (_busy) return;
    if (_recording) {
      await _finishRecording();
      return;
    }
    if (kIsWeb) {
      _setStatus('Choose an audio file.', bad: true);
      return;
    }

    await context.read<PitchService>().stop();
    final recorder = _recorder ??= AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        _setStatus('Microphone access is needed to record.', bad: true);
        return;
      }
      final path = await tempRecordingPath();
      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
    } catch (_) {
      _setStatus('Could not start the recording.', bad: true);
      return;
    }
    setState(() {
      _recording = true;
      _status = 'Recording…';
      _statusBad = false;
      _notes = [];
      _litMidi = {};
    });
  }

  Future<void> _finishRecording() async {
    String? path;
    try {
      path = await _recorder?.stop();
    } catch (_) {
      path = null;
    }
    if (!mounted) return;
    setState(() => _recording = false);
    if (path == null || path.isEmpty) {
      _setStatus('Could not save this recording.', bad: true);
      return;
    }
    Uint8List bytes;
    try {
      bytes = await readAudioFile(path);
    } catch (_) {
      if (mounted) {
        _setStatus('Could not save this recording.', bad: true);
      }
      return;
    }
    if (!mounted) return;
    if (bytes.length > NotesApi.maxBytes) {
      _setStatus('File is larger than 15 MB.', bad: true);
      return;
    }
    setState(() {
      _bytes = bytes;
      _filename = 'solo.m4a';
      _status = '';
      _notes = [];
      _litMidi = {};
    });
  }

  Future<void> _pickFile() async {
    if (_busy) return;
    if (_recording) await _finishRecording();
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: true,
    );
    if (!mounted || picked == null || picked.files.isEmpty) return;
    final file = picked.files.single;
    final name = file.name;
    final dot = name.lastIndexOf('.');
    final ext = dot >= 0 ? name.substring(dot + 1).toLowerCase() : '';
    if (!_allowedExtensions.contains(ext)) {
      _setStatus(
        'Upload wav, mp3, m4a, ogg, flac, webm, or aac.',
        bad: true,
      );
      return;
    }
    if (file.size > NotesApi.maxBytes) {
      _setStatus('File is larger than 15 MB.', bad: true);
      return;
    }
    var bytes = file.bytes;
    if (bytes == null && file.path != null) {
      try {
        bytes = await readAudioFile(file.path!);
      } catch (_) {
        bytes = null;
      }
    }
    if (!mounted) return;
    if (bytes == null || bytes.isEmpty) {
      _setStatus('Choose an audio file first.', bad: true);
      return;
    }
    setState(() {
      _bytes = bytes;
      _filename = name;
      _status = '';
      _notes = [];
      _litMidi = {};
    });
  }

  Future<void> _getNotes() async {
    if (_recording) await _finishRecording();
    final ready = _bytes;
    final readyName = _filename;
    if (ready == null || readyName == null) {
      _setStatus('Choose an audio file first.', bad: true);
      return;
    }
    final id = ++_notesRequest;
    _playbackRun++;
    await _player?.stop();
    setState(() {
      _busy = true;
      _status = 'Reading notes…';
      _statusBad = false;
      _notes = [];
      _litMidi = {};
    });

    try {
      final result = await _api.pianoNotes(bytes: ready, filename: readyName);
      if (!mounted || id != _notesRequest) return;
      if (result.notes.isEmpty) {
        setState(() {
          _busy = false;
          _notes = [];
          _litMidi = {};
          _status = 'No piano notes in this recording.';
          _statusBad = true;
        });
        return;
      }
      setState(() {
        _busy = false;
        _notes = result.notes;
        _litMidi = result.notes.map((note) => note.midi).toSet();
        _status = result.clipped ? 'Showing the first 4000 notes.' : '';
        _statusBad = false;
      });
    } on NotesApiException catch (error) {
      if (!mounted || id != _notesRequest) return;
      setState(() {
        _busy = false;
        _status = error.message;
        _statusBad = true;
      });
    }
  }

  Future<void> _play() async {
    if (_notes.isEmpty || _busy) return;
    final token = ++_playbackRun;
    final notes = _notes;
    final player = _player ??= AudioPlayer();
    try {
      await player.stop();
      await player.play(BytesSource(NoteSynth.wav(notes), mimeType: 'audio/wav'));
    } catch (_) {
      if (mounted && token == _playbackRun) {
        _setStatus('Could not play these notes.', bad: true);
      }
      return;
    }
    if (!mounted || token != _playbackRun) return;
    if (NoteSynth.longerThanPlayback(notes)) {
      _setStatus('Playing the first 90 seconds.');
    }

    final t0 = notes.first.start;
    final groups = <int, List<PianoNote>>{};
    for (final note in notes) {
      final key = ((note.start - t0) * 1000).round();
      if (key > (NoteSynth.maxSeconds * 1000)) continue;
      groups.putIfAbsent(key, () => []).add(note);
    }
    final starts = groups.keys.toList()..sort();
    for (final start in starts) {
      unawaited(
        Future<void>.delayed(Duration(milliseconds: start), () {
          if (!mounted || token != _playbackRun) return;
          setState(() {
            _litMidi = groups[start]!.map((note) => note.midi).toSet();
          });
        }),
      );
    }
    final last = starts.isEmpty ? 0 : starts.last;
    unawaited(
      Future<void>.delayed(Duration(milliseconds: last + 900), () {
        if (!mounted || token != _playbackRun) return;
        setState(() => _litMidi = notes.map((note) => note.midi).toSet());
      }),
    );
  }

  Future<void> _openChords() async {
    final uri = Uri.parse('https://musnote.com/chords/patterns/');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _bytes != null;
    final canPlay = _notes.isNotEmpty && !_busy;
    return ColoredBox(
      color: MusnoteColors.surface2,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            const _Eyebrow(text: 'Notes'),
            const SizedBox(height: 12),
            const Text(
              'audio to piano notes',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['serif', 'Noto Serif'],
                fontSize: 36,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: MusnoteColors.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload a short solo — piano, guitar, or a clear melody. '
              'Keys light up on the keyboard. Hit play. '
              'This is notes on keys, not a sheet of paper.',
              style: TextStyle(
                fontSize: 17,
                height: 1.45,
                color: MusnoteColors.inkSoft,
              ),
            ),
            const SizedBox(height: 22),
            DecoratedBox(
              decoration: BoxDecoration(
                color: MusnoteColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MusnoteColors.line),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F0F1F1A),
                    blurRadius: 40,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audio file (wav, mp3, m4a…)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: MusnoteColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _OutlineButton(
                          label: _recording ? 'Stop' : 'Record',
                          onPressed: _busy ? null : _toggleRecord,
                        ),
                        _OutlineButton(
                          label: 'Choose file',
                          onPressed: _busy ? null : _pickFile,
                        ),
                      ],
                    ),
                    if (_filename != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _filename!,
                        style: const TextStyle(color: MusnoteColors.muted),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _FillButton(
                          label: 'Get notes',
                          filled: MusnoteColors.green500,
                          onPressed: _busy || !hasFile ? null : _getNotes,
                        ),
                        _FillButton(
                          label: 'Play',
                          filled: MusnoteColors.ink,
                          onPressed: canPlay ? _play : null,
                        ),
                      ],
                    ),
                    if (_status.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _status,
                        style: TextStyle(
                          color: _statusBad
                              ? MusnoteColors.danger
                              : MusnoteColors.inkSoft,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    NotesPiano(
                      midis: _notes.map((note) => note.midi).toList(),
                      litMidi: _litMidi,
                    ),
                    if (_notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _notes.length == 1 ? '1 note' : '${_notes.length} notes',
                        style: const TextStyle(color: MusnoteColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _openChords,
                style: TextButton.styleFrom(
                  foregroundColor: MusnoteColors.green700,
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: const Text('Then practise the chords'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MusnoteColors.green50,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: MusnoteColors.green700,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: MusnoteColors.ink,
        disabledForegroundColor: MusnoteColors.muted,
        side: const BorderSide(color: MusnoteColors.line),
        backgroundColor: MusnoteColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      child: Text(label),
    );
  }
}

class _FillButton extends StatelessWidget {
  const _FillButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final Color filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: filled,
        disabledBackgroundColor: filled.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      child: Text(label),
    );
  }
}
