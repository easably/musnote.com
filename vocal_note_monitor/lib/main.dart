import 'package:flutter/material.dart';

import 'app.dart';
import 'services/app_language.dart';
import 'services/note_spelling.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final language = AppLanguage();
  final spelling = NoteSpelling();
  await Future.wait([language.load(), spelling.load()]);
  spelling.followLanguage(language.resolved);
  runApp(VocalNoteMonitorApp(language: language, spelling: spelling));
}
