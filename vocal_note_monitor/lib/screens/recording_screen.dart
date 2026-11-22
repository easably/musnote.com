import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/ui_text.dart';
import '../models/piano_note.dart';
import '../models/recording.dart';
import '../models/stem_notes.dart';
import '../services/recording_store.dart';
import '../services/separated_notes_api.dart';
import '../services/store_review_service.dart';
import '../theme/musnote_theme.dart';
import '../theme/musnote_tokens.g.dart';
import 'share_sheet.dart';
import 'trainer_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key, required this.recordingId});

  final String recordingId;

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with WidgetsBindingObserver {
  final _player = AudioPlayer();
  final _api = SeparatedNotesApi();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  var _playing = false;
  Duration _position = Duration.zero;
  Duration _heard = Duration.zero;
  var _leftVisit = false;
  RecordingStore? _store;
  StoreReviewService? _review;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _review?.enterRecording(widget.recordingId);
      _noteActivity();
    });
    _subscriptions.add(
      _player.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() => _position = position);
          if (_playing) _noteActivity();
        }
      }),
    );
    _subscriptions.add(
      _player.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _heard = duration);
      }),
    );
    _subscriptions.add(
      _player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _playing = false;
            _position = Duration.zero;
          });
        }
      }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store ??= context.read<RecordingStore>();
    _review ??= context.read<StoreReviewService>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _finishVisit();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    _api.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ready = _currentNotesReady();
    final review = _review;
    if (review == null) return;
    if (state == AppLifecycleState.resumed) {
      review.setForeground(true, notesReady: ready);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      review.setForeground(false, notesReady: ready);
    }
  }

  bool _currentNotesReady() {
    final store = _store;
    if (store == null) return false;
    final recording = _recording(store);
    return recording != null && recording.hasPlayableNotes;
  }

  void _noteActivity() {
    _review?.noteActivity(notesReady: _currentNotesReady());
  }

  void _finishVisit() {
    if (_leftVisit) return;
    _leftVisit = true;
    _review?.leaveRecording(notesReady: _currentNotesReady());
  }

  Recording? _recording(RecordingStore store) {
    for (final item in store.items) {
      if (item.id == widget.recordingId) return item;
    }
    return null;
  }

  Future<void> _togglePlay(Recording recording) async {
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
    final file = await context.read<RecordingStore>().audioFile(recording);
    await _player.play(DeviceFileSource(file.path));
    setState(() => _playing = true);
  }

  Future<void> _fetch(Recording recording) async {
    final store = context.read<RecordingStore>();
    await store.update(
      recording.copyWith(status: RecordingStatus.reading, clearError: true),
    );
    try {
      final hadNotes = recording.hasPlayableNotes;
      final file = await store.audioFile(recording);
      final stems = await _api.separatedNotes(file);
      final selected = defaultStemId(stems);
      final updated = recording.copyWith(
        status: RecordingStatus.ready,
        stems: stems,
        selectedStemId: selected,
        clearError: true,
      );
      await store.update(updated);
      if (updated.hasPlayableNotes && mounted) {
        if (!hadNotes) {
          await context.read<StoreReviewService>().noteReadySuccess();
        }
        _noteActivity();
      }
    } on SeparatedNotesException catch (error) {
      await store.update(
        recording.copyWith(status: RecordingStatus.raw, error: error.message),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = _recording(context.watch<RecordingStore>());
    if (recording == null) {
      return Scaffold(body: Center(child: Text(t(context).recordingGone)));
    }
    final text = t(context);
    final selected = recording.selected;
    final shown = recording.duration == Duration.zero ? _heard : recording.duration;
    final progress = shown.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / shown.inMilliseconds).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: MusnoteColors.surface2,
      appBar: AppBar(
        backgroundColor: MusnoteColors.surface,
        title: Text(recording.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _noteActivity(),
        onPointerMove: (_) => _noteActivity(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _noteActivity();
            return false;
          },
          child: MusnotePage(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Hero(
            recording: recording,
            duration: shown,
            playing: _playing,
            progress: progress,
            onPlay: () => _togglePlay(recording),
          ),
          const SizedBox(height: 16),
          if (recording.status == RecordingStatus.reading)
            const _Reading()
          else if (recording.status != RecordingStatus.ready) ...[
            if (recording.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  shownError(text, recording.error!),
                  style: const TextStyle(color: MusnoteColors.danger),
                ),
              ),
            Text(text.serverReads),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _fetch(recording),
              icon: const Icon(Icons.piano),
              label: Text(text.getNotes),
            ),
          ] else ...[
            if (!recording.hasPlayableNotes || selected == null)
              Text(text.noNotes)
            else ...[
              Text(_summary(text, selected)),
              const SizedBox(height: 12),
              _TrainerPlate(
                stemTitle: stemName(text, selected.id),
                onPlay: () {
                  _noteActivity();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrainerScreen(
                        recordingId: recording.id,
                        notes: selected.notes,
                        title: '${stemName(text, selected.id)} · ${recording.name}',
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            Text(text.stemsHeading.toUpperCase(), style: MusnoteType.section),
            const SizedBox(height: 8),
            for (final stem in recording.stems)
              _StemTile(
                stem: stem,
                chosen: stem.id == recording.selectedStemId,
                onTap: stem.playable
                    ? () {
                        _noteActivity();
                        context.read<RecordingStore>().update(
                          recording.copyWith(selectedStemId: stem.id),
                        );
                      }
                    : null,
              ),
            if (recording.hasPlayableNotes) ...[
              const SizedBox(height: 16),
              TakeNotes(recording: recording),
            ],
            const SizedBox(height: 8),
            Text(
              text.comingSoon,
              style: const TextStyle(color: MusnoteColors.muted),
            ),
          ],
        ],
      ),
      ),
        ),
      ),
    );
  }
}

