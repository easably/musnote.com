// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get noteNames => 'Note names';

  @override
  String get noteLetters => 'C D E';

  @override
  String get noteSolfege => 'До Ре Ми';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get writeUs => 'Write to us';

  @override
  String get howItWorks => 'How it works';

  @override
  String get language => 'Language';

  @override
  String get languageAuto => 'System language';

  @override
  String languageAutoNamed(String name) {
    return 'System language ($name)';
  }

  @override
  String get tools => 'Tools';

  @override
  String get toolsTooltip => 'Tools';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get toolAudio => 'Audio to notes';

  @override
  String get toolAudioHint => 'Recordings on this phone';

  @override
  String get toolMonitor => 'Voice monitor';

  @override
  String get toolMonitorHint => 'Live pitch';

  @override
  String get groupInApp => 'In the app';

  @override
  String get groupChords => 'Chords';

  @override
  String get groupVoice => 'Voice';

  @override
  String get toolPiano => 'Ear: piano';

  @override
  String get toolPianoHint => 'Hear a note and find it';

  @override
  String get toolChart => 'Chord chart';

  @override
  String get toolChartHint => 'Look up a chord';

  @override
  String get toolClock => 'Chord clock';

  @override
  String get toolClockHint => 'Chords around the circle';

  @override
  String get toolHops => 'Steps 4+3 / 3+4';

  @override
  String get toolHopsHint => 'Move by chord steps';

  @override
  String get toolPatterns => 'CFG and iDEA';

  @override
  String get toolPatternsHint => 'Two chord patterns';

  @override
  String get toolSpeech => 'Audio to text';

  @override
  String get toolSpeechHint => 'Words from a recording';

  @override
  String get toolSlow => 'Slow pronunciation';

  @override
  String get toolSlowHint => 'Hear a phrase slowly';

  @override
  String get toolOctave => 'Find my octave';

  @override
  String get toolOctaveHint => 'Your voice range';

  @override
  String get toolShadow => 'Shadow a phrase';

  @override
  String get toolShadowHint => 'Repeat after the voice';

  @override
  String get webMark => 'web';

  @override
  String get toolOffline => 'This page did not open. A connection is needed.';

  @override
  String get toolRetry => 'Try again';

  @override
  String get onbTitle => 'From sound to notes on the keys';

  @override
  String get onbLine => '🎙 Sound → ♪ Notes → 🎹 Keys';

  @override
  String get onbBody =>
      'Record a sound or pick a file. We read the notes, and you can play them on the keys.';

  @override
  String get start => 'Start';

  @override
  String get addSound => 'Add a sound';

  @override
  String get addFormats =>
      'mp3, wav, m4a, flac, aac, ogg, webm · up to 100 MB · ✓ free';

  @override
  String get tabRecord => 'Record';

  @override
  String get tabFiles => 'Files';

  @override
  String get tabFromShare => 'Share';

  @override
  String get fromShareTitle => 'From Voice Memos';

  @override
  String get fromShareBody =>
      'Those recordings stay in Voice Memos. Send one here with Share. The file is m4a, and MusNote already opens it.';

  @override
  String get fromShareStep1 => 'Open the recording in Voice Memos.';

  @override
  String get fromShareStep2 => 'Tap Share, then Save to Files.';

  @override
  String get fromShareStep3 =>
      'Open the Files tab here and choose that recording.';



  @override
  String get needSource => 'Need another source?';

  @override
  String get needSourceHint =>
      'Tell us where you want to get music from — we will add the most requested';

  @override
  String get chipYoutube => 'YouTube link';

  @override
  String get chipVideo => 'Video from gallery';

  @override
  String get chipOther => 'Other…';

  @override
  String get pickFile => 'Choose a file';

  @override
  String get openFiles => 'Open Files';

  @override
  String get openingAudio => 'Opening audio on this phone…';






  @override
  String mailSubject(String chip) {
    return 'MusNote: I want a source — $chip';
  }

  @override
  String mailBody(String version, String system) {
    return 'App $version ($system)';
  }

  @override
  String get micNeeded => 'Microphone access is needed.';

  @override
  String get stop => 'Stop';

  @override
  String get recordingWord => 'Recording';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptyBody => 'Tap + to record a sound or pick a file.';

  @override
  String get deleteTitle => 'Delete this recording?';

  @override
  String deleteBody(String name) {
    return '“$name” and its file will be deleted from this phone.';
  }

  @override
  String get keep => 'Keep';

  @override
  String get delete => 'Delete';

  @override
  String get statusRaw => 'Not processed';

  @override
  String get statusReading => 'Reading notes…';

  @override
  String get statusReady => 'Notes ready';

  @override
  String get tapForNotes => 'Tap to get the notes';

  @override
  String recordingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings · stored on this phone',
      one: '$count recording · stored on this phone',
    );
    return '$_temp0';
  }

  @override
  String get recordingGone => 'Recording deleted';

  @override
  String get serverReads =>
      'The MusNote server will read the notes and lay them on the keys. ✓ free';

  @override
  String get getNotes => 'Get notes';

  @override
  String get noNotes => 'No notes found';

  @override
  String get stemsHeading => 'Tracks';

  @override
  String get comingSoon => 'Coming soon: sheet music (PDF) and MusicXML';

  @override
  String get reading => 'Reading notes…';

  @override
  String get playTrainer => 'Play in the trainer';

  @override
  String trainerSub(String stem) {
    return '$stem · falling notes · turn the phone';
  }

  @override
  String foundNotes(int count, String span, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count notes · $span · from $low to $high',
      one: 'Found $count note · $span · from $low to $high',
    );
    return '$_temp0';
  }

  @override
  String stemNotes(int count, String low, String high) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes · $low–$high',
      one: '$count note · $low–$high',
    );
    return '$_temp0';
  }

  @override
  String get take => 'Export';

  @override
  String get allStems => 'All tracks';

  @override
  String get trackWord => 'Track';

  @override
  String get midiTitle => 'MIDI file';

  @override
  String get midiOne => 'GarageBand, MuseScore, Synthesia';

  @override
  String get midiAll => 'One file, each track is its own part';

  @override
  String get pdfTitle => 'Letter sheet';

  @override
  String get pdfHint => 'Printable PDF · C E G…';

  @override
  String get txtTitle => 'Notes as text';

  @override
  String get txtHint => 'Phrases, no octave number';

  @override
  String get copyTitle => 'Copy notes';

  @override
  String get copyHint => 'To the clipboard';

  @override
  String get copied => 'Notes copied';

  @override
  String get buildFailed => 'Could not build the file';

  @override
  String get share => 'Share';

  @override
  String get saveDownloads => 'Save to Downloads';

  @override
  String get saveFiles => 'Save to Files';

  @override
  String get sendOut => 'Send…';

  @override
  String savedAs(String name) {
    return 'Saved: $name';
  }

  @override
  String get saveFailed => 'Could not save the file';

  @override
  String get playFailed => 'Could not play';

  @override
  String get first90 => 'The first 90 seconds play';

  @override
  String get fileFallback => 'recording';

  @override
  String get errType => 'Need an mp3, wav, m4a, flac, aac, ogg, or webm file.';

  @override
  String get errTooBig => 'The file is over 100 MB.';

  @override
  String get errEmpty => 'The file is empty.';

  @override
  String get errNetwork =>
      'Could not reach the server. Check the network and try again.';

  @override
  String get errRead => 'Could not read the notes. Try again.';

  @override
  String get errBad => 'The server returned an unexpected reply.';

  @override
  String get errStems => 'The server did not return six tracks.';

  @override
  String get turnPhone => 'Turn the phone';

  @override
  String get turn => 'Turn';

  @override
  String get tapHint => 'Tap — pause, speed, exit';

  @override
  String get stemVocals => 'Vocals';

  @override
  String get stemPiano => 'Piano';

  @override
  String get stemGuitar => 'Guitar';

  @override
  String get stemBass => 'Bass';

  @override
  String get stemOther => 'Other';

  @override
  String get stemDrums => 'Drums';

  @override
  String get quietDrums => 'drums — no notes';

  @override
  String get quietSilent => 'quiet — no notes';

  @override
  String get sourceMic => 'Recording';

  @override
  String get sourceFile => 'File';


  @override
  String get monitorSaved => 'Recording saved';

  @override
  String get monitorLoaded => 'Recording loaded';

  @override
  String get monitorSave => 'Save';

  @override
  String get monitorLoad => 'Load';

  @override
  String get monitorIdeas => 'Ideas (preview)';

  @override
  String get cancel => 'Cancel';

  @override
  String get langEn => 'English';

  @override
  String get langRu => 'Русский';

  @override
  String get langEs => 'Español';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langFr => 'Français';

  @override
  String get langIt => 'Italiano';

  @override
  String get langPl => 'Polski';
}
