import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> readAudioFile(String path) => File(path).readAsBytes();

Future<String> tempRecordingPath() async {
  return '${Directory.systemTemp.path}/musnote-solo.m4a';
}