String _summary(AppLocalizations text, StemNotes stem) {
  final notes = stem.notes;
  var lo = notes.first.midi;
  var hi = notes.first.midi;
  var end = 0.0;
  for (final note in notes) {
    if (note.midi < lo) lo = note.midi;
    if (note.midi > hi) hi = note.midi;
    if (note.end > end) end = note.end;
  }
  final span = Duration(milliseconds: (end * 1000).round());
  return text.foundNotes(
    notes.length,
    formatDuration(span),
    PianoNote.nameForMidi(lo),
    PianoNote.nameForMidi(hi),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.recording,
    required this.duration,
    required this.playing,
    required this.progress,
    required this.onPlay,
  });

  final Recording recording;
  final Duration duration;
  final bool playing;
  final double progress;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: MusnoteColors.green50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_sourceIcon(recording.source), color: MusnoteColors.green700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recording.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Text(
                      '${sourceName(t(context), recording.source)} · ${formatDuration(duration)} · ${formatRecordingDate(recording.createdAt)}',
                      style: const TextStyle(color: MusnoteColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Material(
                color: MusnoteColors.green500,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onPlay,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: MusnoteColors.line,
                    color: MusnoteColors.green500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatDuration(duration),
                style: const TextStyle(color: MusnoteColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _sourceIcon(RecordingSource source) {
  switch (source) {
    case RecordingSource.mic:
      return Icons.mic;
    case RecordingSource.file:
      return Icons.insert_drive_file_outlined;
  }
}

class _Reading extends StatelessWidget {
  const _Reading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          'assets/lottie/musnote-loading.json',
          width: 240,
          height: 96,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(t(context).reading),
      ],
    );
  }
}

class _TrainerPlate extends StatelessWidget {
  const _TrainerPlate({required this.stemTitle, required this.onPlay});

  final String stemTitle;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [MusnoteTokens.green400, MusnoteTokens.green700],
          ),
          boxShadow: MusnoteTokens.shadowLift,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.piano, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(context).playTrainer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    t(context).trainerSub(stemTitle),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StemTile extends StatelessWidget {
  const _StemTile({required this.stem, required this.chosen, required this.onTap});

  final StemNotes stem;
  final bool chosen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final quiet = !stem.playable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: chosen ? MusnoteColors.green50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _Radio(on: chosen, off: quiet),
                const SizedBox(width: 10),
                Icon(
                  _stemIcon(stem.id),
                  color: quiet ? MusnoteColors.muted : MusnoteColors.green700,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stemName(t(context), stem.id),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: quiet ? MusnoteColors.muted : MusnoteColors.ink,
                        ),
                      ),
                      Text(
                        quiet ? stemQuiet(t(context), stem) : _range(t(context), stem),
                        style: const TextStyle(color: MusnoteColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (!quiet) _MiniBars(seed: stem.notes.first.midi),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _range(AppLocalizations text, StemNotes stem) {
  var lo = stem.notes.first.midi;
  var hi = stem.notes.first.midi;
  for (final note in stem.notes) {
    if (note.midi < lo) lo = note.midi;
    if (note.midi > hi) hi = note.midi;
  }
  return text.stemNotes(stem.notes.length, PianoNote.nameForMidi(lo), PianoNote.nameForMidi(hi));
}

IconData _stemIcon(String id) {
  switch (id) {
    case 'vocals':
      return Icons.mic_none;
    case 'piano':
      return Icons.piano;
    case 'guitar':
      return Icons.music_note;
    case 'bass':
      return Icons.graphic_eq;
    case 'drums':
      return Icons.album_outlined;
    default:
      return Icons.blur_on;
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.on, required this.off});

  final bool on;
  final bool off;

  @override
  Widget build(BuildContext context) {
    final color = off ? MusnoteColors.line : MusnoteColors.green500;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: on ? MusnoteColors.green500 : Colors.transparent,
      ),
      child: on
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            )
          : null,
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var k = 0; k < 9; k++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.25 + sin((k + 1) * ((seed % 7) + 1)).abs() * 0.7,
                    widthFactor: 1,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: MusnoteColors.green500,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
