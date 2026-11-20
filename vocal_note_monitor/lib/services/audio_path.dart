// Where a recorded solo is stored.
// The phone uses a real file (audio_path_io.dart). The browser build uses
// a stub (audio_path_web.dart) so dart:io is not pulled into web.
export 'audio_path_io.dart' if (dart.library.html) 'audio_path_web.dart';
