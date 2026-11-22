import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('ru'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @noteNames.
  ///
  /// In en, this message translates to:
  /// **'Note names'**
  String get noteNames;

  /// No description provided for @noteLetters.
  ///
  /// In en, this message translates to:
  /// **'C D E'**
  String get noteLetters;

  /// No description provided for @noteSolfege.
  ///
  /// In en, this message translates to:
  /// **'До Ре Ми'**
  String get noteSolfege;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @writeUs.
  ///
  /// In en, this message translates to:
  /// **'Write to us'**
  String get writeUs;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageAuto.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageAuto;

  /// No description provided for @languageAutoNamed.
  ///
  /// In en, this message translates to:
  /// **'System language ({name})'**
  String languageAutoNamed(String name);

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @toolsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @toolAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio to notes'**
  String get toolAudio;

  /// No description provided for @toolAudioHint.
  ///
  /// In en, this message translates to:
  /// **'Recordings on this phone'**
  String get toolAudioHint;

  /// No description provided for @toolMonitor.
  ///
  /// In en, this message translates to:
  /// **'Voice monitor'**
  String get toolMonitor;

  /// No description provided for @toolMonitorHint.
  ///
  /// In en, this message translates to:
  /// **'Live pitch'**
  String get toolMonitorHint;

  /// No description provided for @groupInApp.
  ///
  /// In en, this message translates to:
  /// **'In the app'**
  String get groupInApp;

  /// No description provided for @groupChords.
  ///
  /// In en, this message translates to:
  /// **'Chords'**
  String get groupChords;

  /// No description provided for @groupVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get groupVoice;

  /// No description provided for @toolPiano.
  ///
  /// In en, this message translates to:
  /// **'Ear: piano'**
  String get toolPiano;

  /// No description provided for @toolPianoHint.
  ///
  /// In en, this message translates to:
  /// **'Hear a note and find it'**
  String get toolPianoHint;

  /// No description provided for @toolChart.
  ///
  /// In en, this message translates to:
  /// **'Chord chart'**
  String get toolChart;

  /// No description provided for @toolChartHint.
  ///
  /// In en, this message translates to:
  /// **'Look up a chord'**
  String get toolChartHint;

  /// No description provided for @toolClock.
  ///
  /// In en, this message translates to:
  /// **'Chord clock'**
  String get toolClock;

  /// No description provided for @toolClockHint.
  ///
  /// In en, this message translates to:
  /// **'Chords around the circle'**
  String get toolClockHint;

  /// No description provided for @toolHops.
  ///
  /// In en, this message translates to:
  /// **'Steps 4+3 / 3+4'**
  String get toolHops;

  /// No description provided for @toolHopsHint.
  ///
  /// In en, this message translates to:
  /// **'Move by chord steps'**
  String get toolHopsHint;

  /// No description provided for @toolPatterns.
  ///
  /// In en, this message translates to:
  /// **'CFG and iDEA'**
  String get toolPatterns;

  /// No description provided for @toolPatternsHint.
  ///
  /// In en, this message translates to:
  /// **'Two chord patterns'**
  String get toolPatternsHint;

  /// No description provided for @toolSpeech.
  ///
  /// In en, this message translates to:
  /// **'Audio to text'**
  String get toolSpeech;

  /// No description provided for @toolSpeechHint.
  ///
  /// In en, this message translates to:
  /// **'Words from a recording'**
  String get toolSpeechHint;

  /// No description provided for @toolSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow pronunciation'**
  String get toolSlow;

  /// No description provided for @toolSlowHint.
  ///
  /// In en, this message translates to:
  /// **'Hear a phrase slowly'**
  String get toolSlowHint;

  /// No description provided for @toolOctave.
  ///
  /// In en, this message translates to:
  /// **'Find my octave'**
  String get toolOctave;

  /// No description provided for @toolOctaveHint.
  ///
  /// In en, this message translates to:
  /// **'Your voice range'**
  String get toolOctaveHint;

  /// No description provided for @toolShadow.
  ///
  /// In en, this message translates to:
  /// **'Shadow a phrase'**
  String get toolShadow;

  /// No description provided for @toolShadowHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat after the voice'**
  String get toolShadowHint;

  /// No description provided for @webMark.
  ///
  /// In en, this message translates to:
  /// **'web'**
  String get webMark;

  /// No description provided for @toolOffline.
  ///
  /// In en, this message translates to:
  /// **'This page did not open. A connection is needed.'**
  String get toolOffline;

  /// No description provided for @toolRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get toolRetry;

  /// No description provided for @onbTitle.
  ///
  /// In en, this message translates to:
  /// **'From sound to notes on the keys'**
  String get onbTitle;

  /// No description provided for @onbLine.
  ///
  /// In en, this message translates to:
  /// **'🎙 Sound → ♪ Notes → 🎹 Keys'**
  String get onbLine;

  /// No description provided for @onbBody.
  ///
  /// In en, this message translates to:
  /// **'Record a sound or pick a file. We read the notes, and you can play them on the keys.'**
  String get onbBody;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Record a melody or pick a file'**
  String get onbSoundTitle;

  /// No description provided for @onbSoundBody.
  ///
  /// In en, this message translates to:
  /// **'Piano, voice, a whole song — mp3, wav, m4a up to 100 MB.'**
  String get onbSoundBody;

  /// No description provided for @onbTracksTitle.
  ///
  /// In en, this message translates to:
  /// **'We find the notes and split the tracks'**
  String get onbTracksTitle;

  /// No description provided for @onbTracksBody.
  ///
  /// In en, this message translates to:
  /// **'Voice, piano, bass — each track has its own notes. Free, on the MusNote server.'**
  String get onbTracksBody;

  /// No description provided for @onbPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Play along and take the notes'**
  String get onbPlayTitle;

  /// No description provided for @onbPlayBody.
  ///
  /// In en, this message translates to:
  /// **'Notes fall onto the keys. Share a MIDI file, a letter sheet, or text.'**
  String get onbPlayBody;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @addSound.
  ///
  /// In en, this message translates to:
  /// **'Add a sound'**
  String get addSound;

  /// No description provided for @addFormats.
  ///
  /// In en, this message translates to:
  /// **'mp3, wav, m4a, flac, aac, ogg, webm · up to 100 MB · ✓ free'**
  String get addFormats;

  /// No description provided for @tabRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get tabRecord;

  /// No description provided for @tabFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get tabFiles;

  /// No description provided for @tabFromShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get tabFromShare;

  /// No description provided for @fromShareTitle.
  ///
  /// In en, this message translates to:
  /// **'From Voice Memos'**
  String get fromShareTitle;

  /// No description provided for @fromShareBody.
  ///
  /// In en, this message translates to:
  /// **'Those recordings stay in Voice Memos. Send one here with Share. The file is m4a, and MusNote already opens it.'**
  String get fromShareBody;

  /// No description provided for @fromShareStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the recording in Voice Memos.'**
  String get fromShareStep1;

  /// No description provided for @fromShareStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap Share, then Save to Files.'**
  String get fromShareStep2;

  /// No description provided for @fromShareStep3.
  ///
  /// In en, this message translates to:
  /// **'Open the Files tab here and choose that recording.'**
  String get fromShareStep3;

  /// No description provided for @needSource.
  ///
  /// In en, this message translates to:
  /// **'Need another source?'**
  String get needSource;

  /// No description provided for @needSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us where you want to get music from — we will add the most requested'**
  String get needSourceHint;

  /// No description provided for @chipYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube link'**
  String get chipYoutube;

  /// No description provided for @chipVideo.
  ///
  /// In en, this message translates to:
  /// **'Video from gallery'**
  String get chipVideo;

  /// No description provided for @chipOther.
  ///
  /// In en, this message translates to:
  /// **'Other…'**
  String get chipOther;

  /// No description provided for @pickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get pickFile;

  /// No description provided for @openFiles.
  ///
  /// In en, this message translates to:
  /// **'Open Files'**
  String get openFiles;

  /// No description provided for @openingAudio.
  ///
  /// In en, this message translates to:
  /// **'Opening audio on this phone…'**
  String get openingAudio;

  /// No description provided for @mailSubject.
  ///
  /// In en, this message translates to:
  /// **'MusNote: I want a source — {chip}'**
  String mailSubject(String chip);

  /// No description provided for @mailBody.
  ///
  /// In en, this message translates to:
  /// **'App {version} ({system})'**
  String mailBody(String version, String system);

  /// No description provided for @micNeeded.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed.'**
  String get micNeeded;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @recordingWord.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recordingWord;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record a sound or pick a file.'**
  String get emptyBody;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this recording?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” and its file will be deleted from this phone.'**
  String deleteBody(String name);

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @statusRaw.
  ///
  /// In en, this message translates to:
  /// **'Not processed'**
  String get statusRaw;

  /// No description provided for @statusReading.
  ///
  /// In en, this message translates to:
  /// **'Reading notes…'**
  String get statusReading;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Notes ready'**
  String get statusReady;

  /// No description provided for @tapForNotes.
  ///
  /// In en, this message translates to:
  /// **'Tap to get the notes'**
  String get tapForNotes;

  /// No description provided for @recordingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} recording · stored on this phone} other{{count} recordings · stored on this phone}}'**
  String recordingCount(int count);

  /// No description provided for @recordingGone.
  ///
  /// In en, this message translates to:
  /// **'Recording deleted'**
  String get recordingGone;

  /// No description provided for @serverReads.
  ///
  /// In en, this message translates to:
  /// **'The MusNote server will read the notes and lay them on the keys. ✓ free'**
  String get serverReads;

  /// No description provided for @getNotes.
  ///
  /// In en, this message translates to:
  /// **'Get notes'**
  String get getNotes;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get noNotes;

  /// No description provided for @stemsHeading.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get stemsHeading;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon: sheet music (PDF) and MusicXML'**
  String get comingSoon;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading notes…'**
  String get reading;

  /// No description provided for @playTrainer.
  ///
  /// In en, this message translates to:
  /// **'Play in the trainer'**
  String get playTrainer;

  /// No description provided for @trainerSub.
  ///
  /// In en, this message translates to:
  /// **'{stem} · falling notes · turn the phone'**
  String trainerSub(String stem);

  /// No description provided for @foundNotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Found {count} note · {span} · from {low} to {high}} other{Found {count} notes · {span} · from {low} to {high}}}'**
  String foundNotes(int count, String span, String low, String high);

  /// No description provided for @stemNotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note · {low}–{high}} other{{count} notes · {low}–{high}}}'**
  String stemNotes(int count, String low, String high);

  /// No description provided for @take.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get take;

  /// No description provided for @allStems.
  ///
  /// In en, this message translates to:
  /// **'All tracks'**
  String get allStems;

  /// No description provided for @trackWord.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get trackWord;

  /// No description provided for @midiTitle.
  ///
  /// In en, this message translates to:
  /// **'MIDI file'**
  String get midiTitle;

  /// No description provided for @midiOne.
  ///
  /// In en, this message translates to:
  /// **'GarageBand, MuseScore, Synthesia'**
  String get midiOne;

  /// No description provided for @midiAll.
  ///
  /// In en, this message translates to:
  /// **'One file, each track is its own part'**
  String get midiAll;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Letter sheet'**
  String get pdfTitle;

  /// No description provided for @pdfHint.
  ///
  /// In en, this message translates to:
  /// **'Printable PDF · C E G…'**
  String get pdfHint;

  /// No description provided for @txtTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes as text'**
  String get txtTitle;

  /// No description provided for @txtHint.
  ///
  /// In en, this message translates to:
  /// **'Phrases, no octave number'**
  String get txtHint;

  /// No description provided for @copyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy notes'**
  String get copyTitle;

  /// No description provided for @copyHint.
  ///
  /// In en, this message translates to:
  /// **'To the clipboard'**
  String get copyHint;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Notes copied'**
  String get copied;

  /// No description provided for @buildFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not build the file'**
  String get buildFailed;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveDownloads.
  ///
  /// In en, this message translates to:
  /// **'Save to Downloads'**
  String get saveDownloads;

  /// No description provided for @saveFiles.
  ///
  /// In en, this message translates to:
  /// **'Save to Files'**
  String get saveFiles;

  /// No description provided for @sendOut.
  ///
  /// In en, this message translates to:
  /// **'Send…'**
  String get sendOut;

  /// No description provided for @savedAs.
  ///
  /// In en, this message translates to:
  /// **'Saved: {name}'**
  String savedAs(String name);

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the file'**
  String get saveFailed;

  /// No description provided for @playFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play'**
  String get playFailed;

  /// No description provided for @first90.
  ///
  /// In en, this message translates to:
  /// **'The first 90 seconds play'**
  String get first90;

  /// No description provided for @fileFallback.
  ///
  /// In en, this message translates to:
  /// **'recording'**
  String get fileFallback;

  /// No description provided for @errType.
  ///
  /// In en, this message translates to:
  /// **'Need an mp3, wav, m4a, flac, aac, ogg, or webm file.'**
  String get errType;

  /// No description provided for @errTooBig.
  ///
  /// In en, this message translates to:
  /// **'The file is over 100 MB.'**
  String get errTooBig;

  /// No description provided for @errEmpty.
  ///
  /// In en, this message translates to:
  /// **'The file is empty.'**
  String get errEmpty;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check the network and try again.'**
  String get errNetwork;

  /// No description provided for @errRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read the notes. Try again.'**
  String get errRead;

  /// No description provided for @errBad.
  ///
  /// In en, this message translates to:
  /// **'The server returned an unexpected reply.'**
  String get errBad;

  /// No description provided for @errStems.
  ///
  /// In en, this message translates to:
  /// **'The server did not return six tracks.'**
  String get errStems;

  /// No description provided for @turnPhone.
  ///
  /// In en, this message translates to:
  /// **'Turn the phone'**
  String get turnPhone;

  /// No description provided for @turn.
  ///
  /// In en, this message translates to:
  /// **'Turn'**
  String get turn;

  /// No description provided for @tapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap — pause, speed, exit'**
  String get tapHint;

  /// No description provided for @stemVocals.
  ///
  /// In en, this message translates to:
  /// **'Vocals'**
  String get stemVocals;

  /// No description provided for @stemPiano.
  ///
  /// In en, this message translates to:
  /// **'Piano'**
  String get stemPiano;

  /// No description provided for @stemGuitar.
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get stemGuitar;

  /// No description provided for @stemBass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get stemBass;

  /// No description provided for @stemOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get stemOther;

  /// No description provided for @stemDrums.
  ///
  /// In en, this message translates to:
  /// **'Drums'**
  String get stemDrums;

  /// No description provided for @quietDrums.
  ///
  /// In en, this message translates to:
  /// **'drums — no notes'**
  String get quietDrums;

  /// No description provided for @quietSilent.
  ///
  /// In en, this message translates to:
  /// **'quiet — no notes'**
  String get quietSilent;

  /// No description provided for @sourceMic.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get sourceMic;

  /// No description provided for @sourceFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get sourceFile;

  /// No description provided for @monitorSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved'**
  String get monitorSaved;

  /// No description provided for @monitorLoaded.
  ///
  /// In en, this message translates to:
  /// **'Recording loaded'**
  String get monitorLoaded;

  /// No description provided for @monitorSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get monitorSave;

  /// No description provided for @monitorLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get monitorLoad;

  /// No description provided for @monitorIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas (preview)'**
  String get monitorIdeas;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @langEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @langRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get langRu;

  /// No description provided for @langEs.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langEs;

  /// No description provided for @langDe.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langDe;

  /// No description provided for @langFr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get langFr;

  /// No description provided for @langIt.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get langIt;

  /// No description provided for @langPl.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get langPl;

  /// No description provided for @storeReviewBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Songs turned into notes: {count}'**
  String storeReviewBannerTitle(int count);

  /// No description provided for @storeReviewBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If MusNote helps you hear the music, leave a short review.'**
  String get storeReviewBannerSubtitle;

  /// No description provided for @storeReviewBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get storeReviewBannerAction;

  /// No description provided for @storeReviewBannerThanks.
  ///
  /// In en, this message translates to:
  /// **'✓ Thank you!'**
  String get storeReviewBannerThanks;

  /// No description provided for @storeReviewBannerClose.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get storeReviewBannerClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pl',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
