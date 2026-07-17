import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:record/record.dart';

import '../models/musical_note.dart';
import '../models/pitch_point.dart';

enum RecordingState { stopped, recording, playing }

class PitchService extends ChangeNotifier {
  PitchService({this.a4Frequency = 440});

  final AudioRecorder _recorder = AudioRecorder();
  final PitchDetector _pitchDetector = PitchDetector();

  double a4Frequency;
  RecordingState state = RecordingState.stopped;

  MusicalNote currentNote = const MusicalNote(
    name: '—',
    octave: 0,
    frequency: 0,
    midi: 0,
    cents: 0,
  );

  final List<PitchPoint> _history = [];
  List<PitchPoint> get history => List.unmodifiable(_history);

  StreamSubscription<Uint8List>? _audioSubscription;
  Timer? _simulationTimer;
  int _simulationStep = 0;
  bool _processingPitch = false;

  static const _simulationMelody = [
    60.0,
    62.0,
    64.0,
    57.0,
    60.0,
    64.0,
    67.0,
    69.0,
  ];

  Future<void> startRecording() async {
    if (state == RecordingState.recording) return;

    await stop();

    if (kIsWeb || !await _tryStartMicrophone()) {
      _startSimulation();
    }

    state = RecordingState.recording;
    notifyListeners();
  }

  Future<bool> _tryStartMicrophone() async {
    try {
      if (!await _recorder.hasPermission()) return false;

      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        ),
      );

      _audioSubscription = stream.listen(_processAudioBuffer);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _processAudioBuffer(Uint8List buffer) async {
    if (buffer.length < 4 || _processingPitch) return;

    final samples = Int16List.view(buffer.buffer);
    final floatSamples = samples.map((s) => s / 32768.0).toList();

    final amplitude = _rms(floatSamples);
    if (amplitude < 0.01) return;

    if (floatSamples.length < PitchDetector.DEFAULT_BUFFER_SIZE) return;

    _processingPitch = true;
    try {
      final result = await _pitchDetector.getPitchFromFloatBuffer(floatSamples);
      if (result.pitched && result.pitch > 50 && result.pitch < 2000) {
        _addPitchPoint(result.pitch, amplitude * 100);
      }
    } catch (_) {
      // Ignore short/invalid buffers while streaming.
    } finally {
      _processingPitch = false;
    }
  }

  double _rms(List<double> samples) {
    if (samples.isEmpty) return 0;
    var sum = 0.0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    return sqrt(sum / samples.length);
  }

  void _startSimulation() {
    _simulationStep = 0;
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final baseMidi =
          _simulationMelody[_simulationStep % _simulationMelody.length];
      final vibrato = sin(_simulationStep * 0.3) * 0.15;
      final glide = sin(_simulationStep * 0.05) * 0.3;
      final midi = baseMidi + vibrato + glide;
      final frequency =
          MusicalNote.frequencyForMidi(midi, a4Frequency: a4Frequency);
      _addPitchPoint(frequency, 3.0 + Random().nextDouble());
      _simulationStep++;
    });
  }

  void _addPitchPoint(double frequency, double amplitude) {
    final note =
        MusicalNote.fromFrequency(frequency, a4Frequency: a4Frequency);
    currentNote = note;

    _history.add(
      PitchPoint(
        timestamp: DateTime.now(),
        midi: note.midi,
        frequency: frequency,
        amplitude: amplitude,
      ),
    );

    const maxPoints = 2000;
    if (_history.length > maxPoints) {
      _history.removeRange(0, _history.length - maxPoints);
    }

    notifyListeners();
  }

  Future<void> stop() async {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    await _audioSubscription?.cancel();
    _audioSubscription = null;

    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}

    if (state != RecordingState.playing) {
      state = RecordingState.stopped;
    }
    notifyListeners();
  }

  void play() {
    if (_history.isEmpty) return;
    state = RecordingState.playing;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    currentNote = const MusicalNote(
      name: '—',
      octave: 0,
      frequency: 0,
      midi: 0,
      cents: 0,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stop());
    _recorder.dispose();
    super.dispose();
  }
}
