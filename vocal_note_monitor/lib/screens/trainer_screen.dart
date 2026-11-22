import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/ui_text.dart';
import '../models/falling_notes.dart';
import '../models/piano_note.dart';
import '../services/note_synth.dart';
import '../services/store_review_service.dart';
import '../theme/musnote_theme.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({
    super.key,
    required this.recordingId,
    required this.notes,
    required this.title,
  });

  final String recordingId;
  final List<PianoNote> notes;
  final String title;

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen>
    with WidgetsBindingObserver {
  final _player = AudioPlayer();
  Timer? _hide;
  var _controls = true;
  var _hint = true;
  var _speed = 1.0;
  var _paused = false;
  var _time = 0.0;
  var _tablet = false;
  Timer? _tick;
  StoreReviewService? _review;
  DateTime? _lastActivityNote;

  Future<void> _allowOrientations() {
    if (_tablet) {
      return SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    return SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  double get _end {
    var end = 0.0;
    for (final note in widget.notes) {
      if (note.end > end) end = note.end;
    }
    return end;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final size = MediaQuery.sizeOf(context);
    _tablet = size.shortestSide >= 600;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final alreadyLandscape = size.width > size.height;
    if (!_tablet || !alreadyLandscape) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _review?.enterRecording(widget.recordingId);
      _noteActivity();
    });
    _startAudio();
    _tick = Timer.periodic(const Duration(milliseconds: 32), (_) => _advance());
    _hide = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _controls = false);
    });
    Future<void>.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _hint = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _review ??= context.read<StoreReviewService>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final review = _review;
    if (review == null) return;
    if (state == AppLifecycleState.resumed) {
      review.setForeground(true, notesReady: true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      review.setForeground(false, notesReady: true);
    }
  }

  void _noteActivity() {
    final now = DateTime.now();
    final last = _lastActivityNote;
    if (last != null && now.difference(last) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastActivityNote = now;
    _review?.noteActivity(notesReady: true, now: now);
  }

  Future<void> _startAudio() async {
    final bytes = NoteSynth.wav(widget.notes);
    if (bytes.isEmpty) return;
    await _player.setPlaybackRate(_speed);
    await _player.play(BytesSource(bytes));
    _player.onPlayerComplete.listen((_) {
      if (!mounted || _paused) return;
      _time = 0;
      _player.seek(Duration.zero);
      _player.resume();
    });
  }

  void _advance() {
    if (_paused || !mounted) return;
    _noteActivity();
    setState(() {
      _time += 0.032 * _speed;
      if (_time >= _end) _time = 0;
    });
  }

  void _showControls() {
    _noteActivity();
    setState(() => _controls = !_controls);
    _hide?.cancel();
    if (_controls) {
      _hide = Timer(const Duration(milliseconds: 3500), () {
        if (mounted) setState(() => _controls = false);
      });
    }
  }

  Future<void> _setSpeed(double speed) async {
    setState(() => _speed = speed);
    await _player.setPlaybackRate(speed);
  }

  Future<void> _togglePause() async {
    setState(() => _paused = !_paused);
    if (_paused) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> _close() async {
    await _allowOrientations();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _hide?.cancel();
    _player.dispose();
    _allowOrientations();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final portrait = size.height > size.width;
    if (portrait) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t(context).turnPhone),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  SystemChrome.setPreferredOrientations(const [
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ]);
                },
                child: Text(t(context).turn),
              ),
            ],
          ),
        ),
      );
    }

    final keyboardHeight = size.height * 0.28;
    final laneHeight = size.height - keyboardHeight;
    final range = FallingNotes.rangeForMidis(
      widget.notes.map((note) => note.midi),
      minWhites: 15,
    );
    final keys = FallingNotes.keyLayout(range.start, range.whites);
    final whiteWidth = size.width / range.whites;
    final bars = FallingNotes.barsAtTime(
      [
        for (final note in widget.notes)
          (midi: note.midi, start: note.start, end: note.end),
      ],
      _time,
      lookAhead: 2.6,
      laneHeight: laneHeight,
      whiteKeyWidth: whiteWidth,
      keys: keys,
    );
    final progress = _end == 0 ? 0.0 : (_time / _end).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: MusnoteColors.ink,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showControls,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: laneHeight,
              child: CustomPaint(painter: _LanePainter(bars)),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: keyboardHeight,
              child: CustomPaint(
                painter: _KeyboardPainter(keys, whiteWidth, bars),
              ),
            ),
            if (_hint)
              Center(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0x99000000),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      t(context).tapHint,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            if (_controls)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Material(
                  color: Colors.black54,
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _close,
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        for (final speed in const [0.5, 0.75, 1.0])
                          TextButton(
                            onPressed: () => _setSpeed(speed),
                            child: Text(
                              speed == 1 ? '1×' : '$speed×',
                              style: TextStyle(
                                color: _speed == speed ? MusnoteColors.green400 : Colors.white,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: _togglePause,
                          icon: Icon(
                            _paused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_controls)
              Positioned(
                left: 16,
                right: 16,
                top: 56,
                child: LinearProgressIndicator(value: progress),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanePainter extends CustomPainter {
  _LanePainter(this.bars);

  final List<FallingBar> bars;

  @override
  void paint(Canvas canvas, Size size) {
    for (final bar in bars) {
      final paint = Paint()
        ..color = bar.active
            ? MusnoteColors.green400
            : (bar.black ? MusnoteColors.green600 : MusnoteColors.green500);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bar.x + 2, bar.y, bar.width - 4, bar.height),
          const Radius.circular(10),
        ),
        paint,
      );
      if (bar.height < 22) continue;
      final text = TextPainter(
        text: TextSpan(
          text: bar.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        Offset(
          bar.x + bar.width / 2 - text.width / 2,
          bar.y + bar.height / 2 - text.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LanePainter oldDelegate) => true;
}

class _KeyboardPainter extends CustomPainter {
  _KeyboardPainter(this.keys, this.whiteWidth, this.bars);

  final List<FallingKey> keys;
  final double whiteWidth;
  final List<FallingBar> bars;

  @override
  void paint(Canvas canvas, Size size) {
    final lit = {for (final bar in bars) if (bar.active) bar.midi};
    for (final key in keys.where((key) => !key.black)) {
      final x = (key.centerWhites - key.widthWhites / 2) * whiteWidth;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, 0, whiteWidth - 2, size.height),
          const Radius.circular(4),
        ),
        Paint()..color = lit.contains(key.midi) ? MusnoteColors.keyLit : Colors.white,
      );
    }
    for (final key in keys.where((key) => key.black)) {
      final width = key.widthWhites * whiteWidth;
      final x = key.centerWhites * whiteWidth - width / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, width, size.height * 0.62),
          const Radius.circular(3),
        ),
        Paint()..color = lit.contains(key.midi) ? MusnoteColors.keyLitBlack : MusnoteColors.keyBlack,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _KeyboardPainter oldDelegate) => true;
}
