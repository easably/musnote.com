import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/recording.dart';

class RecordingStoreException implements Exception {
  const RecordingStoreException(this.message);

  final String message;
}

/// Audio files and their metadata, kept only on the phone.
class RecordingStore extends ChangeNotifier {
  RecordingStore({Directory? directory}) : _directory = directory;

  static const maxBytes = 100 * 1024 * 1024;
  static const allowedSuffixes = {'.mp3', '.wav', '.m4a', '.flac', '.aac', '.ogg', '.webm'};

  Directory? _directory;
  List<Recording> _items = [];
  var _durationsFilled = false;

  List<Recording> get items => List.unmodifiable(_items);

  Future<Directory> _root() async {
    final existing = _directory;
    if (existing != null) {
      await existing.create(recursive: true);
      return existing;
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'recordings'));
    await dir.create(recursive: true);
    _directory = dir;
    return dir;
  }

  File _audioFile(Directory root, Recording recording) {
    return File(p.join(root.path, recording.id, recording.fileName));
  }

  Future<File> audioFile(Recording recording) async {
    return _audioFile(await _root(), recording);
  }

  Future<void> load() async {
    final root = await _root();
    final index = File(p.join(root.path, 'index.json'));
    if (!await index.exists()) {
      _items = [];
      notifyListeners();
      return;
    }
    final raw = jsonDecode(await index.readAsString());
    final loaded = <Recording>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final recording = Recording.fromJson(Map<String, dynamic>.from(item));
        // A killed request must not stay on "reading" forever.
        loaded.add(
          recording.status == RecordingStatus.reading
              ? recording.copyWith(status: RecordingStatus.raw)
              : recording,
        );
      }
    }
    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _items = loaded;
    await fillMissingDurations();
    notifyListeners();
  }

  /// Files saved before duration was read still say 0:00. Read it once.
  Future<void> fillMissingDurations() async {
    if (_durationsFilled) return;
    _durationsFilled = true;
    final next = <Recording>[];
    var changed = false;
    for (final item in _items) {
      if (item.duration != Duration.zero) {
        next.add(item);
        continue;
      }
      final probed = await probeAudioDuration(_audioFile(await _root(), item));
      if (probed == Duration.zero) {
        next.add(item);
      } else {
        next.add(item.copyWith(duration: probed));
        changed = true;
      }
    }
    if (!changed) return;
    _items = next;
    await _saveIndex();
    notifyListeners();
  }

  Future<void> _saveIndex() async {
    final root = await _root();
    final index = File(p.join(root.path, 'index.json'));
    final payload = jsonEncode([for (final item in _items) item.toJson()]);
    await index.writeAsString(payload);
  }

  Future<Recording> importFile({
    required File source,
    required RecordingSource kind,
    String? displayName,
    Duration duration = Duration.zero,
  }) async {
    final suffix = p.extension(source.path).toLowerCase();
    if (!allowedSuffixes.contains(suffix)) {
      throw const RecordingStoreException('type');
    }
    final length = await source.length();
    if (length > maxBytes) {
      throw const RecordingStoreException('tooBig');
    }
    if (length == 0) {
      throw const RecordingStoreException('empty');
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final root = await _root();
    final folder = Directory(p.join(root.path, id));
    await folder.create(recursive: true);
    final fileName = 'audio$suffix';
    await source.copy(p.join(folder.path, fileName));

    final base = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : p.basenameWithoutExtension(source.path);
    final known = duration == Duration.zero
        ? await probeAudioDuration(File(p.join(folder.path, fileName)))
        : duration;
    final recording = Recording(
      id: id,
      name: base.isEmpty ? 'audio' : base,
      source: kind,
      duration: known,
      createdAt: DateTime.now(),
      status: RecordingStatus.raw,
      fileName: fileName,
    );
    _items = [recording, ..._items];
    await _saveIndex();
    notifyListeners();
    return recording;
  }

  Future<void> update(Recording recording) async {
    _items = [
      for (final item in _items)
        if (item.id == recording.id) recording else item,
    ];
    await _saveIndex();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final root = await _root();
    final folder = Directory(p.join(root.path, id));
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
    _items = [for (final item in _items) if (item.id != id) item];
    await _saveIndex();
    notifyListeners();
  }
}

/// Length of an audio file. A tiny stub (unit tests) stays at zero.
Future<Duration> probeAudioDuration(File file) async {
  if (!await file.exists()) return Duration.zero;
  if (await file.length() < 128) return Duration.zero;
  final player = AudioPlayer();
  try {
    await player.setSource(DeviceFileSource(file.path));
    return await player.getDuration() ?? Duration.zero;
  } catch (_) {
    return Duration.zero;
  } finally {
    await player.dispose();
  }
}
