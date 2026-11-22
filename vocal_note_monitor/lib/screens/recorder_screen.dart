import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../l10n/ui_text.dart';
import '../theme/musnote_theme.dart';

/// Wave, timer, and Stop. Returns the saved file.
class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final _recorder = AudioRecorder();
  final _clock = Stopwatch();
  Timer? _ticker;
  var _level = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      setState(() => _error = t(context).micNeeded);
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/musnote-${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    _clock.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 80), (_) async {
      final amp = await _recorder.getAmplitude();
      if (!mounted) return;
      setState(() => _level = ((amp.current + 45) / 45).clamp(0.05, 1));
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    if (path == null) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context, File(path));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _clock.elapsed;
    final label =
        '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: MusnoteColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(t(context).tabRecord),
      ),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 80,
                    width: 220,
                    child: CustomPaint(painter: _WavePainter(_level)),
                  ),
                  const SizedBox(height: 16),
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 36)),
                  const SizedBox(height: 28),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: MusnoteColors.danger),
                    onPressed: _stop,
                    child: Text(t(context).stop),
                  ),
                ],
              ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.level);

  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    const bars = 18;
    for (var i = 0; i < bars; i++) {
      final t = (i / bars + level) % 1;
      final h = 8 + (size.height - 8) * (0.3 + 0.7 * (t < 0.5 ? t : 1 - t)) * level;
      final x = size.width * i / bars;
      canvas.drawLine(
        Offset(x, (size.height - h) / 2),
        Offset(x, (size.height + h) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.level != level;
}
