import 'dart:typed_data';

Future<Uint8List> readAudioFile(String path) async {
  throw UnsupportedError(path);
}

Future<String> tempRecordingPath() async {
  throw UnsupportedError('Recording a file needs the phone app.');
}
