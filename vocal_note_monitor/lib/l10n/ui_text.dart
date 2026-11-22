import 'package:flutter/widgets.dart';

import '../models/recording.dart';
import '../models/stem_notes.dart';
import 'app_localizations.dart';

AppLocalizations t(BuildContext context) => AppLocalizations.of(context);

String stemName(AppLocalizations l, String id) {
  switch (id) {
    case 'vocals':
      return l.stemVocals;
    case 'piano':
      return l.stemPiano;
    case 'guitar':
      return l.stemGuitar;
    case 'bass':
      return l.stemBass;
    case 'other':
      return l.stemOther;
    case 'drums':
      return l.stemDrums;
    default:
      return id;
  }
}

String stemQuiet(AppLocalizations l, StemNotes stem) {
  if (stem.id == 'drums') return l.quietDrums;
  return l.quietSilent;
}

String sourceName(AppLocalizations l, RecordingSource source) {
  switch (source) {
    case RecordingSource.mic:
      return l.sourceMic;
    case RecordingSource.file:
      return l.sourceFile;
    case RecordingSource.library:
      return l.sourceLibrary;
  }
}

String? knownError(AppLocalizations l, String code) {
  switch (code) {
    case 'type':
      return l.errType;
    case 'tooBig':
      return l.errTooBig;
    case 'empty':
      return l.errEmpty;
    case 'network':
      return l.errNetwork;
    case 'read':
      return l.errRead;
    case 'bad':
      return l.errBad;
    case 'stems':
      return l.errStems;
    default:
      return null;
  }
}

String shownError(AppLocalizations l, String code) => knownError(l, code) ?? code;
